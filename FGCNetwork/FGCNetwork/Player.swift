//
//  Player.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/23/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import Foundation
import Parse

class Player {
    
    var object: PFObject!
    var profilePicture: PFFile!
    var bannerPicture : String!
    var fullName : String!
    var region : String!
    var age : String!
    var birthday : String!
    
    init() {
        self.bannerPicture = ""
        self.fullName = ""
        self.age = "N/A"
        self.region = "N/A"
        self.birthday = ""
        self.profilePicture = nil
    }
    
    init (data: PFObject) {
        self.object = data
        if let banner = data.objectForKey("profileBanner") {
            self.bannerPicture = banner as! String
        }
        if let firstName = data.objectForKey("firstName"),
            lastName = data.objectForKey("lastName") {
                self.fullName = (firstName as! String) + " " + (lastName as! String)
        } else {
            self.fullName = ""
        }
        if let parseAge = data.objectForKey("birthday") {
            self.birthday = dateToString(parseAge)
            self.age = String(findAgefromBirthday(parseAge as! NSDate))
        } else {
            self.birthday = ""
            self.age = "N/A"
        }
        if let region = data.objectForKey("region") {
            self.region = region as! String
        } else {
            self.region = "N/A"
        }
        if let profilePictureFile = data.objectForKey("profilePicture") as? PFFile {
            self.profilePicture = profilePictureFile
        } else {
            self.profilePicture = nil
        }
    }
    
    func saveData(region: String) {
    }
    
    func setBannerImage(image: UIImageView) {
        getImageFromConfig(image)
    }
    
    
    func getImageFromConfig(image: UIImageView) {
        PFConfig.getConfigInBackgroundWithBlock {
            (config: PFConfig?, error: NSError?) -> Void in
            let bannerPicture = config?.objectForKey(self.bannerPicture) as! PFFile
            bannerPicture.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        image.image = UIImage(data: imageData)
                    }
                }
            }
            
        }
    }
    
    func setProfileImage(image: UIImageView) {
        getImage(image)
    }
    
    func getImage(image: UIImageView) {
        if let profilePicture = self.profilePicture {
            profilePicture.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                if let imageData = imageData {
                    image.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    func findAgefromBirthday(birthdate: NSDate) -> Int {
        let today = NSDate()
        let age = NSCalendar.currentCalendar().components(.Year, fromDate: birthdate, toDate: today, options: [])
        return age.year
    }
    
    func dateToString(birthdate: AnyObject) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.stringFromDate(birthdate as! NSDate)
    }
    
    
}
