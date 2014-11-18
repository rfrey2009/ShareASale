//
//  MerchantSettings.swift
//  ShareASale
//
//  Created by Ryan Frey on 11/9/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

/*

TO DO: 

add disallowed states to userSettings on parse
update parse usersettings after each setting change

*/

import Foundation
import UIKit
import CoreData
import MobileCoreServices

protocol MerchantSettingsViewControllerDelegate{
    
    func myVCDidFinish(controller:MerchantSettings)
    
}

class MerchantSettings: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLConnectionDataDelegate {
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
    let merchantKey = "merchant"
    let nameKey = "name"
    let firstNameKey = "firstName"
    let lastNameKey = "lastName"
    let genderKey = "gender"
    let facebookIDKey = "facebookID"
    let linkKey = "link"
    let localeKey = "locale"
    let timezoneKey = "timezone"
    let lastUpdatedKey = "lastUpdated"
    let verifiedKey = "emailVerified"
    let merchantIDKey = "merchantID"
    let orgKey = "org"
    let emailKey = "email"
    let bloggerKey = "blogger"
    let couponKey = "coupon"
    let ppcKey = "ppc"
    let incentiveKey = "incentive"
    let usaKey = "usa"
    let disallowedKey = "disallowed"
    let reuseableCell = "Cell"
    var delegate: MerchantSettingsViewControllerDelegate? = nil
    var imageData = NSMutableData()
    // MARK: - IBOutlets
    @IBOutlet var portrait: UIImageView!
    @IBOutlet var org: UITextField!
    @IBOutlet var merchantID: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bloggerSwitch: UISwitch!
    @IBOutlet var couponSwitch: UISwitch!
    @IBOutlet var ppcSwitch: UISwitch!
    @IBOutlet var incentiveSwitch: UISwitch!
    @IBOutlet var usaSwitch: UISwitch!
    // MARK: - IBActions
    @IBAction func seeAffiliates(sender: AnyObject) {
        
        if (self.merchantID.text != nil && self.org.text != "" ){
            
                self.performSegueWithIdentifier("MerchantSettingsToAffiliateResults", sender: self)
            
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
    @IBAction func logoutBtnPressed(sender: AnyObject) {
        
        //delete user's UserPhoto from parse upon log out
        var query = PFQuery(className: userPhotoKey)
        query.whereKey(userKey, equalTo: self.currentUser)
        query.getFirstObjectInBackgroundWithBlock { (UserPhoto, errorPointer) -> Void in
            
            UserPhoto.deleteInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    PFUser.logOut()
                }
            })
            
        }
        //delete user's coredata local UserPhoto mirror too
        let fetchedResults = getUserImageFromCoreData()
        if let results = fetchedResults {
            if results.isEmpty == false{
                managedObjectContext!.deleteObject(results[0])
            }
        } else {
            println("Could not fetch \(errorPointer), \(errorPointer!.userInfo)")
        }
        //finally transition back to home screen and disable aff/merchant buttons until fb re-login
        if (delegate != nil) {
            delegate!.myVCDidFinish(self)
        }
        
        
    }
    //add parse saves next to each nsuserdefault save on field change
    @IBAction func orgChanged(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setObject(self.org.text, forKey: orgKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    @IBAction func merchantIDChanged(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setObject(self.merchantID.text, forKey: merchantIDKey)
        NSUserDefaults.standardUserDefaults().synchronize()
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
        
        let fetchedResults = getUserImageFromCoreData()
        
        if let results = fetchedResults {
            if results.isEmpty == false{
                //initial portrait/avatar image is what's saved last from coredata locally
                self.portrait.image = UIImage(data: results[0].valueForKey(self.imageFileKey) as NSData)
            }
        } else {
            println("Could not fetch \(errorPointer), \(errorPointer!.userInfo)")
        }
        
        self.org.text = NSUserDefaults.standardUserDefaults().stringForKey(orgKey)
        self.merchantID.text = NSUserDefaults.standardUserDefaults().stringForKey(merchantIDKey)
        
        self.bloggerSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(bloggerKey)
        self.couponSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(couponKey)
        self.ppcSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(ppcKey)
        self.incentiveSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(incentiveKey)
        self.usaSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(usaKey)
        
        updateUser()
      
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
            //reselect/highlight the disallowed rows
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
        //upload
        var imageData = UIImageJPEGRepresentation(smallImage, 1.0);
        self.saveImageToParse(imageData)
        //save to coredata and refresh portrait uiimageview

        
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
                userProfile[self.merchantIDKey] = self.merchantID.text

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
                if (userDictionary["emailVerified"] != nil){
                    self.currentUser.setObject(userDictionary["emailVerified"], forKey: self.verifiedKey)
                }
                self.currentUser.setObject(userSettings, forKey: self.userSettingsKey)
                self.currentUser.setObject(userProfile, forKey: self.userProfileKey)
                self.currentUser.setObject(self.merchantKey, forKey: self.typeKey)
                //get user's current location
                PFGeoPoint.geoPointForCurrentLocationInBackground() { (point, error) -> Void in
                    
                    self.currentUser.setObject(point, forKey: self.geoPointKey)
                    self.currentUser.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if error == nil{
                            println("user updated on parse")
                        }
                    })
                }
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
                }
            //if they do have a local mirrored pic, update it instead of adding new one
            }else{
                results[0].setValue(self.currentUser.objectId, forKey: self.userKey)
                results[0].setValue(imageData, forKey: self.imageFileKey)
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
    //MARK: - Segues
    
    
}

