//
//  Destiny_ggTests.swift
//  Destiny.ggTests
//
//  Created by Daniel Megahan on 1/31/16.
//  Copyright © 2016 Daniel Megahan. All rights reserved.
//

import XCTest
@testable import Destiny_gg

class APIManagerTests: XCTestCase {
    
    let testStreamer:String = "destiny"
    let twitchAPIBaseURL = RestAPIManager.sharedInstance.baseURL;
    let twitchAPIClientID = RestAPIManager.sharedInstance.clientID;
    let youtubeAPIKey = RestAPIManager.sharedInstance.youtubeAPIKey;
        
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //API Tests
    //Twitch API
    func testValidClientID(){
        let clientIDQueryString = "?client_id=" + twitchAPIClientID;
        //construct the query and test if the query returns a valid result (AKA not null or bad query)
        let isOnlineURL = twitchAPIBaseURL + "streams/" + testStreamer + clientIDQueryString;

        let semaphore = DispatchSemaphore(value: 0);
        
        RestAPIManager.sharedInstance.makeHTTPGetRequest(isOnlineURL) { json in
            XCTAssertNil(json.object(forKey: "error"))
            semaphore.signal();
        }
        //we wait forever, should put a 30 second timer here or something
        semaphore.wait(timeout: DispatchTime.now() + timeoutLength)
    }
    
    func testIsStreamOnlineValidReturn(){
        let isOnlineResult:Bool = RestAPIManager.sharedInstance.isStreamOnline(testStreamer);
        XCTAssert(isOnlineResult == true || isOnlineResult == false);
    }
    
    func testDoesStreamExistValidReturn(){
        let doesStreamExist:Bool = RestAPIManager.sharedInstance.doesStreamExist(testStreamer);
        XCTAssert(doesStreamExist == true || doesStreamExist == false);
    }
    
    func testGetTwitchHighlightsValidJSON(){
        let clientIDQueryString = "?client_id=" + twitchAPIClientID;
        
        let channelVideosURL = twitchAPIBaseURL + "channels/" + testStreamer + "/" + "videos" + clientIDQueryString;
        
        print (channelVideosURL)
        
        let semaphore = DispatchSemaphore(value: 0);
        RestAPIManager.sharedInstance.makeHTTPGetRequest(channelVideosURL) { json in
            //assert that no error occured
            XCTAssert(json.object(forKey: "error") == nil);
            //assert that there is a valid videos object
            XCTAssertNotNil(json.object(forKey: "videos"));
            if(json.object(forKey: "videos") != nil){
                for video in json.object(forKey: "videos") as! [Dictionary<String, AnyObject>] {
                    //verify that every returned video has valid properties
                    XCTAssertNotNil(video["title"]);
                    XCTAssertNotNil(video["broadcast_type"]);
                    XCTAssertNotNil(video["preview"]);
                    //check if video["length"] is a valid number
                    XCTAssertNotNil(video["length"] as! NSNumber);
                    XCTAssertNotNil(video["recorded_at"]);
                    XCTAssertNotNil(video["views"]);
                    XCTAssertNotNil(video["views"] as! NSNumber);
                    XCTAssertNotNil(video["url"]);
                }
            }
            semaphore.signal();
        }
        semaphore.wait(timeout: DispatchTime.now() + timeoutLength);
    }
    
    func testGetTwitchBroadcastsValidJSON(){
        let clientIDQueryString = "?client_id=" + twitchAPIClientID;
        
        let channelVideosURL = twitchAPIBaseURL + "channels/" + testStreamer + "/" + "videos" + clientIDQueryString + "&broadcasts=true";
        
        print (channelVideosURL)
        
        let semaphore = DispatchSemaphore(value: 0);
        RestAPIManager.sharedInstance.makeHTTPGetRequest(channelVideosURL) { json in
            //assert that no error occured
            XCTAssert(json.object(forKey: "error") == nil);
            //assert that there is a valid videos object
            XCTAssertNotNil(json.object(forKey: "videos"));
            if(json.object(forKey: "videos") != nil){
                for video in json.object(forKey: "videos") as! [Dictionary<String, AnyObject>] {
                    //verify that every returned video has valid properties
                    XCTAssertNotNil(video["title"]);
                    XCTAssertNotNil(video["broadcast_type"]);
                    XCTAssertNotNil(video["preview"]);
                    XCTAssertNotNil(video["length"]);
                    //check if video["length"] is a valid number
                    XCTAssertNotNil(video["length"] as! NSNumber);
                    XCTAssertNotNil(video["recorded_at"]);
                    XCTAssertNotNil(video["views"]);
                    XCTAssertNotNil(video["views"] as! NSNumber);
                    XCTAssertNotNil(video["url"]);
                }
            }
            semaphore.signal();
        }
        semaphore.wait(timeout: DispatchTime.now() + timeoutLength);
    }
    
