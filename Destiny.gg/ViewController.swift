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
    
    //startPanLocation keeps track of where the pan started
    var startPanLocation = CGPoint();
    //these will be used to find the difference between start and 
    //current pan locations, and modify the chat/stream boxes accordingly
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set up the gesture recognition
        /*
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "OnSwipeGesture:");
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right;
        self.view.addGestureRecognizer(swipeRight);
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "OnSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left;
        self.view.addGestureRecognizer(swipeLeft);
        */
        let panSwipe = UIPanGestureRecognizer(target: self, action: "OnPanSwipe:");
        self.view.addGestureRecognizer(panSwipe);
        
        let streamOnline = RestAPIManager.sharedInstance.isStreamOnline("destiny");
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
    /*
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
    */
    func OnPanSwipe(gesture: UIPanGestureRecognizer){
        if (gesture.state == UIGestureRecognizerState.Began){
            startPanLocation = gesture.translationInView(self.view);
        }else if (gesture.state == UIGestureRecognizerState.Changed){
            let currentPanLocation = gesture.translationInView(self.view)
            let distanceX = currentPanLocation.x - startPanLocation.x;
            
            //once we have the moved distance, we edit the frames (cant edit width directly, need to create a new frame)
            let newChatFrame = CGRectMake(myChatWebView.frame.origin.x + distanceX, myChatWebView.frame.origin.y,
                myChatWebView.frame.width - distanceX, myChatWebView.frame.height)
            //we do a check to determine if the chat will go offstream (too far to the left). If it will, we don't move it anymore
            //also dont move it if the chat is going offscreen to the right. Stop the origin.x at the bounds of screen
            if(myChatWebView.frame.origin.x + distanceX >= 1 &&
                myChatWebView.frame.origin.x + distanceX <= UIScreen.mainScreen().bounds.width){
                myChatWebView.frame = newChatFrame;
            }
            
            let newStreamFrame = CGRectMake(myStreamWebView.frame.origin.x, myStreamWebView.frame.origin.y,
                myStreamWebView.frame.width + distanceX, myStreamWebView.frame.height)
            //no point in panning the stream if the width + distanceX is smaller than 0 or if the stream > the width of the screen
            if(myStreamWebView.frame.width + distanceX > -1 &&
                myStreamWebView.frame.width + distanceX <= UIScreen.mainScreen().bounds.width){
                myStreamWebView.frame = newStreamFrame;
            }
            startPanLocation = currentPanLocation;
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        print("Webview fail with error \(error)");
    }
}
