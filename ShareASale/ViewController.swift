//
//  ViewController.swift
//  ShareASale
//
//  Created by Ryan Frey on 11/8/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MerchantSettingsViewControllerDelegate, AffiliateSettingsViewControllerDelegate {
    
    //MARK: - Protocol conformation
    func settingsDidLogout(controller: UIViewController) {
        
        controller.navigationController?.popViewControllerAnimated(true)
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.guideBallThree.alpha = 0
            self.merchBtn.enabled = false
            self.affBtn.enabled = false
            
            }, completion: {(success: Bool) in
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.guideBallTwo.alpha = 0
                    
                    }, completion: {(success: Bool) in
                        
                        UIView.animateWithDuration(0.3, animations: {
                            
                            self.guideBallOne.alpha = 0
                            
                            }, completion: { (success: Bool) in
                                
                                self.fbLoginBtn.backgroundColor = UIColor(red: (47/255), green: (67/255), blue: (140/255), alpha: 1)
                                self.fbLoginBtn.enabled = true
                                
                        })
                })
                
        })
    }
    //MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "LoginToMerchantSettings"{
            let vc = segue.destinationViewController as MerchantSettings
            vc.delegate = self
        }
        if segue.identifier == "LoginToAffiliateSettings"{
            let vc = segue.destinationViewController as AffiliateSettings
            vc.delegate = self
        }
    }
    //MARK: - constants and variables
    //general reusable error pointer
    var errorPointer: NSError?
    //MARK: - IBOutlets
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var merchBtn: UIButton!
    @IBOutlet weak var affBtn: UIButton!
    @IBOutlet weak var guideBallOne: UIView!
    @IBOutlet weak var guideBallTwo: UIView!
    @IBOutlet weak var guideBallThree: UIView!
    //MARK: - IBActions
    @IBAction func loginWithFacebookPressed(sender: AnyObject) {
        
        let permissionsArray = ["public_profile", "email", "user_friends"]
        var errorMessage = ""
        
        self.loginActivityIndicator.startAnimating()
        
        PFFacebookUtils.logInWithPermissions(permissionsArray, block: { (currentUser, error) -> Void in
            
            if currentUser == nil{
                if error == nil{
                    println("Uh oh. The user cancelled the Facebook login.")
                    errorMessage = "Uh oh. You cancelled the Facebook login."
                }else{
                    println("Uh oh. Error occurred: \(error)")
                    errorMessage = error.localizedDescription
                }
                var alert = UIAlertController(title: "Log In Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                self.loginActivityIndicator.stopAnimating()
                self.fbLoginBtn.enabled = false
                self.fbLoginBtn.backgroundColor = UIColor.grayColor()
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.guideBallOne.alpha = 1.0
                    
                    }, completion: {(success: Bool) in
                        
                        UIView.animateWithDuration(0.3, animations: {
                        
                            self.guideBallTwo.alpha = 1.0
                        
                        }, completion: {(success: Bool) in
                            
                            UIView.animateWithDuration(0.3, animations: {
                                
                                self.guideBallThree.alpha = 1.0
                                
                                }, completion: { (success: Bool) in
                                    
                                    self.merchBtn.enabled = true
                                    self.affBtn.enabled = true
                            })
                        })
                    })
                if currentUser.isNew == true{
                    println("User with facebook signed up and logged in!")
                }else{
                    println("User with facebook logged in!")
                }
            }
            
        })
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loginActivityIndicator.stopAnimating()
        self.merchBtn.enabled = false
        self.affBtn.enabled = false
        //section skips login if user already logged in and sends them to the corresponding merchant/aff settings VC
        if (PFUser.currentUser() != nil && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser())){
            //make sure current session is up to date
            PFUser.currentUser().fetchInBackgroundWithBlock({ (currentUser, errorPointer) -> Void in
                let type = currentUser.valueForKey("type") as String
                //perform the right segue
                if type == "merchant"{
                    self.performSegueWithIdentifier("LoginToMerchantSettings", sender: self)
                }else if type == "affiliate"{
                    self.performSegueWithIdentifier("LoginToAffiliateSettings", sender: self)
                }
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

