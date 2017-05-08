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

class VODViewController: UITableViewController {
    
    let twitchDropDowns : [String] = [VideoType.Highlight.rawValue, VideoType.Broadcast.rawValue];
    let youtubeDropDowns : [String] = [VideoType.Youtube.rawValue];
    
    @IBOutlet var dropDownButton: UIBarButtonItem!
    
    var twitchVideos: [Video] = [];
    let dropDownList = DropDown()
    
    override func viewDidLoad() {
        twitchVideos = RestAPIManager.sharedInstance.getTwitchVODs(destinyTwitchName, dropDownButton.title!);
        
        setupDropDown();
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "VODCell")! as! VODTableViewCell
        let vid: Video = twitchVideos[indexPath.row];
        
        //check if its a twitch video or youtube vid
        print("DEE: " + vid.videoType);
        if(vid.videoType == VideoType.Broadcast.rawValue || vid.videoType == VideoType.Highlight.rawValue){
            //twitch vid
            //this needs to be cleaned up - privatise the labels and have a function that takes a video and populates them
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds: vid.length.intValue);
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
                appDelegate.streamToDisplay = twitchVideoPlayerPrefix + match!;
            
                //return to home screen (stream and chat)
                performSegue(withIdentifier: "VOD2Display", sender: nil);
            }else{
                //perform notification and dont switch views
            }
        }else if(cell.videoType == VideoType.Youtube.rawValue){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            appDelegate.streamToDisplay = youtubeVideoPlayerPrefix + cell.videoURL;
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
    
    func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int){
        //returns (h,m,s)
        return (seconds/3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

