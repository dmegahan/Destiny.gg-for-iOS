//
//  ViewController.swift
//  Destiny.gg
//  ViewController for Ipad storyboard (Main.storyboard)
//
//  Created by Daniel Megahan on 1/31/16.
//  Copyright © 2016 Daniel Megahan. All rights reserved.
//

import UIKit

//inherit from UIWebViewDelegate so we can track when the webviews have loaded/not loaded
class ViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var myStreamWebView: UIWebView!
    @IBOutlet var myChatWebView: UIWebView!
    @IBOutlet var myToolBar: UIToolbar!
    @IBOutlet var ChangeStreamButton: UIBarButtonItem!
    @IBOutlet var LockFramesButton: UIBarButtonItem!
    
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
    var chatDefaultLandscapeFrame = CGRect(x: UIScreen.main.bounds.height * (2/3), y: 0,
                                    width: UIScreen.main.bounds.height * (1/3),
                                    height: UIScreen.main.bounds.width);
    /*
        For the stream landscape frame, we keep the origin at (0,0) but make the width fill 2/3 of the screen, starting
        from the left
    */
    var streamDefaultLandscapeFrame = CGRect(x: 0, y: 0,
                                        width: UIScreen.main.bounds.height * (2/3),
                                        height: UIScreen.main.bounds.width);
    
    /*
        Pretty much the same logic as above, except the height/width switch that happens doesnt apply here. 
        height = height, width = width
    */
    var chatDefaultPortraitFrame = CGRect(x: 0, y: UIScreen.main.bounds.height * (1/3),
                                            width: UIScreen.main.bounds.width,
                                            height: UIScreen.main.bounds.height * (2/3));
    var streamDefaultPortraitFrame = CGRect(x: 0, y: 0,
                                        width: UIScreen.main.bounds.width,
                                        height: UIScreen.main.bounds.height * (1/3));;
    
    //variables (intialized in initializeCurrentFrames) for saving frame layout after a user pans the frames
    var chatCurrentLandscapeFrame = CGRect();
    var streamCurrentLandscapeFrame = CGRect();
    
    var chatCurrentPortraitFrame = CGRect();
    var streamCurrentPortraitFrame = CGRect();
    
    //startPanLocation keeps track of where the pan started
    var startPanLocation = CGPoint();
    //these will be used to find the difference between start and 
    //current pan locations, and modify the chat/stream boxes accordingly
    
    //keeps track of whether the frame (The chat frame and stream frame) should be locked
    //in their current position
    var isLocked = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let panSwipe = UIPanGestureRecognizer(target: self, action: #selector(ViewController.OnPanSwipe(_:)));
        self.view.addGestureRecognizer(panSwipe);
        
        //allow pan swipes to be recognized when panning inside a UIWebView
        myChatWebView.scrollView.panGestureRecognizer .require(toFail: panSwipe);
        myStreamWebView.scrollView.panGestureRecognizer.require(toFail: panSwipe);
        
        initializeCurrentFrames();
        
        //embed chat whether or not stream is online
        embedChat();
        
        let streamer = "Destiny";
        
        let streamOnline = RestAPIManager.sharedInstance.isStreamOnline(streamer);
        if(streamOnline){
            //if online, send request for stream.
            embedStream(streamer);
        }else{
            //will eventually display splash image and label that says offline
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func embedStream(_ streamer: String){
        let url = URL(string: "http://player.twitch.tv/?channel=" + streamer);
        let requestObj = URLRequest(url: url!);
        myStreamWebView.loadRequest(requestObj);
    }
    
    func embedChat(){
        //chat embed URL
        let url = URL(string: "https://www.destiny.gg/embed/chat");
        let requestObj = URLRequest(url: url!);
        myChatWebView.loadRequest(requestObj);
    }
    
    func initializeCurrentFrames(){
        //initialize the current frames for stream and chat
        //variables for saving your frame layout when you switch between portrait and landscape mode;
        chatCurrentLandscapeFrame = chatDefaultLandscapeFrame;
        streamCurrentLandscapeFrame = streamDefaultLandscapeFrame;
        
        chatCurrentPortraitFrame = chatDefaultPortraitFrame;
        streamCurrentPortraitFrame = streamDefaultPortraitFrame;
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
    func OnPanSwipe(_ gesture: UIPanGestureRecognizer){
        if (gesture.state == UIGestureRecognizerState.began){
            //initialize our start location - this is where teh user first started panning from (finger location)
            startPanLocation = gesture.translation(in: self.view);
        }else if (gesture.state == UIGestureRecognizerState.changed){
            if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
            
                let currentPanLocation = gesture.translation(in: self.view)
                //We ceil distanceX (and some properties in the below chat frame creation) to avoid the frames getting out of sync with each other
                //in terms of length and origins. Fixes a bug where a black space was being created because they frames weren't matching up
                //correctly
                let distanceX = ceil(currentPanLocation.x - startPanLocation.x);
            
                //once we have the moved distance, we edit the frames (cant edit width directly, need to create a new frame)
                let newChatFrame = CGRect(x: ceil(myChatWebView.frame.origin.x + distanceX), y: myChatWebView.frame.origin.y,
                width: ceil(myChatWebView.frame.width - distanceX), height: myChatWebView.frame.height)
                //we do a check to determine if the chat will go offstream (too far to the left). If it will, we don't move it anymore
                //also dont move it if the chat is going offscreen to the right. Stop the origin.x at the bounds of screen
                if(myChatWebView.frame.origin.x + distanceX >= 0 &&
                    myChatWebView.frame.origin.x + distanceX <= UIScreen.main.bounds.width){
                        myChatWebView.frame = newChatFrame;
                }
            
                let newStreamFrame = CGRect(x: myStreamWebView.frame.origin.x, y: myStreamWebView.frame.origin.y,
                    width: ceil(myStreamWebView.frame.width + distanceX), height: myStreamWebView.frame.height)
                //no point in panning the stream if the width + distanceX is smaller than 0 or if the stream > the width of the screen
                if(myStreamWebView.frame.width + distanceX >= 0 &&
                    myStreamWebView.frame.width + distanceX <= UIScreen.main.bounds.width){
                        myStreamWebView.frame = newStreamFrame;
                }
                startPanLocation = currentPanLocation;
            }else if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
                let currentPanLocation = gesture.translation(in: self.view)
                let distanceY = currentPanLocation.y - startPanLocation.y
                
                //once we have the moved distance, we edit the frames (cant edit width directly, need to create a new frame)
                let newChatFrame = CGRect(x: myChatWebView.frame.origin.x, y: ceil(myChatWebView.frame.origin.y + distanceY),
                    width: myChatWebView.frame.width, height: ceil(myChatWebView.frame.height - distanceY))
                //we do a check to determine if the chat will go offstream (too far to the left). If it will, we don't move it anymore
                //also dont move it if the chat is going offscreen to the right. Stop the origin.x at the bounds of screen
                if(myChatWebView.frame.origin.y + distanceY >= 0 &&
                    myChatWebView.frame.origin.y + distanceY <= UIScreen.main.bounds.width){
                        myChatWebView.frame = newChatFrame;
                }
                
                let newStreamFrame = CGRect(x: myStreamWebView.frame.origin.x, y: myStreamWebView.frame.origin.y,
                    width: myStreamWebView.frame.width, height: ceil(myStreamWebView.frame.height + distanceY))
                //no point in panning the stream if the width + distanceX is smaller than 0 or if the stream > the width of the screen
                if(myStreamWebView.frame.height + distanceY >= 0 &&
                    myStreamWebView.frame.height + distanceY <= UIScreen.main.bounds.width){
                        myStreamWebView.frame = newStreamFrame;
                }
                startPanLocation = currentPanLocation;
            }
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation){
        //were going to do some lazy programming here. We're going to take the web views that we have
        //and resize them based on the orientation, rather than use a different storyboard
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
            
            
            //myChatWebView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin,
            //    UIViewAutoresizing.FlexibleBottomMargin]
            myChatWebView.frame = chatDefaultLandscapeFrame;
            

            //myStreamWebView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight,UIViewAutoresizing.FlexibleWidth,
            //                                    UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleBottomMargin]
            myStreamWebView.frame = streamDefaultLandscapeFrame;
        }
        else if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
            //myChatWebView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin,
              //  UIViewAutoresizing.FlexibleBottomMargin, UIView	Autoresizing.FlexibleLeftMargin]
            
            myChatWebView.frame = chatDefaultPortraitFrame;
            
            //myStreamWebView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin]
            myStreamWebView.frame = streamDefaultPortraitFrame;
        }
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        print("Webview fail with error \(error)");
    }
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0: //ChangeStream button
            print("Change stream pressed");
        case 1: //LockFrames button
            print("Lock frames pressed");
            isLocked = !isLocked;
        default:
            print("Default invoked");
        }
    }
}
