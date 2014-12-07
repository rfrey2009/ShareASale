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

protocol AffiliateSettingsViewControllerDelegate{
    
    func settingsDidLogout(controller: UIViewController)
    
}

class AffiliateSettings: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLConnectionDataDelegate, AffiliateSettingsMoreInfoViewControllerDelegate {
    // MARK: - constants and variables
    let states = ["ALABAMA","ALASKA","ARIZONA","ARKANSAS","CALIFORNIA","COLORADO","CONNECTICUT","DELAWARE","DISTRICT OF COLUMBIA","FLORIDA","GEORGIA","HAWAII","IDAHO","ILLINOIS","INDIANA","IOWA","KANSAS","KENTUCKY","LOUISIANA","MAINE","MARYLAND","MASSACHUSETTS","MICHIGAN","MINNESOTA","MISSISSIPPI","MISSOURI","MONTANA","NEBRASKA","NEVADA","NEW HAMPSHIRE","NEW JERSEY","NEW MEXICO","NEW YORK","NORTH CAROLINA","NORTH DAKOTA","OHIO","OKLAHOMA","OREGON","PENNSYLVANIA","RHODE ISLAND","SOUTH CAROLINA","SOUTH DAKOTA","TENNESSEE","TEXAS","UTAH","VERMONT","VIRGINIA","WASHINGTON","WEST VIRGINIA","WISCONSIN","WYOMING"]
    //general reusable error pointer
    var errorPointer: NSError?
    //general keys
    let imageFileKey = "imageFile"
    let typeKey = "type"
    let affiliateKey = "affiliate"
    let idKey = "shareasaleId"
    let orgKey = "org"
    let bloggerKey = "blogger"
    let couponKey = "coupon"
    let ppcKey = "ppc"
    let incentiveKey = "incentive"
    let usaKey = "usa"
    let stateKey = "usState"
    let moreInfoKey = "moreInfo"
    let shareASaleBecauseKey = "shareASaleBecause"
    var delegate: AffiliateSettingsViewControllerDelegate? = nil
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
        
        //do logout cleanup
        userUpdates.logOutShareASaleUser()
        //transition back to home screen and disable aff/merchant buttons until fb re-login
        if (delegate != nil) {
            delegate!.settingsDidLogout(self)
        }
    }
    //add parse saves next to each nsuserdefault save on field change
    @IBAction func orgChanged(sender: AnyObject) {
        userUpdates.saveSettingToParseAndNSUserDefaults(orgKey, value: self.org.text)
    }
    @IBAction func affiliateIDChanged(sender: AnyObject) {
        userUpdates.saveSettingToParseAndNSUserDefaults(idKey, value: self.affiliateID.text)
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
    //MARK: - Protocol conformation
    func settingsDidCancel(controller: UIViewController){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func settingsDidSave(controller: UIViewController){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: - inits
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //only way back is via logout button...
        self.navigationItem.hidesBackButton = true
        
        let fetchedResults = userUpdates.getUserImageFromCoreData()
        
        if let results = fetchedResults {
            if results.isEmpty == false{
                //initial portrait/avatar image is what's saved last from coredata locally
                self.portrait.image = UIImage(data: results[0].valueForKey(self.imageFileKey) as NSData)
                println("User's existing image from coredata was shown as portrait")
            }
        } else {
            println("Could not fetch \(errorPointer), \(errorPointer!.userInfo)")
        }
        //setup initial states of switches
        self.org.text = NSUserDefaults.standardUserDefaults().stringForKey(orgKey)
        self.affiliateID.text = NSUserDefaults.standardUserDefaults().stringForKey(idKey)
        self.bloggerSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(bloggerKey)
        self.couponSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(couponKey)
        self.ppcSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(ppcKey)
        self.incentiveSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(incentiveKey)
        self.usaSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(usaKey)
        
        let userSettings = [self.bloggerKey: self.bloggerSwitch.on, self.couponKey: self.couponSwitch.on, self.ppcKey: self.ppcSwitch.on, self.incentiveKey: self.incentiveSwitch.on, self.usaKey: self.usaSwitch.on]
        var moreInfo = NSUserDefaults.standardUserDefaults().stringForKey(moreInfoKey) as String!
        var shareASaleBecause = NSUserDefaults.standardUserDefaults().stringForKey(shareASaleBecauseKey) as String!
        
        userUpdates.updateUser([self.typeKey: self.affiliateKey, self.idKey: self.affiliateID.text, self.orgKey: self.org.text, self.moreInfoKey: moreInfo, self.shareASaleBecauseKey: shareASaleBecause], userSettings: userSettings, portraitFromVC: self.portrait)
        
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
        userUpdates.saveSettingToParseAndNSUserDefaults(stateKey, value: row)
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
        
        if segue.identifier == "AffiliateSettingsToResults"{
            let vc = segue.destinationViewController as Results
            vc.type = "merchant"
        }
        if segue.identifier == "AffiliateSettingsToMoreInfo"{
            let vc = segue.destinationViewController as AffiliateSettingsMoreInfo
            vc.delegate = self
        }

    }
    
}

