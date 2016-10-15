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
    
    var currentConstraints = [NSLayoutConstraint]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
        
        self.initializeConstraints();
        
        //embed chat whether or not stream is online
        embedChat();
        
        let streamer = "Destiny";
        
        //let streamOnline = RestAPIManager.sharedInstance.isStreamOnline(streamer);
        embedStream(streamer);

        let panSwipe = UIPanGestureRecognizer(target: self, action: #selector(ViewController.OnPanSwipe(_:)));
        self.view.addGestureRecognizer(panSwipe);
        
        //allow pan swipes to be recognized when panning inside a UIWebView
        myChatWebView.scrollView.panGestureRecognizer .require(toFail: panSwipe);
        myStreamWebView.scrollView.panGestureRecognizer.require(toFail: panSwipe);
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("Web view did finish load");
        webView.gapBetweenPages = 0;
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
                    chatCurrentLandscapeFrame = newChatFrame;
                }
            
                let newStreamFrame = CGRect(x: myStreamWebView.frame.origin.x, y: myStreamWebView.frame.origin.y,
                    width: ceil(myStreamWebView.frame.width + distanceX), height: myStreamWebView.frame.height)
                //no point in panning the stream if the width + distanceX is smaller than 0 or if the stream > the width of the screen
                if(myStreamWebView.frame.width + distanceX >= 0 &&
                myStreamWebView.frame.width + distanceX <= UIScreen.main.bounds.width){
                    myStreamWebView.frame = newStreamFrame;
                    streamCurrentLandscapeFrame = newStreamFrame;
                }
                startPanLocation = currentPanLocation;
            }else if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
                let currentPanLocation = gesture.translation(in: self.view)
                let distanceY = ceil(currentPanLocation.y - startPanLocation.y);
                
                //once we have the moved distance, we edit the frames (cant edit width directly, need to create a new frame)
                let newChatFrame = CGRect(x: myChatWebView.frame.origin.x, y: ceil(myChatWebView.frame.origin.y + distanceY),
                    width: myChatWebView.frame.width, height: ceil(myChatWebView.frame.height - distanceY))
                //we do a check to determine if the chat will go offstream (too far to the left). If it will, we don't move it anymore
                //also dont move it if the chat is going offscreen to the right. Stop the origin.x at the bounds of screen
                if(myChatWebView.frame.origin.y + distanceY >= 0 &&
                myChatWebView.frame.origin.y + distanceY <= UIScreen.main.bounds.height){
                    myChatWebView.frame = newChatFrame;
                    chatCurrentPortraitFrame = newChatFrame;
                }
                
                let newStreamFrame = CGRect(x: myStreamWebView.frame.origin.x, y: myStreamWebView.frame.origin.y,
                    width: myStreamWebView.frame.width, height: ceil(myStreamWebView.frame.height + distanceY))
                //no point in panning the stream if the width + distanceX is smaller than 0 or if the stream > the width of the screen
                if(myStreamWebView.frame.height + distanceY >= 0 &&
                myStreamWebView.frame.height + distanceY <= UIScreen.main.bounds.height){
                    myStreamWebView.frame = newStreamFrame;
                    streamCurrentPortraitFrame = newStreamFrame;
                }
                startPanLocation = currentPanLocation;
            }
        }
        
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation){
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
            if(chatCurrentPortraitFrame != CGRect() && streamCurrentPortraitFrame != CGRect()){
                //saved frames aren't uninitialized, use them to resize the frames 
                myChatWebView.frame = chatCurrentPortraitFrame;
                myStreamWebView.frame = streamCurrentPortraitFrame;
            }else{
                //use constraints instead
                initializeConstraints();
            }
        }else if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
            if(chatCurrentLandscapeFrame != CGRect() && streamCurrentLandscapeFrame != CGRect()){
                //saved frames aren't uninitialized, use them to resize the frames
                myChatWebView.frame = chatCurrentLandscapeFrame;
                myStreamWebView.frame = streamCurrentLandscapeFrame;
            }else{
                //use constraints instead
                initializeConstraints();
            }
        }
    }
    
    func addAllConstraintsToView(){
        for constraint in currentConstraints {
            view.addConstraint(constraint);
        }
    }
    
    func initializeConstraints(){
        //needs to be turned off to give way for our custom constraints
        myChatWebView.translatesAutoresizingMaskIntoConstraints = false;
        myStreamWebView.translatesAutoresizingMaskIntoConstraints = false;
        
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
            //constant = space inbetween 2 objects (usually 0 for us)
            
            //Constraint for the streams right (trailing) border - line up with the chats left border
            let streamTrailingConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .trailing, relatedBy: .equal, toItem: myChatWebView, attribute: .leading, multiplier: 1.0, constant: 0);
            //streams upper border - line up with the bottom of the toolbar
            let streamTopConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .top, relatedBy: .equal, toItem: myToolBar, attribute: .bottom, multiplier: 1.0, constant: 0);
            //streams bottom border - line up with the bottom of the devices screen
            let streamBottomConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0);
            //streams left border - line up with the devices left side
            let streamLeadingConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
            //initialize stream height to at least 300 - this is so both the stream and chat are visible on launch
            let streamWidthConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300);
            
            //chat right border - line up with right side of screen
            let chatTrailingConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0);
            //chat top border - line up with toolbar bottom
            let chatTopConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .top, relatedBy: .equal, toItem: myToolBar, attribute: .bottom, multiplier: 1.0, constant: 0);
            //chat bottom border - line up with bottom of screen
            let chatBottomConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0);
            //chat left border - line up with right of stream
            let chatLeadingConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .leading, relatedBy: .equal, toItem: myStreamWebView, attribute: .trailing, multiplier: 1.0, constant: 0);
            //initialize chat height at at least 300
            let chatWidthConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300);
            
            //remove current constraints so that there's not conflicting constraints
            view.removeConstraints(currentConstraints);
            currentConstraints.removeAll();
            
            //add all constraints to list then add all constraints in list to view
            currentConstraints.append(streamTrailingConstraint);
            currentConstraints.append(streamTopConstraint);
            currentConstraints.append(streamBottomConstraint);
            currentConstraints.append(streamLeadingConstraint);
            currentConstraints.append(streamWidthConstraint);
            
            currentConstraints.append(chatTrailingConstraint);
            currentConstraints.append(chatTopConstraint);
            currentConstraints.append(chatBottomConstraint);
            currentConstraints.append(chatLeadingConstraint);
            currentConstraints.append(chatWidthConstraint);
        }else{
            
            //stream right border - line up with right side of screen
            let streamTrailingConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0);
            //stream top border - line up with bottom of toolbar
            let streamTopConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .top, relatedBy: .equal, toItem: myToolBar, attribute: .bottom, multiplier: 1.0, constant: 0);
            //stream bottom border - line up with top of chat
            let streamBottomConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .bottom, relatedBy: .equal, toItem: myChatWebView, attribute: .top, multiplier: 1.0, constant: 0);
            //stream left border - line up with left side of screen
            let streamLeadingConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
            //stream height - initialize it to at least 300 so both stream and chat show up
            let streamHeightConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300);
            
            //chat right border - line up with right side of screen
            let chatTrailingConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0);
            //chat top border - line up with bottom of stream
            let chatTopConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .top, relatedBy: .equal, toItem: myStreamWebView, attribute: .bottom, multiplier: 1.0, constant: 0);
            //chat bottom border - line up with bottom of screen
            let chatBottomConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0);
            //chat left border - line up with left side of screen
            let chatLeadingConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
            //initialize chat height to at least 300, so both stream and chat show up
            let chatHeightConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300);
            
            //remove all constraints so no conflicts
            view.removeConstraints(currentConstraints);
            currentConstraints.removeAll();
            
            //add all constraints to list and then to view
            currentConstraints.append(streamTrailingConstraint);
            currentConstraints.append(streamTopConstraint);
            currentConstraints.append(streamBottomConstraint);
            currentConstraints.append(streamLeadingConstraint);
            currentConstraints.append(streamHeightConstraint);
            
            currentConstraints.append(chatTrailingConstraint);
            currentConstraints.append(chatTopConstraint);
            currentConstraints.append(chatBottomConstraint);
            currentConstraints.append(chatLeadingConstraint);
            currentConstraints.append(chatHeightConstraint);
        }
        addAllConstraintsToView();
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
