//
//  ResultDetails.swift
//  ShareASale
//
//  Created by Ryan Frey on 12/6/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import UIKit

class ResultDetails: UIViewController, UIWebViewDelegate {
    
    //MARK: - general keys and constants
    var user = PFUser()

    //MARK: - IBOutlets
    @IBOutlet weak var portrait: PFImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var org: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var Id: UILabel!
    @IBOutlet weak var detailView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let type = user.valueForKey("type") as String
        let userId = user.valueForKey("userProfile")?.valueForKey("shareasaleId") as String
        typeLabel.text = "\(type) #".capitalizedString
        portrait.file = user.valueForKey("UserPhoto")?.valueForKey("imageFile") as PFFile
        name.text = user.valueForKey("name") as? String
        org.text = user.valueForKey("userProfile")?.valueForKey("org") as? String
        Id.text = userId
        
        if type == "merchant"{
            //setup cobranded page webview since this is a merchant
            var coBrandedPageView = UIWebView(frame: self.view.frame)
            coBrandedPageView.scalesPageToFit = true
            detailView.addSubview(coBrandedPageView)
            var URL = NSURL(string: "http://shareasale.com/shareasale.cfm?merchantID=\(userId)")
            var request = NSURLRequest(URL: URL!)
            coBrandedPageView.loadRequest(request)
            
        }else if type == "affiliate"{
            
            
            
        }
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
