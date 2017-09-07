//
//  ViewController.swift
//  Destiny.gg
//  ViewController for Ipad storyboard (Main.storyboard)
//
//  Created by Daniel Megahan on 1/31/16.
//  Copyright © 2016 Daniel Megahan. All rights reserved.
//

import UIKit
import WebKit
import DropDown

//inherit from UIWebViewDelegate so we can track when the webviews have loaded/not loaded
class ViewController: UIViewController, UIWebViewDelegate, UISearchBarDelegate, UISplitViewControllerDelegate, WKNavigationDelegate{
    
    @IBOutlet var myChatWebView: WKWebView!
    @IBOutlet var myStreamWebView: WKWebView!
    @IBOutlet var myToolBar: UIToolbar!
    @IBOutlet var lockFramesButton: UIBarButtonItem!
    @IBOutlet var twitchSearchBar: UISearchBar!
    @IBOutlet var goBackButton: UIButton!
    @IBOutlet var switchChatsButton: UIBarButtonItem!

    @IBOutlet var VODsButton: UIBarButtonItem!
    @IBOutlet var settingsDropDownButton: UIBarButtonItem!
    //variables (intialized in initializeCurrentFrames) for saving frame layout after a user pans the frames
    var chatCurrentLandscapeFrame = CGRect();
    var streamCurrentLandscapeFrame = CGRect();
    
    var chatCurrentPortraitFrame = CGRect();
    var streamCurrentPortraitFrame = CGRect();
    
    //startPanLocation keeps track of where the pan started
    var startPanLocation = CGPoint();
    
    //keeps track of whether the frame (The chat frame and stream frame) should be locked
    //in their current position
    var isLocked = false;
    
    var currentConstraints = [NSLayoutConstraint]();
    
    let defaultStream = destinyTwitchName;
    //string variable containing what will be displayed in the stream web view
    var videoURL: String?;
    
    let settingsDropDown = DropDown();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
        
        //set up the button to open the primary split view controller
        if(UIDevice.current.userInterfaceIdiom == .pad){
            VODsButton.target = splitViewController?.displayModeButtonItem.target;
            VODsButton.action = splitViewController?.displayModeButtonItem.action;
        }
    
        //get our app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        
        myToolBar.barTintColor = UIColor.black;
        
        self.initializeConstraints();
        
        self.twitchSearchBar.delegate = self;
        
        setupDropDown();

        //embed chat whether or not stream is online
        embedChat(destinyChatURL);
        videoURL = appDelegate.streamToDisplay;
        embedStream(videoURL!);

        let panSwipe = UIPanGestureRecognizer(target: self, action: #selector(ViewController.OnPanSwipe(_:)));
        self.view.addGestureRecognizer(panSwipe);
        
        //allow pan swipes to be recognized when panning inside a UIWebView
        myChatWebView.scrollView.panGestureRecognizer .require(toFail: panSwipe);
        myStreamWebView.scrollView.panGestureRecognizer.require(toFail: panSwipe);
    }
    
    func setupDropDown(){
        settingsDropDown.anchorView = settingsDropDownButton
        settingsDropDown.dataSource = settings;
        
        settingsDropDown.selectionAction = { (index: Int, item: String) in
            if(item == Setting.VODs.rawValue){
                //if VODs selected from dropdown, perform segue
                self.performSegue(withIdentifier: "SegueToVODs", sender: nil);
            }else if(item == Setting.Lock.rawValue || item == Setting.UnlockFrames.rawValue){
                self.toggleLockedFrames();
                if(self.isLocked){
                    //if now locked (it should be), change data source to include setting "Unlock Frames"
                    self.replaceSettingInDropdown(toRemove: Setting.Lock.rawValue, toAdd: Setting.UnlockFrames.rawValue)
                }else{
                    self.replaceSettingInDropdown(toRemove: Setting.UnlockFrames.rawValue, toAdd: Setting.Lock.rawValue);
                }
                //if Lock Frames selected from dropdown, lock or unlock the frames
            }else if(item == Setting.TwitchChat.rawValue){
                //Twitch Chat/DGG Chat button - Switch which chat is displayed
                self.embedChat(destinyTwitchChatURL);
                self.replaceSettingInDropdown(toRemove: Setting.TwitchChat.rawValue, toAdd: Setting.DggChat.rawValue)
            }else if(item == Setting.DggChat.rawValue){
                self.embedChat(destinyChatURL);
                self.replaceSettingInDropdown(toRemove: Setting.DggChat.rawValue, toAdd: Setting.TwitchChat.rawValue)
            }
        }
    }
    
