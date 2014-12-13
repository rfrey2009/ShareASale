//
//  MeetingResults.swift
//  ShareASale
//
//  Created by Ryan Frey on 12/13/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import UIKit

class MeetingResults: UIViewController, FloatRatingViewDelegate {

    //MARK: - IBOutlets
    @IBOutlet var starRating: FloatRatingView!
    @IBOutlet weak var notes: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.starRating.delegate = self
        self.starRating.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.notes.layer.borderColor = UIColor.grayColor().CGColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Protocol Conformation
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating: Float) {
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        
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
