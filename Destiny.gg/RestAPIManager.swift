//
//  RestAPIManager.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 2/3/16.
//  Copyright © 2016 Daniel Megahan. All rights reserved.
//

import Foundation

enum JSONError: String, Error {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
}

class RestAPIManager: NSObject {
    static let sharedInstance = RestAPIManager();
    let baseURL = "https://api.twitch.tv/kraken/";
    
    let clientID = config().getClientID()
    
    func isStreamOnline(_ streamer: String) -> (Bool){
        //construct REST api url
        let clientIDQueryString = "?client_id=" + clientID;
        
        let isOnlineURL = baseURL + "streams/" + streamer + clientIDQueryString;
        var isOnline = false;
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
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return isOnline;
    }
    
    func doesStreamExist(_ streamer: String) -> (Bool){
        //construct REST api url
        let clientIDQueryString = "?client_id=" + clientID;
        
        let isOnlineURL = baseURL + "streams/" + streamer + clientIDQueryString;
        var doesExist = false;
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
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return doesExist;
    }
    
    func makeHTTPGetRequest(_ path: String, completionHandler: @escaping (_ myJson: NSDictionary) -> ()){
        let request = URLRequest(url: URL(string: path)!);
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try JSONSerialization.jsonObject(with: dat, options: []) as? NSDictionary else {throw JSONError.ConversionFailed }
                completionHandler(json);
            }catch let error as JSONError {
                print(error.rawValue)
            }catch {
                print(error)
            }
        }.resume()
    }
}
