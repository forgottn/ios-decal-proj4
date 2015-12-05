//
//  GameListSettingTableViewController.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/25/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit
import Parse

class GameListSettingTableViewController: UITableViewController {
    
    var games = [PFObject]()
    var gameTitles: Set<String>!
    var addGameTitles = Set<String>()
    
    var selectedIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getGames()
    }
    
    func getGames() {
        let query = PFQuery(className:"Game")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.games = objects!
                self.tableView.reloadData()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        let user = PFUser.currentUser()!
        var playerObjects = [PFObject]()
        for title in addGameTitles {
            for game in games {
                let gameTitle = game["title"] as! String
                if gameTitle == title {
                    let player = PFObject(className: "Player")
                    player["game"] = game
                    player["user"] = PFUser.currentUser()
                    player["character"] = "N/A"
                    player["gamertag"] = "None"
                    playerObjects.append(player)
                    break
                }
            }
        }
        PFObject.saveAllInBackground(playerObjects) { (success, error) -> Void in
            user.addUniqueObjectsFromArray(playerObjects, forKey: "players")
            user.saveInBackgroundWithBlock { (success, error) -> Void in
                self.performSegueWithIdentifier("backToGameSetting", sender: self)
            }
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.games.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("gameCell", forIndexPath: indexPath)
        let label = self.games[indexPath.row]["title"] as? String
        cell.textLabel?.text = label
        if self.gameTitles.contains(label!) || self.addGameTitles.contains(label!) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
        print(cell.textLabel?.text)
        
        if !gameTitles.contains((cell.textLabel?.text)!) {
            if cell.accessoryType == .Checkmark {
                self.addGameTitles.remove((cell.textLabel?.text)!)
            } else {
                self.addGameTitles.insert((cell.textLabel?.text)!)
            }
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    
}
