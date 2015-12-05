//
//  PlayerListViewController.swift
//  FGCNetwork
//
//  Created by Jason nghe on 11/24/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import Parse
import UIKit

class PlayerListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var game: PFObject!
    var character: String!
    
    var playersArray: [PFObject]! = []
    var selectedPlayerIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let query = PFQuery(className: "Player")
        query.whereKey("game", equalTo: game)
        query.whereKey("character", equalTo: self.character)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                self.playersArray = objects
                self.tableView.reloadData()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("playerCell", forIndexPath: indexPath)
        
        cell.textLabel!.text = self.playersArray[indexPath.row]["gamertag"] as? String
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedPlayerIndex = indexPath.row
        performSegueWithIdentifier("toProfile", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileViewController = segue.destinationViewController as? ProfileViewController {
            if segue.identifier == "toProfile" {
                profileViewController.profileObject = self.playersArray[selectedPlayerIndex]["user"] as! PFObject
                profileViewController.isMyProfile = false
            }
        }
    }
    
}