    func testValidYoutubeAPIKey(){
        let baseURL = "https://www.googleapis.com/youtube/v3"
        let channel = "destiny"
        //get the channel object
        let channelRequest = baseURL + "/channels?part=contentDetails&forUsername=" + channel + "&key=" + youtubeAPIKey
        
        RestAPIManager.sharedInstance.makeHTTPGetRequest(channelRequest) { json in
            XCTAssertNil(json.object(forKey:"error"));
        }
    }
    
    func testGetYoutubeChannelIDValidJSON(){
        let baseURL = "https://www.googleapis.com/youtube/v3"
        let channel = "destiny"
        //get the channel object
        let channelRequest = baseURL + "/channels?part=contentDetails&forUsername=" + channel + "&key=" + youtubeAPIKey
        
        let semaphore = DispatchSemaphore(value: 0);
        //validate that we can read and process the json structure correctly. If the structure changes
        //on googles end, this test will not pass
        RestAPIManager.sharedInstance.makeHTTPGetRequest(channelRequest) { json in
            XCTAssertNotNil(json.object(forKey:"items"));
            if(json.object(forKey: "items") != nil){
                let items = json.object(forKey: "items") as! Array<Dictionary<String, Any>>
                let item = items[0] as Dictionary<String, Any>?;
                XCTAssert(item != nil);
                XCTAssert(item?["id"] != nil);
            }
            semaphore.signal()
        }
        semaphore.wait(timeout: DispatchTime.now() + timeoutLength)
    }
    
    func testGetYoutubeVideoListValidJSON(){
        let baseURL = "https://www.googleapis.com/youtube/v3"
        
        //get list of most recent videos
        //destiny channel ID
        let channelID: String = "UC554eY5jNUfDq3yDOJYirOQ";
        
        let playlistRequest = baseURL + "/search?key=" + youtubeAPIKey + "&channelId=" + channelID + "&part=snippet&order=date&maxResults=20"
        let semaphore = DispatchSemaphore(value: 0);
        RestAPIManager.sharedInstance.makeHTTPGetRequest(playlistRequest) { json in
            //validate that our JSON structure hasnt changed.
            XCTAssertNotNil(json.object(forKey:"items"));
            if(json.object(forKey: "items") != nil){
                for item in json.object(forKey: "items") as! [Dictionary<String, Any>]{
                    //get video id
                    XCTAssertNotNil(item["id"]);
                    let id = item["id"] as! Dictionary<String, Any>
                    XCTAssertNotNil(id["kind"]);
                    let resultType = id["kind"] as! String
                    if (resultType == kindVideo){
                        XCTAssertNotNil(id["videoId"], playlistRequest);
                    
                        XCTAssertNotNil(item["snippet"]);
                        let snippet = item["snippet"] as! Dictionary<String, Any>
                    
                        XCTAssertNotNil(snippet["title"]);
                        XCTAssertNotNil(snippet["publishedAt"]);

                        //enter a nested json - get preview image
                        XCTAssertNotNil(snippet["thumbnails"]);
                        let thumbnails = snippet["thumbnails"] as! Dictionary<String, Any>
                        XCTAssertNotNil(thumbnails["default"]);
                        let defaultThumbnail = thumbnails["default"] as! Dictionary<String, Any>
                        XCTAssertNotNil(defaultThumbnail["url"]);
                    }
                }
            }
            semaphore.signal()
        }
        semaphore.wait(timeout: DispatchTime.now() + timeoutLength)
    }
}
