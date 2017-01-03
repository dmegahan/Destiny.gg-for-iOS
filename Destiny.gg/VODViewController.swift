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
    var twitchVideos: [TwitchVideo] = [];
    
    override func viewDidLoad() {
        twitchVideos = RestAPIManager.sharedInstance.getTwitchVODs("destiny");
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
}
