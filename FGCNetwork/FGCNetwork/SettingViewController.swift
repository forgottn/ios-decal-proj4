//
//  SettingViewController.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/24/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit
import Parse

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var settingTitle: UINavigationItem!
    @IBOutlet weak var settingDesc: UILabel!
    @IBOutlet weak var settingsTable: UITableView!
    
    var selectedIndex: Int!
    var selection: (key: String, value: AnyObject)!
    var selectedValue: AnyObject!
    
    var setting: Setting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.settingTitle.title = self.setting.title
        self.settingDesc.text = self.setting.desc
        self.settingsTable.delegate = self
        self.settingsTable.dataSource = self
        if self.setting.inputType == "table" {
            self.settingsTable.scrollEnabled = true
        }
    }
    
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        switch self.setting.inputType {
        case "date":
            selection = (self.setting.parseTitle, selectedValue)
        case "text":
            grabTextInputFromTextField()
            selection = (self.setting.parseTitle, selectedValue as! String)
        case "table":
            selection = (self.setting.parseTitle, self.setting.tableArray[selectedIndex])
        default: break
        }
        performSegueWithIdentifier("backToSelection", sender: self)
    }
    
    // MARK: - Table View Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.setting.inputType == "table" {
            return self.setting.tableArray.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        if self.setting.inputType == "table" {
            if self.selectedIndex != nil && self.selectedIndex == indexPath.row {
                self.selectedIndex = nil
            } else {
                self.selectedIndex = indexPath.row
            }
            self.settingsTable.reloadData()
        }
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = TextInputTableViewCell(style: .Default, reuseIdentifier: "settingCell")
        
        if self.setting.inputType == "date" {
            let datePicker = UIDatePicker()
            datePicker.setDate(NSDate(), animated: true)
            datePicker.addTarget(self, action: "updateTextView:", forControlEvents: .ValueChanged)
            datePicker.datePickerMode = UIDatePickerMode.Date
            cell.textLabel!.text = self.setting.inputString
            cell.textfield.inputView = datePicker
            
        } else if self.setting.inputType == "text" {
            cell.textfield.text = setting.inputString
            
        } else if self.setting.inputType == "table" {
            let tableCell = tableView.dequeueReusableCellWithIdentifier("settingCell", forIndexPath: indexPath)
            let label = self.setting.tableArray[indexPath.row]
            tableCell.textLabel?.text = label
            if self.selectedIndex != nil && self.selectedIndex == indexPath.row {
                tableCell.accessoryType = .Checkmark
            } else if self.selectedIndex == nil && self.setting.inputString == label {
                tableCell.accessoryType = .Checkmark
            } else {
                tableCell.accessoryType = .None
            }
            return tableCell
        }
        return cell
    }
    
    func updateTextView(sender: UIDatePicker) {
        let cell = self.settingsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TextInputTableViewCell
        cell.textLabel!.text = ""

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.textfield.text = dateFormatter.stringFromDate(sender.date)
        selectedValue = sender.date
    }
    
    func grabTextInputFromTextField() {
        let cell = self.settingsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TextInputTableViewCell
        selectedValue = cell.textfield.text
        print("Inputted String :\(selectedValue)")
    
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    
}
