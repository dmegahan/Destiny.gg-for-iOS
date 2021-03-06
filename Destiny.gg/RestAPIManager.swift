//
//  RestAPIManager.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 2/3/16.
//  Copyright © 2016 Daniel Megahan. All rights reserved.
//

import Foundation

enum JSONError: String, Error {
    case noData = "ERROR: no data"
    case conversionFailed = "ERROR: conversion from JSON failed"
}

class RestAPIManager: NSObject {
    //singleton
    static let sharedInstance = RestAPIManager();
    let baseURL = "https://api.twitch.tv/kraken/";
    
    let clientID = Config().getClientID()
    let youtubeAPIKey = Config().getYoutubeAPIKey();
    
    func isStreamOnline(_ streamer: String) -> (Bool){
        //construct REST api url
        let clientIDQueryString = "?client_id=" + clientID;
        
        let isOnlineURL = baseURL + "streams/" + streamer + clientIDQueryString;
        var isOnline:Bool = false;
        //create semaphore so we wait for the request to finish before reporting if stream is online or not
        let semaphore = DispatchSemaphore(value: 0);

        //make the request for the stream info
        makeHTTPGetRequest(isOnlineURL) { json in
            //we have the json dict, now we get the online status and return it
            //if the stream object is null, the streamer is offline
            if(json.object(forKey: "stream") == nil){
                //no stream object in dictionary, probably a non-existant stream, send false
                isOnline = false;
            }else{
                if(json["stream"] is NSNull){
                    //twitch API sends null when stream is offline
                    isOnline = false;
                }else{
                    isOnline = true;
                }
            }
            semaphore.signal();
        }
        //we wait forever, should put a 30 second timer here or something
        semaphore.wait(timeout: DispatchTime.now() + timeoutLength)
        return isOnline;
    }
    
    /*
    func doesStreamExist(_ streamer: String) -> (Bool){
        //construct REST api url
        let clientIDQueryString = "?client_id=" + clientID;
        
        let isOnlineURL = baseURL + "streams/" + streamer + clientIDQueryString;
        var doesExist:Bool = false;
        //create semaphore so we wait for the request to finish before reporting if stream is online or not
        let semaphore = DispatchSemaphore(value: 0);
        
        //make the request for the stream info
        makeHTTPGetRequest(isOnlineURL) { json in
            if(json.object(forKey: "error") == nil){
                //twitch api returns an error of "Not Found" for when a stream doesn't exist
                //If there's no error, then we can assume the stream exists
                doesExist = true;
            }else{
                //there is an error message, check to make sure its the "Not Found" message
                let errorMsg = json["error"] as! String;
                if(errorMsg == "Not Found"){
                    doesExist = false;
                }else{
                    doesExist = true;
                }
            }
            semaphore.signal();
        }
        //we wait forever, should put a 30 second timer here or something
        semaphore.wait(timeout: DispatchTime.now() + timeoutLength)
        return doesExist;
    }
    */
    
    func getTwitchVODs(_ streamer: String, _ vodType: String, _ optionalQuery_offset: Int = 0, optionalQuery_limit: Int = limit) -> ([Video]){
        let clientIDQueryString = "?client_id=" + clientID;
        
        //twitch will only give 1 type of video in each request. The default
        //video given is highlights, so we don't need to add anything if that's the case.
        var optionalQueries: String = "";
        if(vodType == VideoType.Broadcast.rawValue){
            optionalQueries = "&broadcasts=true";
        }
        //add limit and offset to our optional queries
        optionalQueries += "&offset=" + String(optionalQuery_offset);
        //dont request more than twitch allows 
        if(optionalQuery_limit > twitchHighestLimit){
            optionalQueries += "&limit=" + String(twitchHighestLimit);
        }else{
            optionalQueries += "&limit=" + String(optionalQuery_limit);
        }
        
        let channelVideosURL = baseURL + "channels/" + streamer + "/" + "videos" + clientIDQueryString + optionalQueries;

        let semaphore = DispatchSemaphore(value: 0);
        var videoList: [Video] = [];
        
        makeHTTPGetRequest(channelVideosURL) { json in
            if(json.object(forKey: "videos") != nil){
                for video in json.object(forKey: "videos") as! [Dictionary<String, AnyObject>] {
                    let length = video["length"] as! NSNumber;
                    let lengthString = length.stringValue;
                    videoList.append(Video(_title: video["title"] as! String,
                                                 _videoType: (video["broadcast_type"] as! String).capitalized,
                                                 _previewURL: video["preview"] as! String,
                                                    _length: lengthString,
                                                    _recordedAt: video["recorded_at"] as! String,
                                                    _views: video["views"] as! NSNumber,
                                                    _videoURL: video["url"] as! String));
                }
            }
            semaphore.signal();
        }
        semaphore.wait(timeout: DispatchTime.now() + timeoutLength);
        return videoList;
    }
    
    //needed to add the optionalQuery here as well, since this is the view controllers point of access for generating youtube videos
    func getYoutubeVideos(_ channel: String, _ optionalQuery_maxResults: Int = limit) -> [Video] {
        let channelID = RestAPIManager.sharedInstance.getYoutubeChannelID(channel);
        let videos: [Video] = RestAPIManager.sharedInstance.getYoutubeVideosList(channelID, optionalQuery_maxResults)
        let updatedVideos = RestAPIManager.sharedInstance.getYoutubeVideosDetails(videoList: videos);
        
        return updatedVideos;
    }
    
