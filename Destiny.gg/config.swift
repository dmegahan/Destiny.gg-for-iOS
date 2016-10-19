//
//  config.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 10/18/16.
//  Copyright © 2016 Daniel Megahan. All rights reserved.
//  
/*
    Holds our secret stuff that the Twitch API requires us to give
    Client ID and Client Secret
    To create your own Client ID and Secret, visit https://www.twitch.tv/settings/connections
    and register a new application
*/

import Foundation

class config: NSObject {
    let clientID = "YOUR CLIENT ID";
    let clientSecret = "YOUR CLIENT SECRET"
    
    func getClientID() -> String{
        return clientID;
    }
    
    func getClientSecret() -> String{
        return clientSecret;
    }
}
