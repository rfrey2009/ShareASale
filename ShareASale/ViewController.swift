//
//  ViewController.swift
//  ShareASale
//
//  Created by Ryan Frey on 11/8/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MerchantSettingsViewControllerDelegate {
    
    //MARK: - Protocol conformation
    
    func myVCDidFinish(controller: MerchantSettings) {
        self.merchBtn.enabled = false
        self.affBtn.enabled = false
        controller.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "LoginToMerchantSettings"{
            let vc = segue.destinationViewController as MerchantSettings
            vc.delegate = self
        }
    }

    //MARK: - IBOutlets
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var merchBtn: UIButton!
    @IBOutlet weak var affBtn: UIButton!
    
    //MARK: - IBActions
    @IBAction func loginWithFacebookPressed(sender: AnyObject) {
        
        let permissionsArray = ["public_profile", "email", "user_friends"]
        var errorMessage = ""
        
        self.loginActivityIndicator.startAnimating()
        
        PFFacebookUtils.logInWithPermissions(permissionsArray, block: { (currentUser, error) -> Void in
            
            if currentUser == nil{
                if error == nil{
                    println("Uh oh. The user cancelled the Facebook login.")
                    errorMessage = "Uh oh. The user cancelled the Facebook login."
                }else{
                    println("Uh oh. Error occurred: \(error)")
                    errorMessage = error.localizedDescription
                }
                var alert = UIAlertController(title: "Log In Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                self.loginActivityIndicator.stopAnimating()
                self.merchBtn.enabled = true
                self.affBtn.enabled = true
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
    }
    override func viewDidAppear(animated: Bool) {
        
        //skip login if user already logged in
        if (PFUser.currentUser() != nil && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser())){
            
            self.performSegueWithIdentifier("LoginToMerchantSettings", sender: self)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

