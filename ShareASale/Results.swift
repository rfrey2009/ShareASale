//
//  Results.swift
//  ShareASale
//
//  Created by Ryan Frey on 12/3/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import UIKit

class Results: PFQueryTableViewController, UISearchDisplayDelegate, UISearchBarDelegate {
    
    //MARK: - Constants
    let typeKey = "type"
    let stateKey = "usState"
    let userPhotoKey = "UserPhoto"
    let userProfileKey = "userProfile"
    let imageFileKey = "imageFile"
    let nameKey = "name"
    let orgKey = "org"
    let disallowedKey = "disallowed"
    let merchantKey = "merchant"
    let affiliateKey = "affiliate"
    let pointKey = "geoPoint"
    let bloggerKey = "blogger"
    let couponKey = "coupon"
    let ppcKey = "ppc"
    let incentiveKey = "incentive"
    let usaKey = "usa"
    //type depends on the segue identifier, and means what results we're looking for
    var type = ""
    var filteredUsers = [AnyObject]()
    //MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    //MARK: - Inits
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.parseClassName = "_User"
    }
    override init!(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
        self.parseClassName = "_User"
        self.textKey = "name"
        self.pullToRefreshEnabled = true;
        self.paginationEnabled = true;
        self.objectsPerPage = 20;
    }
    override func queryForTable() -> PFQuery! {
        var query = PFUser.query()
        //location
        let geoPoint = PFUser.currentUser().valueForKey(pointKey) as PFGeoPoint
        //user settings
        let isOrSeeksBlogger = PFUser.currentUser().valueForKey(bloggerKey) as Bool
        let isOrSeeksUsa = PFUser.currentUser().valueForKey(usaKey) as Bool
        let isOrSeeksPpc = PFUser.currentUser().valueForKey(ppcKey) as Bool
        let isOrSeeksIncentive = PFUser.currentUser().valueForKey(incentiveKey) as Bool
        let isOrSeeksCoupon = PFUser.currentUser().valueForKey(couponKey) as Bool

        //get either affiliates or merchants depending on who is looking at results
        query.whereKey(typeKey, equalTo: type)
        //merchant and affiliate both must have agreeing settings seeking one another
        query.whereKey(bloggerKey, equalTo: isOrSeeksBlogger)
        query.whereKey(usaKey, equalTo: isOrSeeksUsa)
        query.whereKey(ppcKey, equalTo: isOrSeeksPpc)
        query.whereKey(incentiveKey, equalTo: isOrSeeksIncentive)
        query.whereKey(couponKey, equalTo: isOrSeeksCoupon)
        //if a merchant is seeking affiliates, get those who aren't in a disallowed US state
        if type == affiliateKey{
            var disallowedRows = NSUserDefaults.standardUserDefaults().arrayForKey(disallowedKey) as Array<Int>!
            query.whereKey(stateKey, notContainedIn: disallowedRows)
        //if an affiliate is seeking merchants, get those who aren't disallowing their US state
        }else if type == merchantKey{
            var chosenState = NSUserDefaults.standardUserDefaults().integerForKey(stateKey) as Int!
            query.whereKey(disallowedKey, notEqualTo: chosenState)
        }
        //then get just nearby affs or merchants to the user
        query.whereKey(pointKey, nearGeoPoint: geoPoint)
        query.includeKey(userPhotoKey)
        return query
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchBar.placeholder = "filter \(type)s".capitalizedString
        
    }
    //MARK: - Protocol conformation
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredUsers.count
        } else {
            return self.objects.count
        }
    }
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        
        let identifier = "Cell"
        var cell = PFTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: identifier)
        if tableView == self.searchDisplayController!.searchResultsTableView {
            //we're on the searchbar tableview
            if !filteredUsers.isEmpty{
                //so grab the User object from the filteredUsers array instead of method argument's User object
                let object = filteredUsers[indexPath.row] as PFObject
                let thumbnail = object.valueForKey(userPhotoKey) as PFObject
                let userProfile: AnyObject? = object.valueForKey(userProfileKey)
                let org = userProfile?.valueForKey(orgKey) as String
                
                cell.textLabel?.text = (object.valueForKey(nameKey) as String)
                cell.detailTextLabel?.text = org
                cell.imageView.file = thumbnail.valueForKey(imageFileKey) as PFFile
                cell.imageView.image = UIImage(named: "default.png")
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                return cell

            }else{
                return cell
            }
        //we're on the main unfiltered tableview
        }else{
            let thumbnail = object.valueForKey(userPhotoKey) as PFObject
            let userProfile: AnyObject? = object.valueForKey(userProfileKey)
            let org = userProfile?.valueForKey(orgKey) as String
            
            cell.textLabel?.text = (object.valueForKey(nameKey) as String)
            cell.detailTextLabel?.text = org
            cell.imageView.file = thumbnail.valueForKey(imageFileKey) as PFFile
            cell.imageView.image = UIImage(named: "default.png")
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            //cell.backgroundColor = UIColor.blueColor()
            return cell
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("seeDetails", sender: tableView)
    }
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }
    //MARK: - helpers
    func filterContentForSearchText(searchText: String) {
        //Filter the array using the filter method
        self.filteredUsers = objects.filter { (user: AnyObject) -> Bool in
            
            let name = user.valueForKey("name") as String
            //userProfile its own object in case I wanted to add other filters from it later... just org for now
            let userProfile: AnyObject? = user.valueForKey("userProfile")
            let org = userProfile?.valueForKey("org") as String
            //the .lowercaseString prevents case sensitive search
            var orgMatch = org.lowercaseString.rangeOfString(searchText.lowercaseString)
            var stringMatch = name.lowercaseString.rangeOfString(searchText.lowercaseString)
            return (stringMatch != nil || orgMatch != nil)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "seeDetails" {
            let userDetailViewController = segue.destinationViewController as ResultDetails
            var indexPath = NSIndexPath()
            //check whether the segue is from the searchbar's tableview or the main tableview
            if sender as UITableView == self.searchDisplayController!.searchResultsTableView {
                //user searched and found result using search bar's tableview, use that index instead of main table view's
                indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!
            } else {
                indexPath = self.tableView.indexPathForSelectedRow()!
                //user didn't use search bar's tableview, so index into the pfquerytableview's main results array, self.objects
                filteredUsers = objects
            }
            
            userDetailViewController.user = filteredUsers[indexPath.row] as PFUser

            }
    }
}

