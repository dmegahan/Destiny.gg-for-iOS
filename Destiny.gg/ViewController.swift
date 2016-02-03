//
//  ViewController.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 1/31/16.
//  Copyright © 2016 Daniel Megahan. All rights reserved.
//

import UIKit

//inherit from UIWebViewDelegate so we can track when the webviews have loaded/not loaded
class ViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var myStreamWebView: UIWebView!
    @IBOutlet var myChatWebView: UIWebView!
    
    var chatDefaultFrame = CGRectNull;
    var streamDefaultFrame = CGRectNull;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set up the gesture recognition
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "OnSwipeGesture:");
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right;
        self.view.addGestureRecognizer(swipeRight);
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "OnSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left;
        self.view.addGestureRecognizer(swipeLeft);
        
        var streamOnline = RestAPIManager.sharedInstance.isStreamOnline("destiny");
        print (streamOnline);
        if(streamOnline){
            //if online, send request for stream.
            embedStream();
        }else{
            //will eventually display splash image and label that says offline
        }
        //embed chat whether or not stream is online
        embedChat();
        
        //initialize default frames
        chatDefaultFrame = myChatWebView.frame;
        streamDefaultFrame = myStreamWebView.frame;
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
    
    //when a swipe is detected, resize the webviews depending on direction
    func OnSwipeGesture(gesture: UIGestureRecognizer)
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction{
                case UISwipeGestureRecognizerDirection.Right:
                    //resize the chat web view
                    //the new frame has a width of 0, everything else stays the same
                    let newFrame = CGRectMake(chatDefaultFrame.origin.x, chatDefaultFrame.origin.y, 0, chatDefaultFrame.size.height);
                    myChatWebView.frame = newFrame;
                    //fill the empty space left by the chat web view
                    //change the width to match the width of the original frame + the default frame width of the chat
                    let newStreamFrame = CGRectMake(streamDefaultFrame.origin.x, streamDefaultFrame.origin.y, streamDefaultFrame.size.width + chatDefaultFrame.size.width, streamDefaultFrame.size.height);
                    myStreamWebView.frame = newStreamFrame;
                case UISwipeGestureRecognizerDirection.Left:
                    //set the web view frames back to the defaults
                    myChatWebView.frame = chatDefaultFrame;
                    myStreamWebView.frame = streamDefaultFrame;
                default:
                    break;
            }
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        print("Webview fail with error \(error)");
    }
}
