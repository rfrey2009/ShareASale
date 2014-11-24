//
//  AffiliateSettings.swift
//  ShareASale
//
//  Created by Ryan Frey on 11/9/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

/*

TO DO:


*/

import Foundation
import UIKit
import CoreData
import MobileCoreServices

protocol AffiliateSettingsViewControllerDelegate{
    
    func settingsDidFinish(controller: UIViewController)
    
}

class AffiliateSettings: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLConnectionDataDelegate {
    // MARK: - constants and variables
    let states = ["ALABAMA","ALASKA","ARIZONA","ARKANSAS","CALIFORNIA","COLORADO","CONNECTICUT","DELAWARE","DISTRICT OF COLUMBIA","FLORIDA","GEORGIA","HAWAII","IDAHO","ILLINOIS","INDIANA","IOWA","KANSAS","KENTUCKY","LOUISIANA","MAINE","MARYLAND","MASSACHUSETTS","MICHIGAN","MINNESOTA","MISSISSIPPI","MISSOURI","MONTANA","NEBRASKA","NEVADA","NEW HAMPSHIRE","NEW JERSEY","NEW MEXICO","NEW YORK","NORTH CAROLINA","NORTH DAKOTA","OHIO","OKLAHOMA","OREGON","PENNSYLVANIA","RHODE ISLAND","SOUTH CAROLINA","SOUTH DAKOTA","TENNESSEE","TEXAS","UTAH","VERMONT","VIRGINIA","WASHINGTON","WEST VIRGINIA","WISCONSIN","WYOMING"]
    //current parse user
    let currentUser = PFUser.currentUser()
    //general reusable error pointer
    var errorPointer: NSError?
    //coredata context
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()
    //general keys
    let userSettingsKey = "userSettings"
    let userProfileKey = "userProfile"
    let userPhotoKey = "UserPhoto"
    let imageFileKey = "imageFile"
    let userKey = "user"
    let geoPointKey = "geoPoint"
    let typeKey = "type"
    let affiliateKey = "affiliate"
    let nameKey = "name"
    let firstNameKey = "firstName"
    let lastNameKey = "lastName"
    let genderKey = "gender"
    let facebookIDKey = "facebookID"
    let linkKey = "link"
    let localeKey = "locale"
    let timezoneKey = "timezone"
    let lastUpdatedKey = "lastUpdated"
    let affiliateIDKey = "affiliateID"
    let orgKey = "org"
    let emailKey = "email"
    let bloggerKey = "blogger"
    let couponKey = "coupon"
    let ppcKey = "ppc"
    let incentiveKey = "incentive"
    let usaKey = "usa"
    let stateKey = "USstate"
    let reuseableCell = "Cell"
    var delegate: AffiliateSettingsViewControllerDelegate? = nil
    var imageData = NSMutableData()
    // MARK: - IBOutlets
    @IBOutlet weak var portrait: UIImageView!
    @IBOutlet weak var org: UITextField!
    @IBOutlet weak var affiliateID: UITextField!
    @IBOutlet weak var pickerViewTitle: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var bloggerSwitch: UISwitch!
    @IBOutlet weak var couponSwitch: UISwitch!
    @IBOutlet weak var ppcSwitch: UISwitch!
    @IBOutlet weak var incentiveSwitch: UISwitch!
    @IBOutlet weak var usaSwitch: UISwitch!
    // MARK: - IBActions
    @IBAction func seeMerchants(sender: AnyObject) {
        
        if (self.affiliateID.text != nil && self.org.text != "" ){
            
            self.performSegueWithIdentifier("AffiliateSettingsToResults", sender: self)
            
        }else{
            var alert = UIAlertController(title: "Info Missing", message: "Please enter an affiliate ID and organization", preferredStyle: UIAlertControllerStyle.Alert)
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
    @IBAction func logoutBtnPressed(sender: AnyObject) {
        
        //delete user's coredata local UserPhoto mirror
        let fetchedResults = getUserImageFromCoreData()
        if let results = fetchedResults {
            if results.isEmpty == false{
                managedObjectContext!.deleteObject(results[0])
                println("User's photo deleted from CoreData")
            }
        } else {
            println("Could not fetch \(errorPointer), \(errorPointer!.userInfo)")
        }
        //delete user's UserPhoto from parse upon log out
        var query = PFQuery(className: userPhotoKey)
        query.whereKey(userKey, equalTo: self.currentUser)
        query.getFirstObjectInBackgroundWithBlock { (UserPhoto, errorPointer) -> Void in
            
            if UserPhoto != nil{
                UserPhoto.deleteInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        PFUser.logOut()
                        println("userPhoto deleted on parse")
                    }
                })
            }else{
                
                println(errorPointer.localizedDescription)
                
            }
            
        }
        //finally transition back to home screen and disable aff/affiliate buttons until fb re-login
        if (delegate != nil) {
            delegate!.settingsDidFinish(self)
        }
        
        
    }
    //add parse saves next to each nsuserdefault save on field change
    @IBAction func orgChanged(sender: AnyObject) {
        saveSettingToParseAndNSUserDefaults(orgKey, value: self.org.text)
    }
    @IBAction func affiliateIDChanged(sender: AnyObject) {
        saveSettingToParseAndNSUserDefaults(affiliateIDKey, value: self.affiliateID.text)
    }
    @IBAction func bloggerSwitchChanged(sender: AnyObject) {
        saveSettingToParseAndNSUserDefaults(bloggerKey, value: self.bloggerSwitch.on)
    }
    @IBAction func couponSwitchChanged(sender: AnyObject) {
        saveSettingToParseAndNSUserDefaults(couponKey, value: self.couponSwitch.on)
    }
    @IBAction func ppcSwitchChanged(sender: AnyObject) {
        saveSettingToParseAndNSUserDefaults(ppcKey, value: self.ppcSwitch.on)
    }
    @IBAction func incentiveSwitchChanged(sender: AnyObject) {
        saveSettingToParseAndNSUserDefaults(incentiveKey, value: self.incentiveSwitch.on)
    }
    @IBAction func usaSwitchChanged(sender: AnyObject) {
        saveSettingToParseAndNSUserDefaults(usaKey, value: self.usaSwitch.on)
        if usaSwitch.on == false{
            pickerView.userInteractionEnabled = true
            pickerView.alpha = 1.0
            pickerViewTitle.alpha = 1.0
        }else if usaSwitch.on == true{
            //disable and fade out the state picker if this isn't a US affiliate...
            pickerView.userInteractionEnabled = false
            pickerView.alpha = 0.6
            pickerViewTitle.alpha = 0.6
        }
    }
    // MARK: - inits
    override func viewDidLoad() {
        
        //add new user creation if necessary and save to parse
        super.viewDidLoad()
        //only way back is via logout button...
        self.navigationItem.hidesBackButton = true
        
        let fetchedResults = getUserImageFromCoreData()
        
        if let results = fetchedResults {
            if results.isEmpty == false{
                //initial portrait/avatar image is what's saved last from coredata locally
                self.portrait.image = UIImage(data: results[0].valueForKey(self.imageFileKey) as NSData)
                println("user's existing image from coredata was shown as portrait")
            }
        } else {
            println("Could not fetch \(errorPointer), \(errorPointer!.userInfo)")
        }
        
        self.org.text = NSUserDefaults.standardUserDefaults().stringForKey(orgKey)
        self.affiliateID.text = NSUserDefaults.standardUserDefaults().stringForKey(affiliateIDKey)
        
        self.bloggerSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(bloggerKey)
        self.couponSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(couponKey)
        self.ppcSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(ppcKey)
        self.incentiveSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(incentiveKey)
        self.usaSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(usaKey)
        
        updateUser()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //set the chosen state in the pickerview
        var chosenState :Int? = NSUserDefaults.standardUserDefaults().integerForKey(stateKey)
        pickerView.selectRow(chosenState!, inComponent: 0, animated: true)
        if usaSwitch.on == false{
            pickerView.userInteractionEnabled = true
            pickerView.alpha = 1.0
        }else if usaSwitch.on == true{
            //disable and fade out the state picker if this isn't a US affiliate...
            pickerView.userInteractionEnabled = false
            pickerView.alpha = 0.6
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - delegates and data sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return states[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        saveSettingToParseAndNSUserDefaults(stateKey, value: row)
    }
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        self.dismissViewControllerAnimated(true, completion: nil)
        //crop
        UIGraphicsBeginImageContext(CGSizeMake(100, 120))
        image.drawInRect(CGRectMake(0, 0, 100, 120))
        var smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        //upload
        var imageData = UIImageJPEGRepresentation(smallImage, 1.0);
        self.saveImageToParse(imageData) //also saves to coredata in the same func
        
    }
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        self.imageData.appendData(data)
        println("Got some image data")
        
    }
    func connectionDidFinishLoading(connection: NSURLConnection) {
        saveImageToParse(self.imageData)
        println("Tried to upload image")
    }
    //MARK: - Helpers
    func updateUser(){
        
        var request = FBRequest.requestForMe()
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error == nil{
                println(result)
                let userDictionary = result as NSDictionary
                var userProfile = Dictionary<String,String>()
                let userSettings = [self.bloggerKey: self.bloggerSwitch.on, self.couponKey: self.couponSwitch.on, self.ppcKey: self.ppcSwitch.on, self.incentiveKey: self.incentiveSwitch.on, self.usaKey: self.usaSwitch.on]
                
                let facebookID: String = userDictionary["id"] as String!
                userProfile[self.facebookIDKey] = facebookID
                let pictureURL : NSURL = NSURL(string: "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_source=1")!
                /*
                setup URL connection from pictureURL using requestImage() helper
                NSURLRequest delegate method gets data
                NSURLRequest finished downloading delegate method hits saveImageToParse() helper
                */
                self.requestImage(pictureURL)
                userProfile[self.orgKey] = self.org.text
                userProfile[self.affiliateIDKey] = self.affiliateID.text
                
                if (userDictionary["name"] != nil){
                    self.currentUser.setObject(userDictionary["name"], forKey: self.nameKey)
                }
                if (userDictionary["email"] != nil){
                    self.currentUser.setObject(userDictionary["email"], forKey: self.emailKey)
                }
                if (userDictionary["first_name"] != nil){
                    userProfile[self.firstNameKey] = userDictionary["first_name"] as String!
                }
                if (userDictionary["last_name"] != nil){
                    userProfile[self.lastNameKey] = userDictionary["last_name"] as String!
                }
                if (userDictionary["gender"] != nil){
                    userProfile[self.genderKey] = userDictionary["gender"] as String!
                }
                if (userDictionary["link"] != nil){
                    userProfile[self.linkKey] = userDictionary["link"] as String!
                }
                if (userDictionary["locale"] != nil){
                    userProfile[self.localeKey] = userDictionary["locale"] as String!
                }
                if (userDictionary["timezone"] != nil){
                    userProfile[self.timezoneKey] = (userDictionary["timezone"] as NSNumber).stringValue
                }
                if (userDictionary["updated_time"] != nil){
                    userProfile[self.lastUpdatedKey] = userDictionary["updated_time"] as String!
                }
                self.currentUser.setObject(userSettings, forKey: self.userSettingsKey)
                self.currentUser.setObject(userProfile, forKey: self.userProfileKey)
                self.currentUser.setObject(self.affiliateKey, forKey: self.typeKey)
                //get user's current location
                PFGeoPoint.geoPointForCurrentLocationInBackground() { (point, error) -> Void in
                    
                    self.currentUser.setObject(point, forKey: self.geoPointKey)
                    self.currentUser.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if error == nil{
                            println("user updated on parse")
                        }
                    })
                }
            }else{
                println(error.localizedDescription)
            }
        }
    }
    func saveImageToParse(imageData: NSData){
        println("image is \(imageData.length) bytes!")
        //mirror locally too
        saveImageToCoreData(imageData)
        
        var imageFile = PFFile(name: "Image.jpg", data: imageData)
        var query = PFQuery(className: userPhotoKey)
        query.whereKey(userKey, equalTo: self.currentUser)
        query.getFirstObjectInBackgroundWithBlock { (userPhoto, error) -> Void in
            //already has a photo, so just update existing on parse
            if error == nil{
                
                userPhoto.setObject(imageFile, forKey: self.imageFileKey)
                userPhoto.saveInBackgroundWithBlock({ (success, error) -> Void in
                    println("Updated existing userPhoto to parse cloud")
                })
                //has no photo, so upload a new one to parse
            }else{
                var userPhoto = PFObject(className: self.userPhotoKey)
                userPhoto.setObject(imageFile, forKey: self.imageFileKey)
                userPhoto.ACL = PFACL(user: self.currentUser)
                userPhoto.setObject(self.currentUser, forKey: self.userKey)
                //save
                userPhoto.saveInBackgroundWithBlock({ (success, error) -> Void in
                    println("Saved new userPhoto to parse cloud")
                })
            }
        }
    }
    func requestImage(pictureURL: NSURL){
        var query = PFQuery(className: userPhotoKey)
        query.whereKey(userKey, equalTo: self.currentUser)
        query.countObjectsInBackgroundWithBlock { (number, error) -> Void in
            if number == 0{
                //User has no image saved in parse yet, so download the user's facebook profile image and save to parse & coredata
                var request = NSURLRequest(URL: pictureURL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 4.0)
                var urlConnection = NSURLConnection(request: request, delegate: self)
                if urlConnection == nil{
                    println("Failed to download picture...")
                }
            }
        }
    }
    func saveImageToCoreData(imageData: NSData){
        
        let fetchedResults = getUserImageFromCoreData()
        
        if let results = fetchedResults {
            //if user has a no picture mirrored locally yet
            if results.isEmpty == true{
                let entity = NSEntityDescription.entityForName(self.userPhotoKey, inManagedObjectContext: managedObjectContext!)
                let newUserPhoto = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedObjectContext!)
                newUserPhoto.setValue(self.currentUser.objectId, forKey: self.userKey)
                newUserPhoto.setValue(imageData, forKey: self.imageFileKey)
                
                if !managedObjectContext!.save(&errorPointer) {
                    println("Could not save \(errorPointer), \(errorPointer?.userInfo)")
                }else{
                    println("Saved new user image locally to CoreData")
                    
                }
                //if they do have a local mirrored pic, update it instead of adding new one
            }else{
                results[0].setValue(self.currentUser.objectId, forKey: self.userKey)
                results[0].setValue(imageData, forKey: self.imageFileKey)
                if !managedObjectContext!.save(&errorPointer) {
                    println("Could not save \(errorPointer), \(errorPointer?.userInfo)")
                }else{
                    println("Saved existing user image locally to CoreData")
                }
            }
            self.portrait.image = UIImage(data: imageData)
        } else {
            println("Could not fetch \(errorPointer), \(errorPointer!.userInfo)")
        }
        
    }
    func getUserImageFromCoreData() -> [NSManagedObject]?{
        
        let fetchRequest = NSFetchRequest(entityName: self.userPhotoKey)
        let sortDescriptor = NSSortDescriptor(key: self.userKey, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "user == %@", self.currentUser.objectId)
        fetchRequest.predicate = predicate
        
        let fetchedResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: &errorPointer) as [NSManagedObject]?
        //should only be one user image but return all just in case...
        return fetchedResults
        
    }
    func saveSettingToParseAndNSUserDefaults (forKey: String, value: Any){
        
        if value is Bool {
            
            NSUserDefaults.standardUserDefaults().setBool(value as Bool, forKey: forKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            var userSettings = self.currentUser.valueForKey(userSettingsKey)! as Dictionary<String, Bool>
            userSettings[forKey] = value as? Bool
            self.currentUser.setObject(userSettings, forKey: self.userSettingsKey)
            self.currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
                println("user's \(forKey) changed on parse as type BOOL")
            }
        }else if value is String{
            
            NSUserDefaults.standardUserDefaults().setObject(value as String, forKey: forKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            var userProfile = self.currentUser.valueForKey(userProfileKey)! as Dictionary<String, String>
            userProfile[forKey] = value as? String
            self.currentUser.setObject(userProfile, forKey: self.userProfileKey)
            self.currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
                println("user's \(forKey) changed on parse as type STRING")
            }
        }else if value is Int{
            
            NSUserDefaults.standardUserDefaults().setInteger(value as Int, forKey: forKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            self.currentUser.setObject(value as Int, forKey: self.stateKey)
            self.currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
                println("user's \(forKey) changed on parse as type INT")
            }
            
        }
    }
    //MARK: - Segues
    
    
}

