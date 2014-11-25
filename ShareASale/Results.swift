//
//  Results.swift
//  ShareASale
//
//  Created by Ryan Frey on 11/10/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import UIKit

class Results: UITableViewController {
    
    //MARK: - Constants
    let userKey = "user"
    let userSettingsKey = "userSettings"
    let typeKey = "type"
    let stateKey = "USstate"
    let disallowedKey = "disallowed"
    let merchantKey = "merchant"
    let affiliateKey = "affiliate"
    let pointKey = "geoPoint"
    let geoPoint = PFUser.currentUser().valueForKey("geoPoint") as PFGeoPoint
    //type depends on the segue identifier, and means what results we're looking for
    var type = ""
    var query = PFUser.query()
    var resultsCount = Int()
    
    //MARK: - Inits
    override func viewDidLoad() {
        super.viewDidLoad()
        //get either affiliates or merchants depending on who is looking at results
        query.whereKey(typeKey, equalTo: type)
        //merchant and affiliate both must have agreeing settings
        var userSettings: AnyObject = PFUser.currentUser().objectForKey(userSettingsKey)
        //query.whereKey(userSettingsKey, equalTo: userSettings)
        
        if type == affiliateKey{
            //if a merchant is seeking affiliates, get those who aren't in a disallowed US state
            var disallowedRows = NSUserDefaults.standardUserDefaults().arrayForKey(disallowedKey) as Array<Int>!
            query.whereKey(stateKey, notContainedIn: disallowedRows)
            
        }else if type == merchantKey{
            //if an affiliate is seeking merchants, get those who aren't disallowing their US state
            var chosenState = NSUserDefaults.standardUserDefaults().integerForKey(stateKey) as Int!
            println(chosenState)
            query.whereKey(disallowedKey, notEqualTo: chosenState)
        }
        //then get just nearby affs or merchants
        query.whereKey(pointKey, nearGeoPoint: geoPoint)
        query.getFirstObjectInBackgroundWithBlock { (user, error) -> Void in
            println(user)
        }
        
    }
    override func viewWillAppear(animated: Bool) {
        //reload table data here
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
