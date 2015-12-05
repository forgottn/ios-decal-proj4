//
//  PlaylistTableViewController.swift
//  FGCNetwork
//
//  Created by Jason nghe on 12/2/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit
import Parse

class PlaylistTableViewController: UITableViewController {
    
    var playlist: PFObject!
    var videosArray: [Youtube]!
    var selectedVideoIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if refreshControl != nil && selectedVideoIndex == nil {
            self.tableView.contentOffset = CGPointMake(0, -self.refreshControl!.frame.size.height)
            self.refreshControl?.beginRefreshing()
        }
    }
    
    func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl!)
    }
    
    @IBAction func refresh(sender: AnyObject) {
        self.tableView.reloadData()
        YoutubeRequest().fetchVideosOf(playlist: playlist["playlistID"] as! String, maxResults: 10) { (objects) -> Void in
            if let objects = objects {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.videosArray = objects
                    self.tableView.reloadData()
                    sender.endRefreshing()
                }
            }
        }
        sender.endRefreshing()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.videosArray != nil {
            return self.videosArray.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("videoCell", forIndexPath: indexPath)
        
        let imageView = cell.viewWithTag(10) as! UIImageView
        let videoTitleLabel = cell.viewWithTag(11) as! UILabel
        let channelTitleLabel = cell.viewWithTag(12) as! UILabel
        let thumbnailURL = self.videosArray[indexPath.row].thumbnail!
        
        var titleString = self.videosArray[indexPath.row].title
        if (titleString!.hasPrefix("USFIV: ")) {
            titleString = (titleString!.substringFromIndex(7))
        }
        
        imageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: thumbnailURL)!)!)!
        videoTitleLabel.text = titleString
        channelTitleLabel.text = self.videosArray[indexPath.row].channelTitle
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedVideoIndex = indexPath.row
        performSegueWithIdentifier("toPlayer", sender: self)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "toPlayer":
                let destinationViewController = segue.destinationViewController as? UINavigationController
                let playerViewController = destinationViewController?.topViewController as? PlayerViewController
                playerViewController!.videoID = self.videosArray[selectedVideoIndex].videoId
            default: break
            }
        }
    }
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue) {
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        UIView.setAnimationsEnabled(true)
    }
}
