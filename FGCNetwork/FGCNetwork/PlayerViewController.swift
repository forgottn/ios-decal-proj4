//
//  PlayerViewController.swift
//  FGCNetwork
//
//  Created by Jason nghe on 12/2/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: YTPlayerView!
    var videoID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.translucent = false
        
        playerView.loadWithVideoId(videoID)
        playerView.playVideo()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        UIView.setAnimationsEnabled(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

extension UINavigationController {
    public override func shouldAutorotate() -> Bool {
        return visibleViewController!.shouldAutorotate()
    }
}

class ViewController: UIViewController {
    override func shouldAutorotate() -> Bool {
        return false
    }
}