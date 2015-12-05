//
//  EditTableViewController.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/23/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit
import Parse

class EditTableViewController: UITableViewController {
    
    var player: Player!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    
    var settingToPass: Setting!
    var selection: (key: String, value: AnyObject)! {
        didSet {
            updateUser()
        }
    }
    
    func updateUser() {
        if selection.key == "birthday" {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            birthdayLabel.text = dateFormatter.stringFromDate(selection.value as! NSDate)
        }
        
        
        let user = PFUser.currentUser()!
        user[selection.key] = selection.value
        user.saveInBackground()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        nameLabel.text = player.fullName
        regionLabel.text = player.region
        birthdayLabel.text = player.birthday
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Profile"
        } else {
            return "Manage"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if indexPath.section == 0 {
            let title = cell?.textLabel?.text
            let value = cell?.detailTextLabel?.text
            if cell?.tag == 2 {
                self.settingToPass = Setting(title: title!, input: value!, inputType: (cell?.tag)!, array: PFConfig.currentConfig()[title!.lowercaseString] as! [String])
            } else {
                self.settingToPass = Setting(title: title!, input: value!, inputType: (cell?.tag)!, array: [])
            }
            performSegueWithIdentifier("toSetting", sender: self)
        } else if indexPath.section == 1 {
            
        }
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
            print(self.settingToPass.title)
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
