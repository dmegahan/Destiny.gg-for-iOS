//
//  VODViewController.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 1/2/17.
//  Copyright © 2017 Daniel Megahan. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import DropDown

class VODViewController: UITableViewController, UISplitViewControllerDelegate {
    
    let twitchDropDowns : [String] = [VideoType.Highlight.rawValue, VideoType.Broadcast.rawValue];
    let youtubeDropDowns : [String] = [VideoType.Youtube.rawValue];
    
    @IBOutlet var dropDownButton: UIBarButtonItem!
    @IBOutlet var backButton: UIBarButtonItem!
    
    var twitchVideos: [Video] = [];
    let dropDownList = DropDown()
    
    override func viewDidLoad() {
        dropDownButton.title = defaultVideoType;
        twitchVideos = RestAPIManager.sharedInstance.getTwitchVODs(destinyTwitchName, dropDownButton.title!);
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            backButton.target = splitViewController?.displayModeButtonItem.target;
            backButton.action = splitViewController?.displayModeButtonItem.action;
        }
        
        setupDropDown();
        
        //point the fresh controller to our refresh function
        self.refreshControl?.addTarget(self, action: #selector(VODViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged);
        //some refresh control customization
        refreshControl?.tintColor = UIColor.white;
        refreshControl?.attributedTitle = NSAttributedString(string: "Fetching Destiny VODS");
        
    }
    
    //A drop down list for selecting the different types of VODS or twitch videos (Highlight, video, livestream vod)
    func setupDropDown(){
        dropDownList.anchorView = dropDownButton
        
        dropDownList.dataSource = twitchDropDowns + youtubeDropDowns;
        
        dropDownList.selectionAction = { (index: Int, item: String) in
            //when an item is selected in the list, change the title of the drop down button to the selected item and load a whole new set of vods based on the selected item
            
            //check if the selected videos are already showing
            if(self.dropDownButton.title != item){
                self.dropDownButton.title = item;
                if(self.twitchDropDowns.contains(item)){
                    self.twitchVideos = RestAPIManager.sharedInstance.getTwitchVODs(destinyTwitchName, item);
                }else if(self.youtubeDropDowns.contains(item)){
                    self.twitchVideos = RestAPIManager.sharedInstance.getYoutubeVideos(destinyYoutubeName);
                }
                self.tableView.reloadData();
            }
        }
    }
    
    //function to populate our table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: VODTableViewCell;
        
