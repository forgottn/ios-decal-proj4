//
//  LoginViewController.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/22/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4
import ParseTwitterUtils


class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let user = PFUser.currentUser()
        if ((user) != nil && (PFFacebookUtils.isLinkedWithUser(user!) || PFTwitterUtils.isLinkedWithUser(user!))) {
            self.presentGameListTableViewController()
        } else {
            self.view.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fbPressed(sender: AnyObject) {
        let permissions = ["public_profile", "email", "user_birthday"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    self.processNewUser(user)
                } else {
                    print("User logged in through Facebook!")
                }
                self.presentGameListTableViewController()
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    func processNewUser(user: PFUser) {
        let params : [NSObject : AnyObject] = ["fields": "birthday, email, first_name, last_name"]
        let request = FBSDKGraphRequest(graphPath: "me", parameters: params, HTTPMethod: "GET")
        request.startWithCompletionHandler({ (connection, result, error) -> Void in
            if error == nil {
                let firstName = result.objectForKey("first_name")
                let lastName = result.objectForKey("last_name")
                let birthday = result.objectForKey("birthday")
                let email = result.objectForKey("email")
                user["firstName"] = firstName
                user["lastName"] = lastName
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                print(birthday)
                print(dateFormatter.dateFromString(birthday as! String))
                user["birthday"] = dateFormatter.dateFromString(birthday as! String)
                if email != nil {
                    user["email"] = email
                }
                user["profileBanner"] = "profileBanner01"
                user["players"] = []
                user.saveInBackground()
                
            }
        })
    }
    
    @IBAction func twitterPressed(sender: AnyObject) {
        PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    self.processNewTwitterUser(user)
                } else {
                    print("User logged in with Twitter!")
                }
                self.presentGameListTableViewController()
            } else {
                print("Uh oh. The user cancelled the Twitter login.")
            }
        }
    }
    
    func processNewTwitterUser(user: PFUser) {
        
        let screenName = PFTwitterUtils.twitter()?.screenName!
        let requestString = NSURL(string: "https://api.twitter.com/1.1/users/show.json?screen_name=" + screenName!)
        let request = NSMutableURLRequest(URL: requestString!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
        PFTwitterUtils.twitter()?.signRequest(request)
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            print(data)
            print(response)
            print(error)
            
            if error == nil {
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    print(result)
                    let names = result.objectForKey("name") as! String
                    if names.characters.count > 0 {
                        var array = names.componentsSeparatedByString(" ")
                        user["lastName"] = array.last
                        array.removeLast()
                        
                        user["firstName"] = array.joinWithSeparator(" ")
                    }
                    user["profileBanner"] = "profileBanner01"
                    user["players"] = []
                    user.saveInBackground()
                    
                } catch let error as NSError {
                    print("ERROR: \(error.localizedDescription)")
                }
            }
        }).resume()

    }
    
    func presentGameListTableViewController() {
        performSegueWithIdentifier("goToGameList", sender: self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
