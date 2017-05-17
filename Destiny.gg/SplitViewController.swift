//
//  SplitViewController.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 5/13/17.
//  Copyright © 2017 Daniel Megahan. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //start with primary view hidden
        self.preferredDisplayMode = .primaryHidden;
        //disallow user swiping to show primary
        self.presentsWithGesture = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
