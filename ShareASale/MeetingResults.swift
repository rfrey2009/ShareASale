//
//  MeetingResults.swift
//  ShareASale
//
//  Created by Ryan Frey on 12/13/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//
import Foundation
import UIKit
import MobileCoreServices


class MeetingResults: UIViewController, FloatRatingViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    //MARK: - general keys and constants
    var user = PFUser()
    var Note = PFObject(className: "Note")
    var noteKey = "Note"
    var ratingKey = "rating"
    var textKey = "text"
    var bizCardImageKey = "bizCardImage"
    var aboutUserKey = "aboutUser"
    var fromUserKey = "fromUser"
    //MARK: - IBOutlets
    @IBOutlet var starRating: FloatRatingView!
    @IBOutlet var notes: UITextView!
    @IBOutlet var bizCardImage: UIImageView!
    //MARK: - IBActions
    @IBAction func saveBizCard(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            println("Saving biz card")
            
            var screenSize = UIScreen.mainScreen().bounds.size
            var screenHeight = screenSize.height
            var screenWidth = screenSize.width
            
            var image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.Camera;
            image.mediaTypes = [kUTTypeImage]
            image.allowsEditing = false
            var overlay = UIView(frame: CGRectMake(screenWidth / 6, screenHeight / 3, 260, 190))
            overlay.backgroundColor = UIColor.clearColor()
            overlay.layer.borderWidth = 3
            overlay.layer.borderColor = UIColor.blueColor().CGColor
            //because the preview on uiimagepickercontroller jumps 20px down after taking a picture...
            var translate = CGAffineTransformMakeTranslation(0.0, 50.0)
            image.cameraViewTransform = translate

            image.cameraOverlayView = overlay;
            self.presentViewController(image, animated: true, completion: nil)
        }
    }
    @IBAction func handleSingleTap(sender: AnyObject) {
        //dismisses keyboard when tapped out of text field
        self.notes.endEditing(true)
        
    }
    //MARK: - inits
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForExistingOrCreateNote()
        
        self.starRating.delegate = self
        self.starRating.contentMode = UIViewContentMode.ScaleAspectFit
        self.notes.layer.borderColor = UIColor.grayColor().CGColor
        
        //Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Protocol Conformation
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating: Float) {
        
    }
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        println("Floatratingview delegate works")
        self.Note.setObject(rating, forKey: ratingKey)
        self.Note.saveInBackgroundWithBlock { (success, error) -> Void in
            if success{
                println("Updated Note's star rating")
            }
        }
        
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        println("I've got a biz card image!")
        var image = info[UIImagePickerControllerOriginalImage] as UIImage
        var screenSize = UIScreen.mainScreen().bounds.size
        var screenHeight = screenSize.height
        var screenWidth = screenSize.width
        var screenBounds = UIScreen.mainScreen().bounds
        UIGraphicsBeginImageContext(screenSize)
        image.drawInRect(screenBounds)
        var smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var cropRect = CGRectMake(screenWidth / 6, screenHeight / 3, 260, 190)
        //new cropped image
        var imageRef = CGImageCreateWithImageInRect(smallImage.CGImage, cropRect);
        bizCardImage.image = UIImage(CGImage: imageRef)
        bizCardImage.alpha = 1.0
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        //save it to parse associated with this note
        var parseImage = UIImageJPEGRepresentation(UIImage(CGImage: imageRef), 1.0)
        var imageFile = PFFile(name: "Image.jpg", data: parseImage)
        self.Note.setObject(imageFile, forKey: bizCardImageKey)
        self.Note.saveInBackgroundWithBlock { (success, error) -> Void in
            println("Saved biz card image to parse!")
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        println("Text view delegate works")
        self.Note.setObject(textView.text, forKey: textKey)
        self.Note.saveInBackgroundWithBlock { (success, error) -> Void in
            if success{
                println("Updated Note's text")
            }
        }
    }
    //MARK: - helpers
    func checkForExistingOrCreateNote(){
        //has this User made a note about the user they're viewing before?
        var query = PFQuery(className: noteKey)
        query.whereKey(aboutUserKey, equalTo: user)
        query.whereKey(fromUserKey, equalTo: PFUser.currentUser())
        query.getFirstObjectInBackgroundWithBlock { (Note, error) -> Void in
            if (Note == nil){
                self.Note.setObject(self.user, forKey: self.aboutUserKey)
                self.Note.setObject(PFUser.currentUser(), forKey: self.fromUserKey)
                self.Note.setObject(1.0, forKey: self.ratingKey)
                self.Note.setObject(self.notes.text, forKey: self.textKey)
                self.Note.ACL = PFACL(user: PFUser.currentUser())
                self.Note.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success{
                        println("Saved Note!")
                    }else if error != nil{
                        println(error)
                    }
                })
            }else{
                self.Note = Note
                self.notes.text = self.Note.valueForKey(self.textKey) as String
                self.starRating.rating = self.Note.valueForKey(self.ratingKey) as Float
                var image = self.Note.valueForKey(self.bizCardImageKey) as PFFile
                image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    var theImage = UIImage(data: data)
                    self.bizCardImage.image = theImage
                    self.bizCardImage.alpha = 1.0
                })
                println("Got an existing Note")
            }
        }
        
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
