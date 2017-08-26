//
//  LaunchScreenViewController.swift
//  Destiny.gg
//
//  Created by Daniel Megahan on 8/26/17.
//  Copyright © 2017 Daniel Megahan. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet var emoteImageView: UIImageView?;
    @IBOutlet var launchScreenView: UIView?;
    
    var nextViewController: ViewController?;
    
    override func viewWillAppear(_ animated: Bool) {
        emoteImageView?.image = UIImage(named: selectRandomEmoticon());
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard: UIStoryboard = self.storyboard!;
        nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as? ViewController;
        self.present(nextViewController!, animated: true, completion: nil);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSegueAfterTime), userInfo: nil, repeats: true)
        timer.fire();
    }
    
    func performSegueAfterLoad(ViewControlllerToSegue: ViewController){
        while(!ViewControlllerToSegue.webViewsFinishedInitialLoad()){
            //wait for webviews to finish loading
            
        }
    }
    
    func performSegueAfterTime(){
        performSegue(withIdentifier: "homepageSegue", sender: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectRandomEmoticon() -> String{
        //search the emoticons folder in the project and return a list of files in that folder
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent("emoticons", isDirectory: true);
        let contents = try! fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
        
        let numberOfEmotes: Int = contents.count;
        //get random emote based on count
        let randomIndex: Int = Int(arc4random_uniform(UInt32(numberOfEmotes)));

        return contents[randomIndex].lastPathComponent;
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
