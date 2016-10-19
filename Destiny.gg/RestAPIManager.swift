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
    
    func isStreamOnline(_ streamer: String) -> (Bool){
        //construct REST api url
        let isOnlineURL = baseURL + "streams/" + streamer;
        var isOnline = false;
        //create semaphore so we wait for the request to finish before reporting if stream is online or not
        let semaphore = DispatchSemaphore(value: 0);

        //make the request for the stream info
        makeHTTPGetRequest(isOnlineURL) { json in
            //we have the json dict, now we get the online status and return it
            //if the stream object is null, the streamer is offline
//          //print(json["stream"]);
            print(json);
            if(json["stream"] is NSNull){
                isOnline = false;
            }else{
                isOnline = true;
            }
            semaphore.signal();
        }
        //we wait forever, should put a 30 second timer here or something
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return isOnline;
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
