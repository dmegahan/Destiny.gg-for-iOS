//
//  Definitions.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 4/28/17.
//  Copyright © 2017 Daniel Megahan. All rights reserved.
//

//Not really sure what to call this file, but this will contain the magic strings and numbers
//we use throughout the program, as enumerations or other types. Because we are
//processing data through a number of different swift files, it is important to have 
//magic stuff in one file so changes can easily occur if needed
import Foundation

enum VideoType: String {
    case Youtube = "Youtube"
    case Highlight = "Highlight"
    case Broadcast = "Broadcast"
}

//destinys usernames acroess various platforms
let destinyTwitchName: String = "destiny";
let destinyYoutubeName: String = "destiny";
//--

let destinyChatURL: String = "https://www.destiny.gg/embed/chat";

let twitchChannelPrefix: String = "http://player.twitch.tv/?channel=";
let twitchVideoPlayerPrefix: String = "https://player.twitch.tv/?video=v";

let youtubeVideoPlayerPrefix: String = "https://www.youtube.com/embed/";

//how google describes the kind of result we get from their API
let kindVideo = "youtube#video"
let kindPlaylist = "youtube#playlist"

//How long we wait until timeout for our RestAPIManager calls
let timeoutLength: Double = 30;
