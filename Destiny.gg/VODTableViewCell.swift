//
//  VODTableViewCell.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 1/2/17.
//  Copyright © 2017 Daniel Megahan. All rights reserved.
//

import UIKit

class VODTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var previewImage: UIImageView!
    @IBOutlet var recordedAtLabel: UILabel!
    @IBOutlet var lengthLabel: UILabel!
    @IBOutlet var viewsLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    
    var videoURL: String = "";
    var videoType: String = "";
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        playButton.isEnabled = false;
        playButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        let currentColor: UIColor;
        if(selected){
            currentColor = UIColor.black;
            playButton.isHidden = false
            playButton.isEnabled = true
        }else{
            currentColor = UIColor.white;
            playButton.isHidden = true
            playButton.isEnabled = false
        }
        titleLabel.textColor = currentColor;
        recordedAtLabel.textColor = currentColor;
        lengthLabel.textColor = currentColor;
        viewsLabel.textColor = currentColor;
    }
}
