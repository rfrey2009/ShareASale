//
//  MerchantSettings.swift
//  ShareASale
//
//  Created by Ryan Frey on 11/9/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

/*

TO DO: 

1. remove save bar button, change it to "see affiliates" bar button
2. remove save IBAction functionality. Make a new user on viewdidload, or update existing user in background if any field changes in one profile dictionary object
3. mirror profile pic in coredata locally, only upload profile pic to parse on user's new pic selection using uploadimage helper

*/

import Foundation
import UIKit
import MobileCoreServices

class MerchantSettings: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // MARK: - constants and variables
    let states = ["ALABAMA","ALASKA","ARIZONA","ARKANSAS","CALIFORNIA","COLORADO","CONNECTICUT","DELAWARE","DISTRICT OF COLUMBIA","FLORIDA","GEORGIA","HAWAII","IDAHO","ILLINOIS","INDIANA","IOWA","KANSAS","KENTUCKY","LOUISIANA","MAINE","MARYLAND","MASSACHUSETTS","MICHIGAN","MINNESOTA","MISSISSIPPI","MISSOURI","MONTANA","NEBRASKA","NEVADA","NEW HAMPSHIRE","NEW JERSEY","NEW MEXICO","NEW YORK","NORTH CAROLINA","NORTH DAKOTA","OHIO","OKLAHOMA","OREGON","PENNSYLVANIA","RHODE ISLAND","SOUTH CAROLINA","SOUTH DAKOTA","TENNESSEE","TEXAS","UTAH","VERMONT","VIRGINIA","WASHINGTON","WEST VIRGINIA","WISCONSIN","WYOMING"]
    
    let nameKey = "name"
    let merchantIDKey = "merchantID"
    let emailKey = "email"
    let bloggerKey = "blogger"
    let couponKey = "coupon"
    let ppcKey = "ppc"
    let incentiveKey = "incentive"
    let usaKey = "usa"
    let disallowedKey = "disallowed"
    let reuseableCell = "Cell"
    // MARK: - IBOutlets
    @IBOutlet var portrait: UIImageView!
    @IBOutlet var name: UITextField!
    @IBOutlet var merchantID: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bloggerSwitch: UISwitch!
    @IBOutlet var couponSwitch: UISwitch!
    @IBOutlet var ppcSwitch: UISwitch!
    @IBOutlet var incentiveSwitch: UISwitch!
    @IBOutlet var usaSwitch: UISwitch!
    // MARK: - IBActions
    
    //remove this
    @IBAction func saveBtn(sender: AnyObject) {
        
        if (self.merchantID.text != nil && self.name.text != "" && self.email.text != ""){
            
            PFGeoPoint.geoPointForCurrentLocationInBackground() { (point, error) -> Void in
                
                if error == nil{
                    
                    var currentUser = PFUser.currentUser()
                    var isNew = false
                    //we've got a new user to signup
                    if(currentUser == nil){
                        
                        currentUser = PFUser()
                        isNew = true
                        
                    }
                    
                    currentUser.username = self.merchantID.text
                    currentUser.password = self.name.text
                    currentUser.email = self.email.text
                    currentUser.setObject(self.name.text, forKey: "name")
                    currentUser.setObject(point, forKey: "geoPoint")
                    
                    //use update or signup method
                    if isNew{
                        //no reason to use with block, but just signUpInBackground() isn't available in Swift...
                        currentUser.signUpInBackgroundWithBlock({ (success, error) -> Void in
                            println("new user created on parse")
                        })
                        
                    }else{
                        //no reason to use with block, but just saveUpInBackground() isn't available in Swift...
                        currentUser.saveInBackgroundWithBlock({ (success, error) -> Void in
                            println("user updated on parse")
                        })
                        
                    }
                    self.performSegueWithIdentifier("MerchantSettingsToAffiliateResults", sender: self)
                    
                }
            }
            
        }else{
            var alert = UIAlertController(title: "Info Missing", message: "Please enter a merchant ID, name, and email address", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    @IBAction func handleImageUpdate(sender: UIImageView) {
        
        println("image tapped")
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            var image = UIImagePickerController()
            image.delegate = self
            image.sourceType = .SavedPhotosAlbum;
            image.allowsEditing = false
            
            self.presentViewController(image, animated: true, completion: nil)
        }
    
        
    }
    
    @IBAction func handleSingleTap(sender: AnyObject) {
        //dismisses keyboard when tapped out of text field
        self.view.endEditing(true)
        
    }
    //add parse saves next to each nsuserdefault save on field change
    @IBAction func nameChanged(sender: AnyObject) {
        
        if sender as NSObject == self.name{
            NSUserDefaults.standardUserDefaults().setObject(self.name.text, forKey: nameKey)
        }
    }
    @IBAction func merchantIDChanged(sender: AnyObject) {
        
        if sender as NSObject == self.merchantID{
            NSUserDefaults.standardUserDefaults().setObject(self.merchantID.text, forKey: merchantIDKey)
        }
    }
    @IBAction func emailChanged(sender: AnyObject) {
        
        if sender as NSObject == self.email{
            NSUserDefaults.standardUserDefaults().setObject(self.email.text, forKey: emailKey)
        }
    }
    @IBAction func bloggerSwitchChanged(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setBool(self.bloggerSwitch.on, forKey: bloggerKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    @IBAction func couponSwitchChanged(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setBool(self.couponSwitch.on, forKey: couponKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    @IBAction func ppcSwitchChanged(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setBool(self.ppcSwitch.on, forKey: ppcKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    @IBAction func incentiveSwitchChanged(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setBool(self.incentiveSwitch.on, forKey: incentiveKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    @IBAction func usaSwitchChanged(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setBool(self.usaSwitch.on, forKey: usaKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    // MARK: - inits
    override func viewDidLoad() {
        
        //add new user creation if necessary and save to parse
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseableCell)
        
        self.name.text = NSUserDefaults.standardUserDefaults().stringForKey(nameKey)
        self.merchantID.text = NSUserDefaults.standardUserDefaults().stringForKey(merchantIDKey)
        self.email.text = NSUserDefaults.standardUserDefaults().stringForKey(emailKey)
        
        self.bloggerSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(bloggerKey)
        self.couponSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(couponKey)
        self.ppcSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(ppcKey)
        self.incentiveSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(incentiveKey)
        self.usaSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(usaKey)
        /*
        self.portrait.image = //coredata image
        */
        var query = PFQuery(className: "UserPhoto")
        var currentUser = PFUser.currentUser()
        query.whereKey("user", equalTo: currentUser)
        query.findObjectsInBackgroundWithBlock { (object, error) -> Void in
            if object.count > 0{
                //first user photo object
                var userPhoto: PFObject = object[0] as PFObject
                //actual image object from that user photo object
                var imageFile: PFFile = userPhoto.objectForKey("imageFile") as PFFile
                //transformable data from imageFile object
                var imageData: NSData = imageFile.getData()
                //data to UIImage object
                var displayPhoto: UIImage = UIImage(data: imageData)!
                self.portrait.image = displayPhoto
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - delegates and data sources
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Disallowed States"
    }
    
    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int{
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.states.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseableCell, forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell
        cell.textLabel.text = self.states[indexPath.row]
        var disallowedRows = NSUserDefaults.standardUserDefaults().arrayForKey(disallowedKey) as Array<Int>!
        
        if disallowedRows != nil{
            if contains(disallowedRows, indexPath.row) {
                
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var disallowedIndexPaths = tableView.indexPathsForSelectedRows() as Array!
        var disallowedRows = [Int]()
        
        //get rows of selected states
        for indexPath in disallowedIndexPaths {
            
            disallowedRows.append(indexPath.row)
            
        }
        NSUserDefaults.standardUserDefaults().setObject(disallowedRows, forKey: disallowedKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        var disallowedIndexPaths = tableView.indexPathsForSelectedRows() as Array<NSIndexPath>!
        var disallowedRows = [Int]()
        
        if disallowedIndexPaths != nil{
            for indexPath in disallowedIndexPaths {
                
                disallowedRows.append(indexPath.row)
                
            }
        }
        NSUserDefaults.standardUserDefaults().setObject(disallowedRows, forKey: disallowedKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //crop
        UIGraphicsBeginImageContext(CGSizeMake(100, 120))
        image.drawInRect(CGRectMake(0, 0, 100, 120))
        var smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        //set immediate profile pic
        self.portrait.image = smallImage
        //upload
        var imageData = UIImageJPEGRepresentation(smallImage, 1.0);
        self.uploadImage(imageData)
        //save to coredata and refresh portrait uiimageview

        
    }
    
    //MARK: - Helpers
    func uploadImage(imageData: NSData){
        println("image is \(imageData.length) bytes!")
        var imageFile = PFFile(name: "Image.jpg", data: imageData)
        imageFile.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if error == nil{
            
                var currentUser = PFUser.currentUser()
                
                var userPhoto = PFObject(className: "UserPhoto")
                userPhoto.setObject(imageFile, forKey: "imageFile")
                userPhoto.ACL = PFACL(user: currentUser)
                userPhoto.setObject(currentUser, forKey: "user")
                //save
                userPhoto.saveInBackgroundWithBlock({ (success, error) -> Void in
                    println("Saved image to parse cloud")
                })
            }
        }
    }
}

