//
//  ViewController.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 1/31/16.
//  Copyright © 2016 Daniel Megahan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var myStreamWebView: UIWebView!
    @IBOutlet var myChatWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set up the gesture recognition
        
        
        //set up the stream and chat embeds
        embedStream();
        embedChat();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func embedStream(){
        let url = NSURL(string: "http://player.twitch.tv/?channel=destiny");
        let requestObj = NSURLRequest(URL: url!);
        myStreamWebView.loadRequest(requestObj);
    }
    
    func embedChat(){
        //chat embed URL
        let url = NSURL(string: "https://www.destiny.gg/embed/chat");
        let requestObj = NSURLRequest(URL: url!);
        myChatWebView.loadRequest(requestObj);
    }
}