    //this function swaps out a setting in the dropdown list. toRemove is swapped with toAdd,
    //and uses the same index
    func replaceSettingInDropdown(toRemove: String, toAdd: String){
        //find what index toRemove is at
        let indexToInsert: Int = settingsDropDown.dataSource.index(of: toRemove)!;
        settingsDropDown.dataSource.replaceSubrange(indexToInsert...indexToInsert, with: [toAdd]);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func embedStream(_ videoURL: String){
        //url implementation
        let url = URL(string: videoURL);
        let requestObj = URLRequest(url: url!);
        myStreamWebView.load(requestObj);
    }
    
    func embedChat(_ chatURL: String){
        //chat embed URL
        let url = URL(string: chatURL);
        let requestObj = URLRequest(url: url!);
        myChatWebView.load(requestObj);
    }

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
                if(myChatWebView.frame.origin.y + distanceY >= myToolBar.frame.maxY &&
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
        
        let minWidth = CGFloat(200);
        let minHeight = CGFloat(150);
        
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
            let streamWidthConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: minWidth);
            
            //chat right border - line up with right side of screen
            let chatTrailingConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0);
            //chat top border - line up with toolbar bottom
            let chatTopConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .top, relatedBy: .equal, toItem: myToolBar, attribute: .bottom, multiplier: 1.0, constant: 0);
            //chat bottom border - line up with bottom of screen
            let chatBottomConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0);
            //chat left border - line up with right of stream
            let chatLeadingConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .leading, relatedBy: .equal, toItem: myStreamWebView, attribute: .trailing, multiplier: 1.0, constant: 0);
            //initialize chat height at at least 300
            let chatWidthConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: minWidth);
        
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
            let streamHeightConstraint = NSLayoutConstraint(item: myStreamWebView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: minHeight);
            
            //chat right border - line up with right side of screen
            let chatTrailingConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0);
            //chat top border - line up with bottom of stream
            let chatTopConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .top, relatedBy: .equal, toItem: myStreamWebView, attribute: .bottom, multiplier: 1.0, constant: 0);
            //chat bottom border - line up with bottom of screen
            let chatBottomConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0);
            //chat left border - line up with left side of screen
            let chatLeadingConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
            //initialize chat height to at least 300, so both stream and chat show up
            let chatHeightConstraint = NSLayoutConstraint(item: myChatWebView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: minHeight);
            
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
    
    func toggleLockedFrames(){
        isLocked = !isLocked;
        
        if(isLocked){
            //remove all recognized gestures (currently only a pan swipe is used, so effectively only removing that)
            self.view.gestureRecognizers?.removeAll();
        }else{
            //if there are no current gesture recognizers (if there is then we shouldn't do anything)
            if(self.view.gestureRecognizers != nil){
                //recreate the original panswipe and add it back like we do when the view loads
                let panSwipe = UIPanGestureRecognizer(target: self, action: #selector(ViewController.OnPanSwipe(_:)));
                self.view.addGestureRecognizer(panSwipe);

                myChatWebView.scrollView.panGestureRecognizer .require(toFail: panSwipe);
                myStreamWebView.scrollView.panGestureRecognizer.require(toFail: panSwipe);
                
                //this might need another look, there should be a more efficient way to just disable a certain swipe temporarily, without removing it from the view.gestureRecognizers list
            }
        }
    }
    
    @IBAction func barButtonPressed(_ sender: UIBarButtonItem) {
        switch sender.tag {
        //settings drop down tag is 3
        case 3:
            settingsDropDown.show()
        default:
            break;
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        //go back button - that shows up when a link is clicked in the chat
        switch sender.tag {
        case 0:
            if(myChatWebView.canGoBack){
                myChatWebView.goBack();
            }
        default:
            break;
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text?.lowercased();

        //commented out because doesStreamExist doesnt work. Twitch no longer
        //differentiates endpoint wise between a invalid stream and an offline one
        //if(RestAPIManager.sharedInstance.doesStreamExist(searchText!)){
        let stream : String = twitchChannelPrefix + searchText!;
        embedStream(stream);
        //}
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //myChatWebview has a tag of 0
        if(webView.tag == 0){
            //called when myWebView loads a request (like a link clicked in chat)
            let currentURL : String = (webView.request?.url?.absoluteString)!;
            
            //if the request is not for chat itself, show the go back button so the user can return to chat
            if(currentURL != destinyChatURL && currentURL != destinyTwitchChatURL){
                goBackButton.isHidden = false;
            }else if(currentURL == destinyChatURL && currentURL == destinyTwitchChatURL){
                goBackButton.isHidden = true;
            }
        }
    }
    
    func webViewsFinishedInitialLoad() -> Bool{
        return myStreamWebView.isLoading && myChatWebView.isLoading;
    }
}
