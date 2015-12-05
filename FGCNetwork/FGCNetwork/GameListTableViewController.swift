//
//  GameListTableViewController.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/22/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit
import Parse

class GameListTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    var gamesLoaded = 0
    var gamesArray = NSMutableArray()
    var gamesLength: Int!
    var selectedIndex: Int! = 0
    
    var searchController: UISearchController!
    var searchResults = [PFObject]()
    var shouldShowSearchResults = false
    var searchText: String! {
        didSet {
            self.searchResults.removeAll(keepCapacity: false)
            tableView.reloadData()
            refresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchImageforGamefromParse()
        
        configureSearchController()
        
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        self.tableView.separatorStyle = .None
        self.tableView.estimatedRowHeight = tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        self.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func refresh() {
        if self.searchText != nil {
            let searchText = self.searchText.lowercaseString
            let query = PFQuery(className:"Player")
            query.whereKey("gamertagLowercase", containsString: searchText)
            query.findObjectsInBackgroundWithBlock {
                (players: [PFObject]?, error: NSError?) -> Void in
                self.searchResults = players!
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchImageforGamefromParse() {
        let query = PFQuery(className: "Game")
        query.orderByDescending("position")
        query.whereKeyExists("title")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            self.gamesLength = objects!.count
            for object in objects! {
                let gameImageFile = object.objectForKey("iosMainImage") as! PFFile
                gameImageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        self.gamesLoaded += 1
                        if let imageData = imageData {
                            let image = UIImage(data:imageData)
                            
                            var gameDict = Dictionary<NSObject, AnyObject>()
                            gameDict["game"] = object
                            gameDict["image"] = image
                            self.gamesArray.addObject(gameDict)
                        }
                        if self.gamesLength == self.gamesArray.count {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                            }
                            
                        }
                    }
                }
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
        if shouldShowSearchResults {
            return searchResults.count
        }
        return self.gamesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if shouldShowSearchResults {
            let cell = tableView.dequeueReusableCellWithIdentifier("playerCell", forIndexPath: indexPath)
            cell.textLabel!.text = searchResults[indexPath.row]["gamertag"] as? String
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("gameCell", forIndexPath: indexPath)
        
        cell.imageView?.image = self.gamesArray[indexPath.row]["image"] as? UIImage
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        if shouldShowSearchResults {
            performSegueWithIdentifier("toProfile", sender: self)
        } else {
            performSegueWithIdentifier("toGame", sender: self)
        }
    }
    
    // MARK: - Search Bar Delegate
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.searchBar.text != "" {
            searchText = searchController.searchBar.text
        }
    }
    func willPresentSearchController(searchController: UISearchController) {
        self.navigationController!.navigationBar.translucent = true;
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.updateSearchResultsForSearchController(self.searchController)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.separatorStyle = .SingleLine
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.separatorStyle = .None
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.separatorStyle = .SingleLine
            tableView.reloadData()
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "toGame":
                let gameViewController = segue.destinationViewController as! GameViewController
                gameViewController.game = gamesArray[selectedIndex] as! Dictionary<NSObject, AnyObject>
            case "toProfile":
                let profileViewController = segue.destinationViewController as! ProfileViewController
                profileViewController.profileObject = self.searchResults[selectedIndex]["user"] as! PFObject
                profileViewController.isMyProfile = false
            default: break
            }
        }
    }
}
