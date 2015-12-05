//
//  GameSettingTableViewController.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/24/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit
import Parse

class GameSettingTableViewController: UITableViewController {
    
    var games = [PFObject]()
    var gameTitles = Set<String>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.getPlayerGames()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.title = "Games"
    }
    
    func getPlayerGames() {
        
        let query = PFUser.query()
        query?.includeKey("players")
        query?.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                self.games = object!["players"] as! [PFObject]
                self.tableView.reloadData()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.tableView.editing {
            return 1
        } else {
            return 2
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 {
            return 1
        } else {
            return self.games.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("gameCell", forIndexPath: indexPath)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        if indexPath.section == 0 {
            cell.textLabel?.text = ""
            self.games[indexPath.row]["game"].fetchIfNeededInBackgroundWithBlock{
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    cell.textLabel?.text = object!["title"] as? String
                    self.gameTitles.insert((object!["title"] as? String)!)
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        } else if indexPath.section == 1 {
            cell.textLabel?.text = "Add New Game..."
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return " "
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if self.tableView.editing {
            if indexPath.section == 1 {
                self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
                return .None
            }
            return .Delete
        }
        return .None
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let object = games[indexPath.row]
            object.deleteInBackground()

            let user = PFUser.currentUser()!
            user.removeObject(object, forKey: "players")
            user.saveInBackground()
            
            games.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            performSegueWithIdentifier("toSingleGameSetting", sender: self)
        } else {
            performSegueWithIdentifier("toGameListSetting", sender: self)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toSingleGameSetting" {
            let singleGameSettingViewController = segue.destinationViewController as! SingleGameSettingTableViewController
            singleGameSettingViewController.playerInfo = self.games[self.tableView.indexPathForSelectedRow!.row]
        } else if segue.identifier == "toGameListSetting" {
            let gameListSettingViewController = segue.destinationViewController as! GameListSettingTableViewController
            gameListSettingViewController.gameTitles = self.gameTitles
        }
    }
    
    @IBAction func unwindWithNewAddedGames(segue:UIStoryboardSegue) {
        self.getPlayerGames()
    }


}
