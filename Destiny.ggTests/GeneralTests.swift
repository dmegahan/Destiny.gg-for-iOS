//
//  GeneralTests.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 4/26/17.
//  Copyright © 2017 Daniel Megahan. All rights reserved.
//

import XCTest
@testable import Destiny_gg
class GeneralTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testVideoClassInitializer(){
        let title:String = "Test Title";
        let videoType:String = "Test Video";
        let previewURL:String = "destiny.gg/bigscreen";
        let length:NSNumber = 666;
        let recordedAt:String = "12/25/2017 00:00:00";
        let views:NSNumber = 667;
        let videoURL:String = "destiny.gg";
        
        let video:Video = Video(_title: title, _videoType: videoType, _previewURL: previewURL, _length: length, _recordedAt: recordedAt, _views: views, _videoURL: videoURL);
        XCTAssertEqual(title, video.title);
        XCTAssertEqual(videoType, video.videoType);
        XCTAssertEqual(previewURL, video.previewURL);
        XCTAssertEqual(length, video.length);
        XCTAssertEqual(recordedAt, video.recordedAt);
        XCTAssertEqual(views, video.views);
        XCTAssertEqual(videoURL, video.videoURL);
    }
    
    func testGetAPIKeys(){
        let configFile = Config();
        XCTAssertNotNil(configFile)
        let clientID:String = configFile.getClientID();
        let clientSecret:String = configFile.getClientSecret();
        let youtubeKey:String = configFile.getYoutubeAPIKey();
        
        XCTAssertNotNil(clientID);
        XCTAssertNotNil(clientSecret);
        XCTAssertNotNil(youtubeKey);
    }
    
}
