//
//  MerchantSettings.swift
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

protocol MerchantSettingsViewControllerDelegate{
    
    func settingsDidFinish(controller:UIViewController)
    
}

class MerchantSettings: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // MARK: - constants and variables
    let states = ["ALABAMA","ALASKA","ARIZONA","ARKANSAS","CALIFORNIA","COLORADO","CONNECTICUT","DELAWARE","DISTRICT OF COLUMBIA","FLORIDA","GEORGIA","HAWAII","IDAHO","ILLINOIS","INDIANA","IOWA","KANSAS","KENTUCKY","LOUISIANA","MAINE","MARYLAND","MASSACHUSETTS","MICHIGAN","MINNESOTA","MISSISSIPPI","MISSOURI","MONTANA","NEBRASKA","NEVADA","NEW HAMPSHIRE","NEW JERSEY","NEW MEXICO","NEW YORK","NORTH CAROLINA","NORTH DAKOTA","OHIO","OKLAHOMA","OREGON","PENNSYLVANIA","RHODE ISLAND","SOUTH CAROLINA","SOUTH DAKOTA","TENNESSEE","TEXAS","UTAH","VERMONT","VIRGINIA","WASHINGTON","WEST VIRGINIA","WISCONSIN","WYOMING"]
    //general reusable error pointer
    var errorPointer: NSError?
    //general keys
    let imageFileKey = "imageFile"
    let typeKey = "type"
    let merchantKey = "merchant"
    let idKey = "shareasaleId"
    let orgKey = "org"
    let bloggerKey = "blogger"
    let couponKey = "coupon"
    let ppcKey = "ppc"
    let incentiveKey = "incentive"
    let usaKey = "usa"
    let disallowedKey = "disallowed"
    let reuseableCell = "Cell"
    var delegate: MerchantSettingsViewControllerDelegate? = nil
    // MARK: - IBOutlets
    @IBOutlet weak var portrait: UIImageView!
    @IBOutlet weak var org: UITextField!
    @IBOutlet weak var merchantID: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bloggerSwitch: UISwitch!
    @IBOutlet weak var couponSwitch: UISwitch!
    @IBOutlet weak var ppcSwitch: UISwitch!
    @IBOutlet weak var incentiveSwitch: UISwitch!
    @IBOutlet weak var usaSwitch: UISwitch!
    // MARK: - IBActions
    @IBAction func seeAffiliates(sender: AnyObject) {
        
        if (self.merchantID.text != nil && self.org.text != "" ){
            
                self.performSegueWithIdentifier("MerchantSettingsToResults", sender: self)
            
        }else{
            var alert = UIAlertController(title: "Info Missing", message: "Please enter a merchant ID and organization", preferredStyle: UIAlertControllerStyle.Alert)
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
        
        //do logout cleanup
        userUpdates.logOutShareASaleUser()
        //transition back to home screen and disable aff/merchant buttons until fb re-login
        if (delegate != nil) {
            delegate!.settingsDidFinish(self)
        }
        
    }
    //add parse saves next to each nsuserdefault save on field change
    @IBAction func orgChanged(sender: AnyObject) {
        userUpdates.saveSettingToParseAndNSUserDefaults(orgKey, value: self.org.text)
    }
    @IBAction func merchantIDChanged(sender: AnyObject) {
        userUpdates.saveSettingToParseAndNSUserDefaults(idKey, value: self.merchantID.text)
    }
    @IBAction func bloggerSwitchChanged(sender: AnyObject) {
        userUpdates.saveSettingToParseAndNSUserDefaults(bloggerKey, value: self.bloggerSwitch.on)
    }
    @IBAction func couponSwitchChanged(sender: AnyObject) {
        userUpdates.saveSettingToParseAndNSUserDefaults(couponKey, value: self.couponSwitch.on)
    }
    @IBAction func ppcSwitchChanged(sender: AnyObject) {
        userUpdates.saveSettingToParseAndNSUserDefaults(ppcKey, value: self.ppcSwitch.on)
    }
    @IBAction func incentiveSwitchChanged(sender: AnyObject) {
        userUpdates.saveSettingToParseAndNSUserDefaults(incentiveKey, value: self.incentiveSwitch.on)
    }
    @IBAction func usaSwitchChanged(sender: AnyObject) {
        userUpdates.saveSettingToParseAndNSUserDefaults(usaKey, value: self.usaSwitch.on)
    }
    // MARK: - inits
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //only way back is via logout button...
        self.navigationItem.hidesBackButton = true

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseableCell)
        
        let fetchedResults = userUpdates.getUserImageFromCoreData()
        
        if let results = fetchedResults {
            if results.isEmpty == false{
                //initial portrait/avatar image is what's saved last from coredata locally
                self.portrait.image = UIImage(data: results[0].valueForKey(self.imageFileKey) as NSData)
                println("user's existing image from CoreData was shown as portrait")
            }
        } else {
            println("Could not fetch \(errorPointer), \(errorPointer!.userInfo)")
        }
        //setup initial states of switches
        self.org.text = NSUserDefaults.standardUserDefaults().stringForKey(orgKey)
        self.merchantID.text = NSUserDefaults.standardUserDefaults().stringForKey(idKey)
        self.bloggerSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(bloggerKey)
        self.couponSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(couponKey)
        self.ppcSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(ppcKey)
        self.incentiveSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(incentiveKey)
        self.usaSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(usaKey)
        
        let userSettings = [self.bloggerKey: self.bloggerSwitch.on, self.couponKey: self.couponSwitch.on, self.ppcKey: self.ppcSwitch.on, self.incentiveKey: self.incentiveSwitch.on, self.usaKey: self.usaSwitch.on]
        
        userUpdates.updateUser([self.typeKey: self.merchantKey, self.idKey: self.merchantID.text, self.orgKey: self.org.text], userSettings: userSettings, portraitFromVC: self.portrait)
      
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
        cell.textLabel?.text = self.states[indexPath.row]
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
        userUpdates.saveSettingToParseAndNSUserDefaults(disallowedKey, value: disallowedRows)
        
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        var disallowedIndexPaths = tableView.indexPathsForSelectedRows() as Array<NSIndexPath>!
        var disallowedRows = [Int]()
        
        if disallowedIndexPaths != nil{
            for indexPath in disallowedIndexPaths {
                
                disallowedRows.append(indexPath.row)
                
            }
        }
        userUpdates.saveSettingToParseAndNSUserDefaults(disallowedKey, value: disallowedRows)
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
        userUpdates.saveImageToParse(imageData) //also saves to coredata in the same func
    }
    //MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let vc = segue.destinationViewController as Results

        if segue.identifier == "MerchantSettingsToResults"{
            vc.type = "affiliate"
        }
    }
    
}

