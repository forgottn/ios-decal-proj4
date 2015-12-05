//
//  SingleGameSettingTableViewController.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/25/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit
import Parse

class SingleGameSettingTableViewController: UITableViewController {
    
    var playerInfo: PFObject!
    var settingToPass: Setting!
    var selection: (key: String, value: AnyObject)! {
        didSet {
            playerInfo[selection.key] = selection.value as? String
            playerInfo["\(selection.key)Lowercase"] = (selection.value as? String)!.lowercaseString
            playerInfo.saveInBackground()
            update()
        }
    }
    
    @IBOutlet weak var gamertagLabel: UILabel!
    @IBOutlet weak var characterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if let gamertag = playerInfo.objectForKey("gamertag") {
            gamertagLabel.text = gamertag as? String
        } else {
            gamertagLabel.text = ""
        }
        if let character = playerInfo.objectForKey("character") {
            characterLabel.text = character as? String
        } else {
            characterLabel.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update() {
        switch selection.key {
        case "gamertag":
            gamertagLabel.text = selection.value as? String
        case "character":
            characterLabel.text = selection.value as? String
        default: break
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let title = cell?.textLabel?.text
        let value = cell?.detailTextLabel?.text
        if indexPath.row == 0 {
            self.settingToPass = Setting(title: title!, input: value!, inputType: (cell?.tag)!, array: [])
        } else if indexPath.row == 1 {
            let characters = self.playerInfo.objectForKey("game")?.objectForKey("characters") as! [String]
            self.settingToPass = Setting(title: title!, input: value!, inputType: (cell?.tag)!, array: characters)
        }
        performSegueWithIdentifier("toSetting", sender: self)
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
    
    // Configure the cell...
    
    return cell
    }
    */
    
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
        if segue.identifier == "toSetting" {
            let settingViewController = segue.destinationViewController as! SettingViewController
            settingViewController.setting = self.settingToPass
        }
    }
    
    @IBAction func unwindWithSelection(segue:UIStoryboardSegue) {
        if let settingViewController = segue.sourceViewController as? SettingViewController {
            if let selection = settingViewController.selection {
                self.selection = selection
            }
        }
    }
}
