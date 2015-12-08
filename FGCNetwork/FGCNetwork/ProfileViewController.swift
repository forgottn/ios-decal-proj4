//
//  ProfileViewController.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/23/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let imagePicker = UIImagePickerController()
    
    var profile = Player()
    var profileObject: PFObject!
    var isMyProfile: Bool = true
    
    var games = [PFObject]()
    
    var selectedIndex: Int!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var gameTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.gameTableView.dataSource = self
        self.gameTableView.delegate = self
        self.gameTableView.hidden = true
        
        if isMyProfile {
            getPlayerAndGames(PFUser.currentUser()!)
            profileImageView.userInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("imageTapped:"))
            profileImageView.addGestureRecognizer(tapRecognizer)
        } else {
            editButton.enabled = false
            editButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.clearColor()], forState: .Normal)
            getPlayerAndGames(self.profileObject!)
        }
    }
    
    func getPlayerAndGames(user: PFObject) {
        let query = PFUser.query()
        query?.includeKey("players")
        query?.getObjectInBackgroundWithId((user.objectId)!) {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                self.games = object!["players"] as! [PFObject]
                if self.games.count > 0 {
                    self.gameTableView.hidden = false
                    self.selectedIndex = 0
                }
                self.profile = Player(data: object!)
                self.profile.setBannerImage(self.bannerImageView)
                self.profile.setProfileImage(self.profileImageView)
                self.fullNameLabel.text = self.profile.fullName
                self.regionLabel.text = self.profile.region
                self.ageLabel.text = self.profile.age
                self.createScrollMenu()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        if isMyProfile {
            getPlayerAndGames(PFUser.currentUser()!)
            profileImageView.userInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: "imageTapped:")
            profileImageView.addGestureRecognizer(tapRecognizer)
        } else {
            editButton.enabled = false
            editButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.clearColor()], forState: .Normal)
            getPlayerAndGames(self.profileObject!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createScrollMenu() {
        
        var x = CGFloat(8.0)
        let sumOfButtonWidths = CGFloat(100.0 * Double(self.games.count))
        if sumOfButtonWidths < view.bounds.width {
            let remainingSpace = view.bounds.width - sumOfButtonWidths
            let leftPadding = remainingSpace / 2
            x = leftPadding
        }
        for (var i = 0; i < self.games.count; i++) {
            self.games[i]["game"].fetchIfNeededInBackgroundWithBlock{
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    let button = UIButton(frame: CGRectMake(x, 0, 100, 100))
                    //                    button.backgroundColor = UIColor.whiteColor()
                    let gameImageFile = object!.objectForKey("iosButtonImage") as! PFFile
                    gameImageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                let image = UIImage(data:imageData)
                                button.setImage(image, forState: .Normal)
                            }
                        }
                    }
                    //                    button.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    //                    button.setTitle(object!["title"] as? String, forState: .Normal)
                    button.tag = i
                    button.addTarget(self, action: "buttonAction:", forControlEvents: .TouchUpInside)
                    self.scrollView.addSubview(button)
                    x += button.frame.size.width
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
            
        }
        scrollView.showsHorizontalScrollIndicator = false
        if x < view.bounds.width {
            x = view.bounds.width + 1
        }
        scrollView.contentSize = CGSizeMake(x, scrollView.frame.size.height)
        self.gameTableView.reloadData()
    }
    
    func buttonAction(sender:UIButton!)
    {
        self.selectedIndex = sender.tag
        self.gameTableView.reloadData()
    }
    
    func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Remove Current Photo", style: UIAlertActionStyle.Destructive) { Void in
            self.profileImageView.image = UIImage(named: "no_profile_picture.jpg")
            PFUser.currentUser()!.removeObjectForKey("profilePicture")
            PFUser.currentUser()!.saveEventually()
            })
        alert.addAction(UIAlertAction(title: "Take Photo", style: .Default) { Void in
            self.loadCamera()
            })
        alert.addAction(UIAlertAction(title: "Choose From Library", style: .Default) { Void in
            self.loadImagePicker()
            })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func loadImagePicker() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func loadCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .Camera
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            imagePicker.cameraCaptureMode = .Photo
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.modalPresentationStyle = .FullScreen
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Image Picker View Controller Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let croppedImage = imageByScalingAndCroppingForSize(pickedImage, profileImageFrameSize: self.profileImageView.bounds.size)
            profileImageView.image = croppedImage
            
            let imageFile = PFFile(data: UIImageJPEGRepresentation(croppedImage, 1.0)!)
            PFUser.currentUser()!["profilePicture"] = imageFile
            PFUser.currentUser()?.saveInBackground()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageByScalingAndCroppingForSize(sourceImage: UIImage, profileImageFrameSize: CGSize) -> UIImage {
        let imageSize: CGSize = sourceImage.size
        let width: CGFloat = imageSize.width
        let height: CGFloat = imageSize.height
        
        let profileSize: CGSize = profileImageFrameSize
        let profileWidth: CGFloat = profileSize.width
        let profileHeight: CGFloat = profileSize.height
        
        var scaleFactor: CGFloat = 0.0
        var scaledWidth: CGFloat = profileWidth
        var scaledHeight: CGFloat = profileHeight
        
        var thumbnailPoint: CGPoint = CGPointMake(0, 0)
        
        if CGSizeEqualToSize(imageSize, profileSize) == false {
            let widthFactor: CGFloat = profileWidth / width
            let heightFactor: CGFloat = profileHeight / height
            
            if widthFactor > heightFactor {
                scaleFactor = widthFactor // Scale to fit height
            } else {
                scaleFactor = heightFactor // scale to fit width
            }
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            
            // Center the image
            if widthFactor > heightFactor {
                thumbnailPoint.y = (profileHeight - scaledHeight) * 0.5
            }
            if heightFactor > widthFactor {
                thumbnailPoint.x = (profileWidth - scaledWidth) * 0.5
            }
        }
        UIGraphicsBeginImageContext(profileSize)
        var thumbnailRect: CGRect = CGRectZero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight
        
        sourceImage.drawInRect(thumbnailRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        if newImage == nil {
            print("Error: Could not resize the image")
        }
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.gameTableView.dequeueReusableCellWithIdentifier("gametagChar", forIndexPath: indexPath)
        if self.games.count > 0 {
            self.games[selectedIndex].fetchIfNeededInBackgroundWithBlock{
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    cell.textLabel?.text = object!["gamertag"] as? String
                    cell.detailTextLabel?.text = object!["character"] as? String
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
        
        return cell
        
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toEdit" {
            let editTableViewController = segue.destinationViewController as! EditTableViewController
            editTableViewController.player = self.profile
        }
    }
    
}
