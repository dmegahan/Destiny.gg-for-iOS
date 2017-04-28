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
    
    let twitchDropDowns : [String] = ["Highlights", "Broadcasts"];
    let youtubeDropDowns : [String] = ["Youtube"];
    
    @IBOutlet var dropDownButton: UIBarButtonItem!
    
    var twitchVideos: [Video] = [];
    let dropDownList = DropDown()
    
    override func viewDidLoad() {
        twitchVideos = RestAPIManager.sharedInstance.getTwitchVODs("destiny", dropDownButton.title!);
        
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
                    self.twitchVideos = RestAPIManager.sharedInstance.getTwitchVODs("destiny", item);
                }else if(self.youtubeDropDowns.contains(item)){
                    self.twitchVideos = RestAPIManager.sharedInstance.getYoutubeVideos("Destiny");
                }
                self.tableView.reloadData();
            }
        }
    }
    
    //function to populate our table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VODCell")! as! VODTableViewCell
        let vid: Video = twitchVideos[indexPath.row];
        
        //this needs to be cleaned up - privatise the labels and have a function that takes a video and populates them
        cell.titleLabel.text = vid.title;
        cell.lengthLabel.text = vid.length.stringValue;
        cell.recordedAtLabel.text = vid.recordedAt;
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //show button when row is selected
        let selectedCell = tableView.cellForRow(at: indexPath) as! VODTableViewCell;

        selectedCell.playButton.isEnabled = true;
        selectedCell.playButton.isHidden = false;
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //hide the play button when a row is deselected
        let selectedCell = tableView.cellForRow(at: indexPath) as! VODTableViewCell;
        
        selectedCell.playButton.isEnabled = false;
        selectedCell.playButton.isHidden = true;
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
        
        if(cell.videoType != "Youtube"){
            //need to extract numbers from videoURL and append to the end of this prefix to get the player url
            let twitchVideoPrefix: String = "https://player.twitch.tv/?video=v";
        
            //regex searchs for digits with any length at the end of our string
            let match: String? = getMatchFromRegex(regex: "[\\d]*$", text: cell.videoURL)
        
            if(match != nil){
                let appDelegate = UIApplication.shared.delegate as! AppDelegate;
                appDelegate.streamToDisplay = twitchVideoPrefix + match!;
            
                //return to home screen (stream and chat)
                performSegue(withIdentifier: "VOD2Display", sender: nil);
            }else{
                //perform notification and dont switch views
            }
        }else if(cell.videoType == "Youtube"){
            let youtubePrefix: String = "https://www.youtube.com/embed/";
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            appDelegate.streamToDisplay = youtubePrefix + cell.videoURL;
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
}

