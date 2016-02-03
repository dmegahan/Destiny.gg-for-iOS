//
//  RestAPIManager.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 2/3/16.
//  Copyright © 2016 Daniel Megahan. All rights reserved.
//

import Foundation

enum JSONError: String, ErrorType {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
}

class RestAPIManager: NSObject {
    //for now, this object will only be used to get destiny's stream information
    static let sharedInstance = RestAPIManager();
    let baseURL = "https://api.twitch.tv/kraken/";
    
    
    func isStreamOnline(streamer: String) -> (Bool){
        //construct REST api url
        let isOnlineURL = baseURL + "streams/" + streamer;
        var isOnline = false;
        //create semaphore so we wait for the request to finish before reporting if stream is online or not
        var semaphore = dispatch_semaphore_create(0);

        //make the request for the stream info
        makeHTTPGetRequest(isOnlineURL) { json in
            //we have the json dict, now we get the online status and return it
            //if the stream object is null, the streamer is offline
            print(json["stream"]);
            if(json["stream"] is NSNull){
                isOnline = false;
            }else{
                isOnline = true;
            }
            dispatch_semaphore_signal(semaphore);
        }
        //we wait forever, should put a 30 second timer here or something
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return isOnline;
    }
    
    func makeHTTPGetRequest(path: String, completionHandler: (myJson: NSDictionary) -> ()){
        let request = NSMutableURLRequest(URL: NSURL(string: path)!);
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else {throw JSONError.ConversionFailed }
                completionHandler(myJson: json);
            }catch let error as JSONError {
                print(error.rawValue)
            }catch {
                print(error)
            }
        }.resume()
    }
}