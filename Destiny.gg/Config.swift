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

class Config: NSObject {
    let clientID = "YOUR CLIENTID HERE";
    let clientSecret = "YOUR CLIENT SECRET HERE"
    
    func getClientID() -> String{
        return clientID;
    }
    
    func getClientSecret() -> String{
        return clientSecret;
    }
}