        //determine what VODCell to show to the user, based on type of device and orientation
        if(UIDevice.current.userInterfaceIdiom == .phone){
            if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
                cell = tableView.dequeueReusableCell(withIdentifier: "VODCellPortrait")! as! VODTableViewCell
            }else{
                cell = tableView.dequeueReusableCell(withIdentifier: "VODCellLandscape")! as! VODTableViewCell
            }
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "VODCell")! as! VODTableViewCell
        }
        
        let vid: Video = twitchVideos[indexPath.row];
        
        //check if its a twitch video or youtube vid
        if(vid.videoType == VideoType.Broadcast.rawValue ||
            vid.videoType == VideoType.Highlight.rawValue ||
            vid.videoType == VideoType.Archive.rawValue){
            //twitch vid
            //this needs to be cleaned up - privatise the labels and have a function that takes a video and populates them
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(vid.length)!);
            let lengthString: String = String(format: lengthFormat, h, m, s);
            cell.lengthLabel.text = lengthString;
            
            //date stuff
            let dateFormat = DateFormatter();
            //take the format we get from the twitch Video and reformat it, start by extracting the date to a date object
            dateFormat.dateFormat = twitchDateFormat;
            let date = dateFormat.date(from: vid.recordedAt);
            
            //reformat the date object to a string that is readable
            let cellDateFormat = DateFormatter();
            cellDateFormat.dateFormat = ourDateFormat;
            let ourDate: String = cellDateFormat.string(from: date!);
            
            cell.recordedAtLabel.text = ourDate;
        }else if(vid.videoType == VideoType.Youtube.rawValue){
            //youtube vid
            //date stuff
            let dateFormat = DateFormatter();
            //take the format we get from the twitch Video and reformat it, start by extracting the date to a date object
            dateFormat.dateFormat = youtubeDateFormat;
            let date = dateFormat.date(from: vid.recordedAt);
            
            //reformat the date object to a string that is readable
            let cellDateFormat = DateFormatter();
            cellDateFormat.dateFormat = ourDateFormat;
            let ourDate: String = cellDateFormat.string(from: date!);
            
            cell.recordedAtLabel.text = ourDate;
            
            //convert the youtube length to a readable length
            let matches: [String] = getMultipleMatchesFromRegex(regex: "(\\d+[H|M|S])", text: vid.length);
            //youtube format for length is PT#H#M#S, our regex captures #H, #M, #S
            var hours = "", minutes = "", seconds = "";
            for match in matches{
                if(match.contains("H")){
                    //remove the last index in this string, which will be H, M, or S
                    hours = match.substring(to: match.index(before: match.endIndex));
                }else if(match.contains("M")){
                    minutes = match.substring(to: match.index(before: match.endIndex));
                }else if(match.contains("S")){
                    seconds = match.substring(to: match.index(before: match.endIndex));
                }
            }
            var lengthLabelString: String = "";
            if(!hours.isEmpty){
                lengthLabelString += hours + "H:";
            }
            if(!minutes.isEmpty){
                if(minutes.characters.count == 1){
                    //if there's only 1 character, we need to insert a 0 so that there are 2
                    minutes.insert("0", at: minutes.startIndex);
                }
                lengthLabelString += minutes + "M:";
            }
            if(!seconds.isEmpty){
                if(seconds.characters.count == 1){
                    //if there's only 1 character, we need to insert a 0 so that there are 2
                    seconds.insert("0", at: seconds.startIndex);
                }
                lengthLabelString += seconds + "S";
            }
            cell.lengthLabel.text = lengthLabelString;
        }
        cell.titleLabel.text = vid.title;
        cell.viewsLabel.text = vid.views.stringValue + " views";
        cell.videoURL = vid.videoURL;
        cell.videoType = vid.videoType;
        
        cell.playButton.tag = indexPath.row;
        
        let imageURL = URL(string: vid.previewURL);
        cell.previewImage.af_setImage(withURL: imageURL!);
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twitchVideos.count;
    }
    
    @IBAction func dropDownButtonPressed(_ sender: UIBarButtonItem) {
        //Drop down button tag is 1
        if(sender.tag == 1){
            dropDownList.show();
        }
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        let index: IndexPath = IndexPath(row: sender.tag, section: 0);
        let cell = self.tableView.cellForRow(at: index) as! VODTableViewCell;
        
        if(cell.videoType != VideoType.Youtube.rawValue){
            //need to extract numbers from videoURL and append to the end of the twitch video prefix to get the player url
        
            //regex searchs for digits with any length at the end of our string
            let match: String? = getMatchFromRegex(regex: "[\\d]*$", text: cell.videoURL)
        
            if(match != nil){
                let appDelegate = UIApplication.shared.delegate as! AppDelegate;
                let videoToDisplay: String = twitchVideoPlayerPrefix + match!;
            
                appDelegate.setVideoToDisplay(video: videoToDisplay);
                performSegue(withIdentifier: "VOD2Display", sender: nil);
            }else{
                //perform notification and dont switch views
            }
        }else if(cell.videoType == VideoType.Youtube.rawValue){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            let videoToDisplay: String = youtubeVideoPlayerPrefix + cell.videoURL;
            appDelegate.setVideoToDisplay(video: videoToDisplay);
            performSegue(withIdentifier: "VOD2Display", sender: nil);
        }
    }
    
    func getMatchFromRegex(regex: String, text: String) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: []);
            let result = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, text.characters.count))
            //extract result from type NSTextCheckingResult
            if((result) != nil){
                let nsText = text as NSString
                let resultString = nsText.substring(with: (result?.range)!) as String
                return resultString
            }
            return nil;
        }catch let error {
            print("invalid regex: " + (error as! String));
            return nil;
        }
    }
    
    func getMultipleMatchesFromRegex(regex: String, text: String) -> [String]{
        do {
            let regex = try NSRegularExpression(pattern: regex);
            let nsStringText = text as NSString;
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsStringText.length));
            return results.map { nsStringText.substring(with: $0.range)};
        } catch let error {
            print("invalid regex: " + (error as! String));
            return [];
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int){
        //returns (h,m,s)
        return (seconds/3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    //Does our refresh, handles all the actions when the user does a refresh
    func handleRefresh(refreshControl: UIRefreshControl){
        self.tableView.reloadData();
        refreshControl.endRefreshing();
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //determine when the user has scrolled through the entire table view list
        let height = scrollView.frame.size.height;
        let contentYoffset = scrollView.contentOffset.y;
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if (distanceFromBottom < height){
            addVideosToTableViewList();
        }
    }
    
    func addVideosToTableViewList(){
        let numberOfRows:Int = self.tableView.numberOfRows(inSection: 0);
        //get the currently selected video type
        if (dropDownButton.title == VideoType.Highlight.rawValue || dropDownButton.title == VideoType.Broadcast.rawValue){
            //Send our REST command to get twitch highlights, specify a different offset and limit based on how many are currently in the list
            //our offset is the current length of the list, and our limit is the current length of the list + the set limit in Definitions.swift
            //we only have one section, so all the rows in that section is our number
            let addedVODs = RestAPIManager.sharedInstance.getTwitchVODs(destinyTwitchName, dropDownButton.title!, numberOfRows, optionalQuery_limit: limit);
            
            twitchVideos.append(contentsOf: addedVODs);
            //update the table view
            self.tableView.beginUpdates();
            for count in 0...addedVODs.count-1 {
                self.tableView.insertRows(at: [IndexPath(row: numberOfRows + count, section: 0)], with: .automatic);
            }
            //self.tableView.insertRows(at: [IndexPath(row:twitchVideos.count-1, section: 0)], with: .automatic);
            self.tableView.endUpdates();
        }else if(dropDownButton.title == VideoType.Youtube.rawValue){
            if(numberOfRows >= youtubeHighestMaxResults){
                //return if we're at the cap of video requests youtube allows
                return;
            }
            //same thing basically but with youtube
            let addedVideos = RestAPIManager.sharedInstance.getYoutubeVideos(destinyYoutubeName, numberOfRows + limit);
            //since youtube doesn't give us an offset, we need to ignore all the videos in the addedVideos list that we already have, so we'll discard all the videos that are at an index less than our number of rows
            let newVideos = addedVideos.dropFirst(numberOfRows);
            
            //update our table
            twitchVideos.append(contentsOf: newVideos);
            self.tableView.beginUpdates();
            for count in 0...newVideos.count-1 {
                self.tableView.insertRows(at: [IndexPath(row: numberOfRows + count, section: 0)], with: .automatic);
            }
            self.tableView.endUpdates();
        }
    }
}

