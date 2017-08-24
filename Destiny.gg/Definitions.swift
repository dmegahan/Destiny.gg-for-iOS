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
//Which type of videos the VODS dropdown button defaults to
let defaultVideoType: String = VideoType.Broadcast.rawValue;

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

//what twitch gives us as a date
let twitchDateFormat: String = "yyyy-MM-dd'T'HH:mm:ss'Z'";
let youtubeDateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.000'Z'"
//what we want as a date (aka readable)
let ourDateFormat: String = "dd 'of' MMMM yyyy, hh:mm a zzz";

//how to present the length of the video
//as far as I know, youtube doesnt give us the length of a video when querying the api
let lengthFormat: String = "length: %02d:%02d:%02d";

//Default values for optional queries
//Default value for optional query - limit, determines how many videos are returned to us when we query youtube or twitch through the REST API Manager
let limit: Int = 15;

//Highest possible values for the number of videos requested on various platforms
let twitchHighestLimit: Int = 100;
let youtubeHighestMaxResults: Int = 50;
