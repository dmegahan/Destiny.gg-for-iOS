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
    
    /*
        We want the chat landscape frame to be on the right side of the screen, and take up relatively little space
        compared to the stream frame. Here we are setting the x origin to the screen height times 2/3. Height is used
        here because when a rotation from portrait to landscape happens (or vice versa), UIScreen still thinks its in
        portrait mode, so the height of the portrait screen ends up equaling the width of the landscape screen. And we
        multiply the height (really the width) by 2/3 because we want the origin to be on the right side of the screen.
        The Y origin remains 0. We set the width to the height (width) times 1/3, because we want the chat to fill
        the rest of the spoace on the right side. We set the height of the chat to the width (height of the portrait
        screen)
    
    */
    var chatDefaultLandscapeFrame = CGRectMake(UIScreen.mainScreen().bounds.height * (2/3), 0,
                                    UIScreen.mainScreen().bounds.height * (1/3),
                                    UIScreen.mainScreen().bounds.width);
    /*
        For the stream landscape frame, we keep the origin at (0,0) but make the width fill 2/3 of the screen, starting
        from the left
    */
    var streamDefaultLandscapeFrame = CGRectMake(0, 0,
                                        UIScreen.mainScreen().bounds.height * (2/3),
                                        UIScreen.mainScreen().bounds.width);
    
    /*
        Pretty much the same logic as above, except the height/width switch that happens doesnt apply here. 
        height = height, width = width
    */
    var chatDefaultPortraitFrame = CGRectMake(0, UIScreen.mainScreen().bounds.height * (1/3),
                                    UIScreen.mainScreen().bounds.width,
                                    UIScreen.mainScreen().bounds.height * (2/3));
    var streamDefaultPortraitFrame = CGRectMake(0, 0,
                                        UIScreen.mainScreen().bounds.width,
                                        UIScreen.mainScreen().bounds.height * (1/3));;
    
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
        
        //allow pan swipes to be recognized when panning inside a UIWebView
        [myChatWebView.scrollView.panGestureRecognizer .requireGestureRecognizerToFail(panSwipe)];
        [myStreamWebView.scrollView.panGestureRecognizer.requireGestureRecognizerToFail(panSwipe)];
        
        //embed chat whether or not stream is online
        embedChat();
        
        let streamer = "LIRIK";
        
        let streamOnline = RestAPIManager.sharedInstance.isStreamOnline(streamer);
        if(streamOnline){
            //if online, send request for stream.
            embedStream(streamer);
        }else{
            //will eventually display splash image and label that says offline
        }
        
        print("We in the ipad viewControler");
        
        //initialize default frames
        //chatDefaultFrame = myChatWebView.frame;
        //streamDefaultFrame = myStreamWebView.frame;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func embedStream(streamer: String){
        let url = NSURL(string: "http://player.twitch.tv/?channel=" + streamer);
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
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation){
        //were going to do some lazy programming here. We're going to take the web views that we have
        //and resize them based on the orientation, rather than use a different storyboard
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
            //let newChatFrame = CGRectMake(UIScreen.mainScreen().bounds.width * (2/3), myChatWebView.frame.origin.y,
            //    , UIScreen.mainScreen().bounds.height);
            //myChatWebView.frame = newChatFrame;
            
            myChatWebView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin,
                UIViewAutoresizing.FlexibleBottomMargin]
            myChatWebView.frame = chatDefaultLandscapeFrame;
            
            //max out the height so it becomes full screened
            //let newStreamFrame = CGRectMake(0, 0,
            //    UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            //myStreamWebView.frame = newStreamFrame;
            
            myStreamWebView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight,UIViewAutoresizing.FlexibleWidth,
                                                UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleBottomMargin]
            myStreamWebView.frame = streamDefaultLandscapeFrame;
        }
        else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)){
            //try putting delay on when to resize
            //set height to 0, we want it to be hidden at the start
            //self.myStreamWebView.frame = self.defaultPortraitStreamFrame;
            
            //minimize the stream web view and make the chat web view full screen
            //self.myChatWebView.frame = self.defaultPortraitChatFrame;

            //self.myStreamWebView.mediaPlaybackRequiresUserAction = false;
            //self.myChatWebView.reload();
            
            //self.myChatWebView.reload()
            //self.myStreamWebView.reload()
            
            myChatWebView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin,
                UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin]
            
            myChatWebView.frame = chatDefaultPortraitFrame;
            
            myStreamWebView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin]
            myStreamWebView.frame = streamDefaultPortraitFrame;
        }
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        print("Webview fail with error \(error)");
    }
}
