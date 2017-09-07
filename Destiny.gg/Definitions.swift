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
    //twitch vid types
    case Highlight = "Highlight"
    case Broadcast = "Broadcast"
    //archive is a "special" vid type, these are the broadcasts but for some reason twitch sets the vid type to archive when we request it
    case Archive = "Archive"
}

enum Setting: String {
    case VODs = "VODs"
    case Lock = "Lock Frames"
    case UnlockFrames = "Unlock Frames"
    case TwitchChat = "Twitch Chat"
    case DggChat = "D.gg Chat"
}
//list of settings available in the settings dropd down in View Controller
let settings: [String] = [Setting.VODs.rawValue, Setting.Lock.rawValue, Setting.TwitchChat.rawValue];

//Which type of videos the VODS dropdown button defaults to
let defaultVideoType: String = VideoType.Youtube.rawValue;

//destinys usernames acroess various platforms
let destinyTwitchName: String = "destiny";
let destinyYoutubeName: String = "destiny";
//--

let destinyChatURL: String = "https://www.destiny.gg/embed/chat";
let destinyTwitchChatURL: String = "https://www.twitch.tv/destiny/chat?no-mobile-redirect=true";

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

//label for the switch chats button
let switchToTwitchLabel: String = "Twitch Chat";
let switchToDGGLabel: String = "d.gg Chat";

//row heights for landscape and portrait on Iphone
let rowHeightPortraitIphone: Int = 475;
let rowHeightLandscapeIphone: Int = 325;
