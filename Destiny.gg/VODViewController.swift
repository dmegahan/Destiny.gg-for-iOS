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
    @IBOutlet var dropDownButton: UIBarButtonItem!
    
    var twitchVideos: [TwitchVideo] = [];
    let dropDownList = DropDown()
    
    override func viewDidLoad() {
        twitchVideos = RestAPIManager.sharedInstance.getTwitchVODs("destiny", dropDownButton.title!);
        
        setupDropDown();
    }
    
    //A drop down list for selecting the different types of VODS or twitch videos (Highlight, video, livestream vod)
    func setupDropDown(){
        dropDownList.anchorView = dropDownButton
        
        dropDownList.dataSource = ["Highlights", "Broadcasts"];
        
        dropDownList.selectionAction = { (index: Int, item: String) in
            //when an item is selected in the list, change the title of the drop down button to the selected item and load a whole new set of vods based on the selected item
            self.dropDownButton.title = item;
            self.twitchVideos = RestAPIManager.sharedInstance.getTwitchVODs("destiny", item);
            self.tableView.reloadData();
        }
    }
    
    //function to populate our table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VODCell")! as! VODTableViewCell
        let twitchVid: TwitchVideo = twitchVideos[indexPath.row];
        
        cell.titleLabel.text = twitchVid.title;
        cell.lengthLabel.text = twitchVid.length.stringValue;
        cell.recordedAtLabel.text = twitchVid.recordedAt;
        cell.viewsLabel.text = twitchVid.views.stringValue + " views";
        
        let imageURL = URL(string: twitchVid.previewURL);
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
}
