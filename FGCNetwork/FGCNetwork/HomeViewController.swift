//
//  HomeViewController.swift
//  FGCNetwork
//
//  Created by Jason nghe on 11/28/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import Parse
import UIKit
import AVKit
import AVFoundation

class HomeViewController: UIViewController, SMSegmentViewDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var mainPlaylistScrollView: UIScrollView =  UIScrollView()
    var selectionBar: UIView = UIView()
    var segmentedControl: SMSegmentView!
    var currentSelectedIndex: Int!
    
    var stream: Stream!
    var gamesArray: [PFObject]!
    var youtubeArray: [Youtube]!
    var playlistArray: [PFObject]!
    var mainPlaylist: PFObject!
    var selectedPlaylist: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 187.0/255.0, green: 18.0/255.0, blue: 36.0/255.0, alpha: 1.0)
        
        self.tableView.estimatedRowHeight = tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        configureSegmentedControl()
    }
    
    func reloadMainPlaylistScrollView() {
        let subViews = self.mainPlaylistScrollView.subviews
        for subview in subViews {
            subview.removeFromSuperview()
        }
    }
    
    func configureMainPlaylistScrollMenu(scrollView: UIScrollView) -> UIScrollView {
        var x = CGFloat(8.0)
        for (var i = 0; i < youtubeArray.count; i++) {
            
            let buttonView = UIView(frame: CGRectMake(x, 0, 120, 240))
            
            // YTPlayer ImageView
            //            let thumbnailImageView = YTPlayerView(frame: CGRectMake(0, 0, 120, 90))
            //            thumbnailImageView.loadWithVideoId(youtubeArray[i].videoId)
            //            buttonView.addSubview(thumbnailImageView)
            
            //             Thumbnail Image Preview
            let thumbnailURL =  youtubeArray[i].thumbnail!
            let thumbnailImage = UIImage(data: NSData(contentsOfURL: NSURL(string: thumbnailURL)!)!)!
            let button = UIButton()
            button.setImage(thumbnailImage, forState: .Normal)
            button.frame = CGRect(x: 0, y: 0, width: 120 , height: 90)
            button.tag = i
            button.addTarget(self, action: "tappedVideo:", forControlEvents: UIControlEvents.TouchUpInside)
            buttonView.addSubview(button)
            
            // let thumbnailImageView = UIImageView(image: thumbnailImage)
            // thumbnailImageView.frame = CGRect(x: 0, y: 0, width: 120, height: 90)
            
            let titleLabel = UILabel(frame: CGRectMake(0, button.frame.height, buttonView.frame.size.width, 50))
            titleLabel.setNeedsDisplay()
            titleLabel.setNeedsLayout()
            titleLabel.numberOfLines = 0
            var titleString = youtubeArray[i].title!
            if (titleString.hasPrefix("USFIV: ")) {
                titleString = (titleString.substringFromIndex(7))
                
            }
            titleLabel.text = titleString
            titleLabel.font = UIFont(name: "SFUIText-Semibold", size: 12)
            buttonView.addSubview(titleLabel)
            
            let channelLabel = UILabel(frame: CGRectMake(0, button.frame.height + titleLabel.frame.height, buttonView.frame.size.width, 24))
            channelLabel.text = youtubeArray[i].channelTitle
            channelLabel.font = UIFont(name: "SFUIText-Medium", size: 12)
            channelLabel.textColor = UIColor.grayColor()
            buttonView.addSubview(channelLabel)
            
            
            
            x += buttonView.frame.size.width + 8.0
            scrollView.addSubview(buttonView)
        }
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSizeMake(x, scrollView.frame.size.height)
        return scrollView
    }
    
    var selectedVideoIndex: Int!
    func tappedVideo(sender: UIButton) {
        selectedVideoIndex = sender.tag
        performSegueWithIdentifier("toPlayer", sender: self)
        
    }
    
    
    // MARK: - Segmented Controller
    
    func configureSegmentedControl() {
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = UIColor.whiteColor()
        self.scrollView.showsHorizontalScrollIndicator = false
        self.segmentedControl = SMSegmentView(frame: CGRect(x: 0, y: 0.0, width: self.view.frame.size.width*1.3, height: 50.0), separatorColour: UIColor.clearColor(), separatorWidth: 0.0, segmentProperties: [keyContentVerticalMargin: 10.0, keySegmentOnSelectionColour: UIColor.whiteColor(), keySegmentOffSelectionColour: UIColor.whiteColor(), keySegmentOnSelectionTextColour: UIColor(red: 187.0/255.0, green: 18.0/255.0, blue: 36.0/255.0, alpha: 1.0), keySegmentTitleFont: UIFont(name: "SFUIText-Medium", size: 14)!])
        
        self.segmentedControl.delegate = self
        
        let query = PFQuery(className: "Game")
        query.whereKeyExists("title")
        query.orderByAscending("position")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            self.gamesArray = objects!
            
            for object in objects! {
                let shortTitle = object.valueForKey("shortTitle") as? String
                self.segmentedControl.addSegmentWithTitle(shortTitle, onSelectionImage: nil, offSelectionImage: nil)
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.segmentedControl.selectSegmentAtIndex(0)
                self.segmentedControl.layer.borderColor = UIColor.clearColor().CGColor
                self.segmentedControl.layer.borderWidth = 1.0
                
                self.selectionBar.frame = CGRect(x: 0.0, y: 45.0, width: self.segmentedControl.frame.size.width/CGFloat(self.segmentedControl.numberOfSegments), height: 5.0)
                self.selectionBar.backgroundColor = UIColor(red: 187.0/255.0, green: 18.0/255.0, blue: 36.0/255.0, alpha: 1.0)
                
                self.scrollView.translatesAutoresizingMaskIntoConstraints = true
                self.scrollView.addSubview(self.segmentedControl)
                self.scrollView.contentSize = self.segmentedControl.frame.size
                self.scrollView.addConstraint(NSLayoutConstraint(item: self.segmentedControl, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.scrollView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0))
            }
        }
    }
    
    func segmentView(segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int) {
        if let currentSelectedIndex = self.currentSelectedIndex {
            if currentSelectedIndex == index {
                return
            }
        }
        
        self.currentSelectedIndex = index
        self.youtubeArray = nil
        self.stream = nil
        self.reloadMainPlaylistScrollView()
        self.tableView.reloadData()
        
        
        let placeSelectionBar = { () -> () in
            var barFrame = self.selectionBar.frame
            barFrame.origin.x = barFrame.size.width * CGFloat(index)
            self.selectionBar.frame = barFrame
        }
        
        if self.selectionBar.superview == nil {
            self.segmentedControl.addSubview(self.selectionBar)
            placeSelectionBar()
        } else {
            UIView.animateWithDuration(0.1) { () -> Void in
                placeSelectionBar()
            }
        }
        
        let query = PFQuery(className: "Playlist")
        query.whereKey("game", equalTo: self.gamesArray[index])
        query.orderByAscending("date")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                self.playlistArray = objects
                self.mainPlaylist = self.playlistArray.last
                let mainPlaylistID = self.mainPlaylist!["playlistID"]
                self.sectionHeaderTitlesArray.replaceObjectAtIndex(1, withObject: self.mainPlaylist!["title"]!.uppercaseString)
                self.playlistArray.removeLast()
                self.playlistArray = self.playlistArray.reverse()
                self.spinner.startAnimating()
                
                TwitchRequest().fetchStreamsOf(self.gamesArray[index]["title"] as? String) { (stream) -> Void in
                    YoutubeRequest().fetchVideosOf(playlist: mainPlaylistID! as! String) { (youtubeObjects) -> Void in
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            if let stream = stream {
                                self.stream = stream
                            }
                            if let objects = youtubeObjects {
                                self.youtubeArray = objects
                            }
                            self.spinner.stopAnimating()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Table View Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.youtubeArray != nil {
            if self.playlistArray != nil {
                return 3
            }
            return 2
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if youtubeArray != nil {
            if section == 2 {
                return playlistArray.count
            }
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("streamCell", forIndexPath: indexPath)
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("streamCell", forIndexPath: indexPath)
            let webView = cell.viewWithTag(11) as! UIWebView
            webView.scrollView.scrollEnabled = false
            
            if let stream = stream {
                let myURL: String = "http://player.twitch.tv/?channel=\(stream.channelName)"
                let myURLRequest: NSURLRequest = NSURLRequest(URL: NSURL(string: myURL)!)
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    webView.mediaPlaybackRequiresUserAction = true
                    webView.loadRequest(myURLRequest)
                }
            }
            
            return cell
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("mainPlaylistCell", forIndexPath: indexPath)
            var scrollView = cell.viewWithTag(12) as! UIScrollView
            if (youtubeArray != nil) {
                scrollView = configureMainPlaylistScrollMenu(scrollView)
                self.mainPlaylistScrollView = scrollView
            }
        } else if indexPath.section == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier("playlistCell", forIndexPath: indexPath)
            cell.textLabel!.text = self.playlistArray[indexPath.row]["title"] as? String
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.selectedPlaylist = self.playlistArray[indexPath.row]
            performSegueWithIdentifier("toPlaylist", sender: self)
        }
    }
    
    var sectionHeaderTitlesArray: NSMutableArray = ["LIVE NOW", "LATEST VIDEOS", "MORE VIDEOS"]
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame:CGRect = tableView.frame
        
        let title = UILabel(frame: CGRectMake(15, 7.5, 250, 30))
        title.font = UIFont(name: "SFUIText-Semibold", size: 14)!
        title.textColor = UIColor.grayColor()
        title.text = sectionHeaderTitlesArray.objectAtIndex(section) as? String
        
        let headBttn:UIButton = UIButton(type: UIButtonType.Custom) as UIButton
        headBttn.setImage(UIImage(named: "More Than-1.png"), forState: UIControlState.Normal)
        headBttn.frame = CGRectMake(headerFrame.width*0.85, 7.5, 30, 30)
        headBttn.enabled = true
        headBttn.titleLabel?.text = title.text
        headBttn.tag = sectionHeaderTitlesArray.indexOfObject(sectionHeaderTitlesArray.objectAtIndex(section))
        headBttn.addTarget(self, action: "headerButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let headerView:UIView = UIView(frame: CGRectMake(0, 0, headerFrame.size.width, 45))
        headerView.backgroundColor = UIColor.clearColor()
        headerView.addSubview(title)
        headerView.addSubview(headBttn)
        
        return headerView
    }
    
    func headerButtonTapped(sender: UIButton) {
        let section = sender.tag
        switch section {
        case 0: break
        case 1:
            self.selectedPlaylist = self.mainPlaylist
            performSegueWithIdentifier("toPlaylist", sender: self)
        default: break
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "toPlaylist":
                let playlistViewController = segue.destinationViewController as? PlaylistTableViewController
                playlistViewController?.playlist = self.selectedPlaylist
            case "toPlayer":
                let destinationViewController = segue.destinationViewController as? UINavigationController
                let playerViewController = destinationViewController?.topViewController as? PlayerViewController
                playerViewController!.videoID = self.youtubeArray[selectedVideoIndex].videoId
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



extension String
{
    func substringFromIndex(index: Int) -> String
    {
        if (index < 0 || index > self.characters.count)
        {
            return ""
        }
        return self.substringFromIndex(self.startIndex.advancedBy(index))
    }
}