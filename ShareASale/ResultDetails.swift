//
//  ResultDetails.swift
//  ShareASale
//
//  Created by Ryan Frey on 12/6/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import UIKit

class ResultDetails: UIViewController {
    
    //MARK: - general keys and constants
    var userPortrait = PFFile()
    var userName = ""
    var userOrg = ""
    var userId = ""
    //MARK: - IBOutlets
    @IBOutlet weak var portrait: PFImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var org: UILabel!
    @IBOutlet weak var Id: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        portrait.file = userPortrait
        name.text = userName
        org.text = userOrg
        Id.text = userId
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
