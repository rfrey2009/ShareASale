//
//  AffiliateSettingsMoreInfo.swift
//  ShareASale
//
//  Created by Ryan Frey on 12/5/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import UIKit

protocol AffiliateSettingsMoreInfoViewControllerDelegate{
    
    func settingsDidCancel(controller: UIViewController)
    func settingsDidSave(controller: UIViewController)
    
}

class AffiliateSettingsMoreInfo: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    //general keys and constants
    var delegate: AffiliateSettingsMoreInfoViewControllerDelegate? = nil
    let moreInfoKey = "moreInfo"
    let shareASaleBecauseKey = "shareASaleBecause"
    //MARK: - Protocol conformation
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return "Ryan Frey"
    }
    //MARK: - IBActions
    @IBAction func cancelPressed(sender: AnyObject) {
        self.delegate?.settingsDidCancel(self)
    }
    @IBAction func handleSingleTap(sender: AnyObject) {
        //dismisses keyboard when tapped out of text field
        self.view.endEditing(true)
        
    }
    @IBAction func donePressed(sender: AnyObject) {
        userUpdates.saveSettingToParseAndNSUserDefaults(moreInfoKey, value: infoTextView.text)
        userUpdates.saveSettingToParseAndNSUserDefaults(shareASaleBecauseKey, value: shareASaleTextView.text)
        self.delegate?.settingsDidSave(self)
    }
    //MARK: - IBOutlets
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var shareASaleTextView: UITextView!
    //MARK: - inits
    override func viewDidLoad() {
        super.viewDidLoad()
        //set border colors (can't be done in runtime attributes)
        self.infoTextView.layer.borderColor = UIColor.grayColor().CGColor
        self.shareASaleTextView.layer.borderColor = UIColor.grayColor().CGColor
        
        var infoTextViewText = NSUserDefaults.standardUserDefaults().stringForKey(moreInfoKey) as String!
        var shareASaleTextViewText = NSUserDefaults.standardUserDefaults().stringForKey(shareASaleBecauseKey) as String!
        
        if infoTextViewText == nil || infoTextViewText == ""{
            infoTextView.text = "Enter more information about your company, strategy, and promotional methods."
        }else{
            infoTextView.text = infoTextViewText
        }
        if shareASaleTextViewText == nil  || shareASaleTextViewText == ""{
            shareASaleTextView.text = "In a few sentences, what do you love about ShareASale?"
        }else{
            shareASaleTextView.text = shareASaleTextViewText
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
