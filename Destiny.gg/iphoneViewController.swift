//
//  ViewController.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 1/31/16.
//  Copyright © 2016 Daniel Megahan. All rights reserved.
//

import UIKit
import WebKit
//inherit from UIWebViewDelegate so we can track when the webviews have loaded/not loaded
class iphoneViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet var myChatWebView: WKWebView!
    @IBOutlet var myStreamWebView: UIWebView!
    
    //When a double tap gesture is done, this will be used to determine how we should change the chat and stream frames
    var isChatFullScreen = true;
    
    var defaultPortraitChatFrame = CGRect.null;
    var defaultPortraitStreamFrame = CGRect.null;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //set up the gesture recognition
        /*
            these aren't currently being used, but we might want ot use them later
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "OnSwipeGesture:");
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down;
        self.view.addGestureRecognizer(swipeDown);
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "OnSwipeGesture:")
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up;
        self.view.addGestureRecognizer(swipeUp);
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "OnDoubleTapGesture:");
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 2;
        view.addGestureRecognizer(doubleTap);
        */
        //let panSwipe = UIPanGestureRecognizer(target: self, action: "OnPanSwipe:");
        //self.view.addGestureRecognizer(panSwipe);
        
        let streamer = "destiny";
        
        //let streamOnline = RestAPIManager.sharedInstance.isStreamOnline(streamer);
    
        
        self.defaultPortraitChatFrame = self.myChatWebView.frame;
        self.defaultPortraitStreamFrame = self.myStreamWebView.frame;
        
        /*
        if(streamOnline){
            //if online, send request for stream.
            embedStream(streamer);
        }else{
            embedStream(streamer);
            //will eventually display splash image and label that says offline
        }
 */
        //embed chat whether or not stream is online
        embedChat();
        
        print("We in iphone view control");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func embedStream(_ streamer : String){
        let url = URL(string: "http://player.twitch.tv/?channel=" + streamer);
        let requestObj = URLRequest(url: url!);
        myStreamWebView.loadRequest(requestObj);
        
        self.myStreamWebView.allowsInlineMediaPlayback = true;
        //attempt at figuring out inline media playback, apparently just turning the above to true doesnt work
        //let embeddedHTML = "<video width=\"640\" height=\"360\" id=\"player1\" preload=\"none\" webkit-playsinline><source type=\"video/youtube\" src=\"" + url + "\" /></video>";
        //self.myStreamWebView.loadHTMLString(embeddedHTML, baseURL: NSBundle.mainBundle().bundleURL);
    }
    
    func embedChat(){
        //chat embed URL
        let url = URL(string: "https://www.destiny.gg/embed/chat");
        let requestObj = URLRequest(url: url!);
        let connectionObj = NSURLConnection(request: requestObj, delegate: self)!
        myChatWebView.load(requestObj);
    }
    
    /*
    func OnDoubleTapGesture(gesture: UIGestureRecognizer)
    {
        print("double tap");
        if let doubleTapGesture = gesture as? UITapGestureRecognizer{
            if(!isChatFullScreen){
                //In both portait mode and landscape mode, an up swipe will full screen the caht
                //when we get an upward swipe, we want to fullscreen the chat
                //to do this, we move the origin.y up to 0 and change the height to match the screen height
                let newChatFrame = CGRectMake(myChatWebView.frame.origin.x, 0,
                    myChatWebView.frame.width, UIScreen.mainScreen().bounds.height);
                myChatWebView.frame = newChatFrame;
                //change the height of the stream to 0 so it doesnt appear anymore
                let newStreamFrame = CGRectMake(myStreamWebView.frame.origin.x, myStreamWebView.frame.origin.y,
                    myStreamWebView.frame.width, 0);
                myStreamWebView.frame = newStreamFrame;
            }else if(isChatFullScreen){
                //down swipes have a different function depending on the orientation
                if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                    //a down swipe in landscape mode will full screen the stream
                    //to do this, we need to adjust the chat origin back to the original, which is
                    //at the bottom of the screen (so we set origin.y to the height of the screen) and make the height of the frame to 0
                    let newChatFrame = CGRectMake(myChatWebView.frame.origin.x, UIScreen.mainScreen().bounds.height,
                        myChatWebView.frame.width, 0);
                    myChatWebView.frame = newChatFrame;
                    //full screen the stream, set origin to 0 and height to size of screen
                    let newStreamFrame = CGRectMake(myStreamWebView.frame.origin.x, 0,
                        myStreamWebView.frame.width, UIScreen.mainScreen().bounds.height);
                    myStreamWebView.frame = newStreamFrame;
                }else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)){
                    //this may change later, but a double tap in portrait mode, with the chat full screened,
                    //will cause the stream to take up half the window. So we're going to change the origin.y to halfway
                    //down the screen for the chat and halve the hieght as well
                    let newChatFrame = CGRectMake(myChatWebView.frame.origin.x, UIScreen.mainScreen().bounds.height/2,
                        myChatWebView.bounds.width, UIScreen.mainScreen().bounds.height/2);
                    myChatWebView.frame = newChatFrame;
                    
                    //stream origin.y stays at 0 but we change the height to half the screen
                    let newStreamFrame = CGRectMake(myStreamWebView.frame.origin.x, myStreamWebView.frame.origin.y,
                        myStreamWebView.frame.width, UIScreen.mainScreen().bounds.height/2)
                    myStreamWebView.frame = newStreamFrame;
                }
            }
        }
    }
    //when a swipe is detected, resize the webviews depending on direction
    
    func OnSwipeGesture(gesture: UIGestureRecognizer)
    {
        print("swipe detected");
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction{
                case UISwipeGestureRecognizerDirection.Up:
                    //In both portait mode and landscape mode, an up swipe will full screen the caht
                    //when we get an upward swipe, we want to fullscreen the chat
                    //to do this, we move the origin.x up to 0 and change the height to match the screen height
                    let newChatFrame = CGRectMake(0, myChatWebView.frame.origin.y,
                            myChatWebView.frame.width, UIScreen.mainScreen().bounds.height);
                    myChatWebView.frame = newChatFrame;
                    //change the height of the stream to 0 so it doesnt appear anymore
                    let newStreamFrame = CGRectMake(myStreamWebView.frame.origin.x, myStreamWebView.frame.origin.y,
                            myStreamWebView.frame.width, 0);
                    myStreamWebView.frame = newStreamFrame;
                case UISwipeGestureRecognizerDirection.Down:
                    //down swipes have a different function depending on the orientation
                    if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                        //a down swipe in landscape mode will full screen the stream
                        //to do this, we need to adjust the chat origin back to the original, which is 
                        //at the bottom of the screen (so we set origin.x to the height of the screen) and make the height of the frame to 0
                        let newChatFrame = CGRectMake(UIScreen.mainScreen().bounds.height, myChatWebView.frame.origin.y,
                            myChatWebView.frame.width, 0);
                        myChatWebView.frame = newChatFrame;
                        //full screen the stream, set origin to 0 and height to size of screen
                        let newStreamFrame = CGRectMake(0, myStreamWebView.frame.origin.y,
                            myStreamWebView.frame.width, UIScreen.mainScreen().bounds.height);
                        myStreamWebView.frame = newStreamFrame;
                    }
                    myChatWebView.frame = chatDefaultFrame;
                    myStreamWebView.frame = streamDefaultFrame;
                default:
                    break;
            }
        }
    }
    func OnPanSwipe(gesture: UIPanGestureRecognizer){
        if (gesture.state == UIGestureRecognizerState.Began){
            startPanLocation = gesture.translationInView(self.view);
        }else if (gesture.state == UIGestureRecognizerState.Changed){
            let currentPanLocation = gesture.translationInView(self.view)
            let distanceY = currentPanLocation.y - startPanLocation.y;
            
            let newChatFrame = CGRectMake(myChatWebView.frame.origin.x, myChatWebView.frame.origin.y + distanceY,
                myChatWebView.frame.width, myChatWebView.frame.height - distanceY)
            
            //we do a check to determine if the chat will go offscreen (too far up or down). If it will, we don't move it anymore
            if(myChatWebView.frame.origin.y + distanceY >= 1 &&
                myChatWebView.frame.origin.y + distanceY <= UIScreen.mainScreen().bounds.height){
                myChatWebView.frame = newChatFrame;
            }
            
            let newStreamFrame = CGRectMake(myStreamWebView.frame.origin.x, myStreamWebView.frame.origin.y,
                myStreamWebView.frame.width + distanceY, myStreamWebView.frame.height)
            //no point in panning the stream if the width + distanceX is smaller than 0 or if the stream > the width of the screen
            if(myStreamWebView.frame.width + distanceY > -1 &&
                myStreamWebView.frame.width + distanceY <= UIScreen.mainScreen().bounds.width){
                myStreamWebView.frame = newStreamFrame;
            }
            startPanLocation = currentPanLocation;
        }
    }
    */
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation){
        //were going to do some lazy programming here. We're going to take the web views that we have 
        //and resize them based on the orientation, rather than use a different storyboard
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
            //minimize the chat web view and make the stream web view full screen
            //new chat frame will have a height of 0, and a width to match the screen size (so we can bring it up using
            //a swipe easily if we want to)
            //We also construct a new origin.y, so the chat frame is at the bottom of the screen, instead of at the top
            let newChatFrame = CGRect(x: myChatWebView.frame.origin.x, y: myChatWebView.frame.origin.y + UIScreen.main.bounds.height,
                width: UIScreen.main.bounds.width, height: 0);
            myChatWebView.frame = newChatFrame;
            
            //max out the height so it becomes full screened
            let newStreamFrame = CGRect(x: 0, y: 0,
                width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            myStreamWebView.frame = newStreamFrame;
            
            isChatFullScreen = false;
            //unhide it if it is hidden
            myStreamWebView.isHidden = false;
        }
        else if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
            print("portraitmode");
            //try putting delay on when to resize
            //set height to 0, we want it to be hidden at the start
            self.myStreamWebView.frame = self.defaultPortraitStreamFrame;
                
            //minimize the stream web view and make the chat web view full screen
            self.myChatWebView.frame = self.defaultPortraitChatFrame;
                
            self.isChatFullScreen = true;
            //self.myStreamWebView.mediaPlaybackRequiresUserAction = false;
            //self.myChatWebView.reload();
            
            //self.myChatWebView.reload()
            //self.myStreamWebView.reload()
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        print("Webview fail with error \(error)");
    }
}