    func getYoutubeChannelID(_ channel: String) -> String{
        let baseURL = "https://www.googleapis.com/youtube/v3"
        
        //get the channel object
        let channelRequest = baseURL + "/channels?part=contentDetails&forUsername=" + channel + "&key=" + youtubeAPIKey
        var channelID : String = "";
        let semaphore = DispatchSemaphore(value: 0);
        
        makeHTTPGetRequest(channelRequest) { json in
            if(json.object(forKey: "items") != nil){
                let items = json.object(forKey: "items") as! Array<Dictionary<String, Any>>
                let item = items[0] as Dictionary<String, Any>;
                
                channelID = item["id"] as! String;
                
                //let details = item["contentDetails"] as! Dictionary<String, Any>
                //let playlists = details["relatedPlaylists"] as! Dictionary<String, Any>
                //playlistID = playlists["uploads"] as! String;
            }
            semaphore.signal()
        }
        semaphore.wait(timeout: DispatchTime.now() + timeoutLength)
        return channelID;
    }
    
    func getYoutubeVideosList(_ channelID: String, _ optionalQuery_maxResults: Int = limit) -> [Video]{
        let baseURL = "https://www.googleapis.com/youtube/v3"

        //get list of most recent videos
        
        var playlistRequest = baseURL + "/search?key=" + youtubeAPIKey + "&channelId=" + channelID + "&part=snippet&order=date"
        //add optionalquery_maxResults to the request
        //if optionalQuery_maxResults is higher than what youtube allows, request the highest possible number of videos
        if(optionalQuery_maxResults > youtubeHighestMaxResults){
            playlistRequest += "&maxResults=" + String(youtubeHighestMaxResults);
        }else{
            playlistRequest += "&maxResults=" + String(optionalQuery_maxResults);
        }
        
        let semaphore = DispatchSemaphore(value: 0);
        
        var videoList: [Video] = [];
        
        makeHTTPGetRequest(playlistRequest) { json in
            if(json.object(forKey: "items") != nil){
                for item in json.object(forKey: "items") as! [Dictionary<String, Any>]{
                    //check what kind of result this is: playlist or video
                    //get video id
                    let id = item["id"] as! Dictionary<String, Any>
                    let resultType = id["kind"] as! String
                    if (resultType == kindVideo) {
                        let videoID = id["videoId"] as! String
                        
                        //extract our data, google has a bunch of nested variables we need, so its messy
                        //snippet holds everything ,but has sublists
                        let snippet = item["snippet"] as! Dictionary<String, Any>
                        
                        let title = snippet["title"] as! String;
                        let publishedAt = snippet["publishedAt"] as! String
                        let type = VideoType.Youtube.rawValue;
                        
                        //enter a nested json - get preview image
                        let thumbnails = snippet["thumbnails"] as! Dictionary<String, Any>
                        let defaultThumbnail = thumbnails["default"] as! Dictionary<String, Any>
                        let defaultThumbnailURL = defaultThumbnail["url"] as! String
                        
                        videoList.append(Video(_title: title, _videoType: type, _previewURL: defaultThumbnailURL, _length: "0", _recordedAt: publishedAt, _views: 0, _videoURL: videoID))
                    }
                }
            }
            semaphore.signal()
        }
        semaphore.wait(timeout: DispatchTime.now() + timeoutLength)
        return videoList;
    }
    
    func getYoutubeVideosDetails(videoList: [Video], _ optionalQuery_maxResults: Int = limit) -> [Video]{
        let baseURL = "https://www.googleapis.com/youtube/v3"
        
        //append all the video IDs to the requestedVideoIds string, which will be inserted into the videos request later being sent
        var requestedVideoIDs = "";
        for video in videoList{
            requestedVideoIDs += video.videoURL + ","
        }
        //remove last comma
        requestedVideoIDs.remove(at: requestedVideoIDs.index(before: requestedVideoIDs.endIndex));
        
        let detailsRequest = baseURL + "/videos?key=" + youtubeAPIKey + "&id=" + requestedVideoIDs + "&part=contentDetails,statistics"
        
        let semaphore = DispatchSemaphore(value: 0);
        
        makeHTTPGetRequest(detailsRequest) { json in
            if(json.object(forKey: "items") != nil){
                var i: Int = 0;
                for item in json.object(forKey: "items") as! [Dictionary<String, Any>]{
                    //check what kind of result this is: playlist or video
                    //get video id
                    
                    let statistics = item["statistics"] as! Dictionary<String, Any>
                    let viewCount = statistics["viewCount"] as! String;
                    
                    //get the length of the video
                    let contentDetails = item["contentDetails"] as! Dictionary<String, Any>
                    let length = contentDetails["duration"] as! String
                    
                    videoList[i].views = Int(viewCount)! as NSNumber; //disgustiny
                    videoList[i].length = length;
                    
                    i=i+1;
                }
            }
            semaphore.signal()
        }
        semaphore.wait(timeout: DispatchTime.now() + timeoutLength)
        return videoList;
    }
    
    func makeHTTPGetRequest(_ path: String, completionHandler: @escaping (_ myJson: NSDictionary) -> ()){
        let request = URLRequest(url: URL(string: path)!);
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.noData }
                guard let json = try JSONSerialization.jsonObject(with: dat, options: []) as? NSDictionary else {throw JSONError.conversionFailed }
                completionHandler(json);
            }catch let error as JSONError {
                print(error.rawValue)
            }catch {
                print(error)
            }
        }.resume()
    }
}
