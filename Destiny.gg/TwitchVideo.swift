//
//  TwitchVideo.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 1/2/17.
//  Copyright © 2017 Daniel Megahan. All rights reserved.
//

import Foundation

class TwitchVideo {
    var title: String;
    var videoType: String; //highlight or VOD
    var previewURL: String;
    var length: NSNumber;
    var recordedAt: String;
    var views: NSNumber;
    
    init(_title:String, _videoType:String, _previewURL:String, _length:NSNumber,
         _recordedAt:String, _views:NSNumber) {
        title = _title;
        videoType = _videoType;
        previewURL = _previewURL;
        length = _length;
        recordedAt = _recordedAt;
        views = _views;
    }
}
