//
//  MerchantSettings.swift
//  ShareASale
//
//  Created by Ryan Frey on 11/9/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import Foundation

class MerchantSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - constants and variables
    let states = ["ALABAMA","ALASKA","ARIZONA","ARKANSAS","CALIFORNIA","COLORADO","CONNECTICUT","DELAWARE","DISTRICT OF COLUMBIA","FLORIDA","GEORGIA","HAWAII","IDAHO","ILLINOIS","INDIANA","IOWA","KANSAS","KENTUCKY","LOUISIANA","MAINE","MARYLAND","MASSACHUSETTS","MICHIGAN","MINNESOTA","MISSISSIPPI","MISSOURI","MONTANA","NEBRASKA","NEVADA","NEW HAMPSHIRE","NEW JERSEY","NEW MEXICO","NEW YORK","NORTH CAROLINA","NORTH DAKOTA","OHIO","OKLAHOMA","OREGON","PENNSYLVANIA","RHODE ISLAND","SOUTH CAROLINA","SOUTH DAKOTA","TENNESSEE","TEXAS","UTAH","VERMONT","VIRGINIA","WASHINGTON","WEST VIRGINIA","WISCONSIN","WYOMING"]
    
    let nameKey = "name"
    let merchantIDKey = "merchantID"
    let orgKey = "org"
    let bloggerKey = "blogger"
    let couponKey = "coupon"
    let ppcKey = "ppc"
    let incentiveKey = "incentive"
    let usaKey = "usa"
    let disallowedKey = "disallowed"
    let reuseableCell = "Cell"
    // MARK: - IBOutlets
    @IBOutlet var tapper: UITapGestureRecognizer!
    @IBOutlet var name: UITextField!
    @IBOutlet var merchantID: UITextField!
    @IBOutlet var org: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bloggerSwitch: UISwitch!
    @IBOutlet var couponSwitch: UISwitch!
    @IBOutlet var ppcSwitch: UISwitch!
    @IBOutlet var incentiveSwitch: UISwitch!
    @IBOutlet var usaSwitch: UISwitch!
    // MARK: - IBActions
    @IBAction func handleSingleTap(sender: AnyObject) {
        
        self.view.endEditing(true)
        
    }
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
    @IBAction func orgChanged(sender: AnyObject) {
        
        if sender as NSObject == self.org{
            NSUserDefaults.standardUserDefaults().setObject(self.org.text, forKey: orgKey)
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
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseableCell)
        
        self.name.text = NSUserDefaults.standardUserDefaults().stringForKey(nameKey)
        self.merchantID.text = NSUserDefaults.standardUserDefaults().stringForKey(merchantIDKey)
        self.org.text = NSUserDefaults.standardUserDefaults().stringForKey(orgKey)

        
        self.bloggerSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(bloggerKey)
        self.couponSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(couponKey)
        self.ppcSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(ppcKey)
        self.incentiveSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(incentiveKey)
        self.usaSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(usaKey)
        
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
    
    //MARK: - Helpers
    
}


