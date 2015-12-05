//
//  GameViewController.swift
//  FGCNetwor

//
//  Created by Jason nghe on 11/23/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import Parse
import UIKit

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // ***
    // TWO THINGS TO SET PER GAME SEGUE
    var game: Dictionary<NSObject, AnyObject>!
    
    var selectedIndex: Int!
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
        configureSearchController()
        
        self.tableView.separatorStyle = .None
        self.tableView.estimatedRowHeight = tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationController?.title = game["game"]!["title"] as? String!
        self.navigationController?.navigationBar.translucent = false
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
    
    func refreshUI() {
        self.tableView.reloadData()
    }
    
    @IBAction func segmentTapped(sender: AnyObject) {
        refreshUI()
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
    
    // MARK: - Table View Delegates & Datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.game["game"]!["characters"]! as! Array<String>).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("characterCell", forIndexPath: indexPath)
        cell.textLabel!.font = UIFont(name: "SF-UI-Text-Medium.otf", size: 16)
        let characters = self.game["game"]!["characters"] as! Array<String>
        cell.textLabel!.text = characters[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.selectedIndex = indexPath.row
        performSegueWithIdentifier("toPlayerList", sender: self)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 43
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let playerListViewController = segue.destinationViewController as? PlayerListViewController {
            if segue.identifier == "toPlayerList" {
                playerListViewController.character = ((self.game["game"] as! PFObject).valueForKey("characters") as! Array<String>)[selectedIndex]
                playerListViewController.game = self.game["game"] as! PFObject
            }
        }
        
    }
    
}
