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
    //whether the current logged in User invited this User
    var isInvitedByCurrentUser = Bool()
    //whether this User invited the current logged in User
    var isInvitedByUser = Bool()
    let inviteKey = "Invite"
    let fromUserKey = "fromUser"
    let toUserKey = "toUser"

    //MARK: - IBOutlets
    @IBOutlet weak var portrait: PFImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var org: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var Id: UILabel!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var inviteBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var navItem: UINavigationItem!
    //MARK: - IBActions
    @IBAction func inviteBtnPressed(sender: AnyObject) {
        
        var invite = PFObject(className: inviteKey)
        invite.setObject(PFUser.currentUser(), forKey: fromUserKey)
        invite.setObject(user, forKey: toUserKey)
        invite.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil{
                println("Invite saved to parse")
                //if the current User was already invited by this User, enable chat button
                if self.isInvitedByUser == true {
                    self.chatBtn.enabled = true
                }
                //disable invite button to prevent additional invites
                self.inviteBtn.enabled = false
                //trigger alert
                let type = self.user.valueForKey("type") as String
                var alert = UIAlertController(title: "Invite sent", message: "An invite has been sent to the \(type). If they send you an invite back, you'll be able to chat with them to meet!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    //MARK: - inits
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatBtn.enabled = (self.isInvitedByCurrentUser && self.isInvitedByUser)
        inviteBtn.enabled = !self.isInvitedByCurrentUser
        
        // Do any additional setup after loading the view.
        let type = user.valueForKey("type") as String
        let userId = user.valueForKey("userProfile")?.valueForKey("shareasaleId") as String
        typeLabel.text = "\(type) #".capitalizedString
        portrait.file = user.valueForKey("UserPhoto")?.valueForKey("imageFile") as PFFile
        name.text = user.valueForKey("name") as? String
        org.text = user.valueForKey("userProfile")?.valueForKey("org") as? String
        Id.text = userId
        self.navItem.title = user.valueForKey("name") as? String
        //setup bios
        if type == "merchant"{
            //setup cobranded page webview since this is a merchant
            var coBrandedPageView = UIWebView(frame: self.view.frame)
            coBrandedPageView.scalesPageToFit = true
            detailView.addSubview(coBrandedPageView)
            var URL = NSURL(string: "http://shareasale.com/shareasale.cfm?merchantID=\(userId)")
            var request = NSURLRequest(URL: URL!)
            coBrandedPageView.loadRequest(request)
        //since this is an affiliate, setup their bio instead of co-branded webview
        }else if type == "affiliate"{
            var moreInfoView = UILabel(frame: CGRectMake(8.0,0.0,272.0,123.0))
            moreInfoView.text = user.valueForKey("userProfile")?.valueForKey("moreInfo") as? String
            moreInfoView.numberOfLines = 0
            moreInfoView.sizeToFit()
            
            var shareASaleBecauseView = UILabel(frame: CGRectMake(8.0,131.0,272.0,145.0))
            shareASaleBecauseView.text = user.valueForKey("userProfile")?.valueForKey("shareASaleBecause") as? String
            shareASaleBecauseView.numberOfLines = 0
            shareASaleBecauseView.sizeToFit()

            detailView.addSubview(moreInfoView)
            detailView.addSubview(shareASaleBecauseView)
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if segue.identifier == "ResultDetailsToChat"{
        
            let chatVC = segue.destinationViewController as Chat
            chatVC.withUser = user
        }
        if segue.identifier == "ResultDetailsToNotes"{
            let notesVC = segue.destinationViewController as MeetingResults
            notesVC.user = user
        }
    }
}
