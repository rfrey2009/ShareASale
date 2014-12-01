//
//  userUpdates.swift
//  ShareASale
//
//  Created by Ryan Frey on 11/30/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MobileCoreServices

class userUpdates: NSObject, NSURLConnectionDataDelegate {
    //because real class vars not yet supported by Swift I'm using this struct hack...
    struct classVars {
        static var portrait: UIImageView!
        //current parse user
        static let currentUser = PFUser.currentUser()
        //general reusable error pointer
        static var errorPointer: NSError?
        //CoreData context
        static var managedObjectContext : NSManagedObjectContext? = {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                if let managedObjectContext = appDelegate.managedObjectContext {
                    return managedObjectContext
                }
                else {
                    return nil
                }
        }()
        static var imageData = NSMutableData()
        //general keys
        static let userSettingsKey = "userSettings"
        static let userProfileKey = "userProfile"
        static let userPhotoKey = "UserPhoto"
        static let imageFileKey = "imageFile"
        static let userKey = "user"
        static let geoPointKey = "geoPoint"
        static let typeKey = "type"
        static let nameKey = "name"
        static let firstNameKey = "firstName"
        static let lastNameKey = "lastName"
        static let genderKey = "gender"
        static let facebookIdKey = "facebookId"
        static let linkKey = "link"
        static let localeKey = "locale"
        static let timezoneKey = "timezone"
        static let lastUpdatedKey = "lastUpdated"
        static let idKey = "shareasaleId"
        static let orgKey = "org"
        static let emailKey = "email"
        static let bloggerKey = "blogger"
        static let couponKey = "coupon"
        static let ppcKey = "ppc"
        static let incentiveKey = "incentive"
        static let usaKey = "usa"
        static let disallowedKey = "disallowed"
        static let stateKey = "usState"
        static let reuseableCell = "Cell"
    }
    
    class func getUserImageFromCoreData() -> [NSManagedObject]?{
        
        let fetchRequest = NSFetchRequest(entityName: classVars.userPhotoKey)
        let sortDescriptor = NSSortDescriptor(key: classVars.userKey, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "user == %@", classVars.currentUser.objectId)
        fetchRequest.predicate = predicate
        
        let fetchedResults = classVars.managedObjectContext!.executeFetchRequest(fetchRequest, error: &classVars.errorPointer) as [NSManagedObject]?
        //should only be one user image but return all just in case...
        return fetchedResults
        
    }
    class func logOutShareASaleUser(){
        
        //delete user's CoreData local UserPhoto mirror
        let fetchedResults = getUserImageFromCoreData()
        if let results = fetchedResults {
            if results.isEmpty == false{
                classVars.managedObjectContext!.deleteObject(results[0])
                println("User's photo deleted from CoreData")
            }
        } else {
            println("Could not fetch \(classVars.errorPointer), \(classVars.errorPointer!.userInfo)")
        }
        //delete user's UserPhoto from parse upon log out
        var query = PFQuery(className: classVars.userPhotoKey)
        query.whereKey(classVars.userKey, equalTo: classVars.currentUser)
        query.getFirstObjectInBackgroundWithBlock { (UserPhoto, errorPointer) -> Void in
            
            if UserPhoto != nil{
                UserPhoto.deleteInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        //actually log user out
                        PFUser.logOut()
                        println("userPhoto deleted on parse and user logged out")
                    }
                })
            }else{
                println(classVars.errorPointer!.localizedDescription)
            }
            
        }
    }
    class func updateUser(userInfo: Dictionary<String, String>, userSettings: Dictionary<String, Bool>, portraitFromVC: UIImageView!){
        
        classVars.portrait = portraitFromVC
        var request = FBRequest.requestForMe()
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error == nil{
                let userDictionary = result as NSDictionary
                var userProfile = Dictionary<String,String>()
                
                let facebookId: String = userDictionary["id"] as String!
                userProfile[classVars.facebookIdKey] = facebookId
                let pictureURL : NSURL = NSURL(string: "https://graph.facebook.com/\(facebookId)/picture?type=large&return_ssl_source=1")!
                /*
                **Setup URL connection from pictureURL using requestImage() helper
                **NSURLRequest delegate method gets data
                **NSURLRequest finished downloading delegate method hits saveImageToParse() helper
                */
                self.requestImage(pictureURL)
                
                for (info, value) in userInfo{
                    if info == classVars.typeKey{
                        classVars.currentUser.setObject(value, forKey: classVars.typeKey)
                    }
                    if info == classVars.idKey{
                        userProfile[classVars.idKey] = value
                    }
                    if info == classVars.orgKey{
                        userProfile[classVars.orgKey] = value
                    }
                }
                
                if (userDictionary["name"] != nil){
                    classVars.currentUser.setObject(userDictionary["name"], forKey: classVars.nameKey)
                }
                if (userDictionary["email"] != nil){
                    classVars.currentUser.setObject(userDictionary["email"], forKey: classVars.emailKey)
                }
                if (userDictionary["first_name"] != nil){
                    userProfile[classVars.firstNameKey] = userDictionary["first_name"] as String!
                }
                if (userDictionary["last_name"] != nil){
                    userProfile[classVars.lastNameKey] = userDictionary["last_name"] as String!
                }
                if (userDictionary["gender"] != nil){
                    userProfile[classVars.genderKey] = userDictionary["gender"] as String!
                }
                if (userDictionary["link"] != nil){
                    userProfile[classVars.linkKey] = userDictionary["link"] as String!
                }
                if (userDictionary["locale"] != nil){
                    userProfile[classVars.localeKey] = userDictionary["locale"] as String!
                }
                if (userDictionary["timezone"] != nil){
                    userProfile[classVars.timezoneKey] = (userDictionary["timezone"] as NSNumber).stringValue
                }
                if (userDictionary["updated_time"] != nil){
                    userProfile[classVars.lastUpdatedKey] = userDictionary["updated_time"] as String!
                }
                for (setting, value) in userSettings{
                    classVars.currentUser.setObject(value, forKey: setting)
                }
                classVars.currentUser.setObject(userProfile, forKey: classVars.userProfileKey)
                //get user's current location
                PFGeoPoint.geoPointForCurrentLocationInBackground() { (point, error) -> Void in
                    
                    classVars.currentUser.setObject(point, forKey: classVars.geoPointKey)
                    classVars.currentUser.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if error == nil{
                            println("user updated on parse")
                        }
                    })
                }
            }else{
                println(error.localizedDescription)
            }
        }
    }
    class func saveImageToParse(imageData: NSData){
        println("image is \(imageData.length) bytes!")
        //mirror locally too
        saveImageToCoreData(imageData)
        
        var imageFile = PFFile(name: "Image.jpg", data: imageData)
        var query = PFQuery(className: classVars.userPhotoKey)
        query.whereKey(classVars.userKey, equalTo: classVars.currentUser)
        query.getFirstObjectInBackgroundWithBlock { (userPhoto, error) -> Void in
            //already has a photo, so just update existing on parse
            if error == nil{
                userPhoto.setObject(imageFile, forKey: classVars.imageFileKey)
                userPhoto.saveInBackgroundWithBlock({ (success, error) -> Void in
                    println("Updated existing userPhoto to parse cloud")
                })
            //has no photo, so upload a new one to parse
            }else{
                var userPhoto = PFObject(className: classVars.userPhotoKey)
                userPhoto.setObject(imageFile, forKey: classVars.imageFileKey)
                userPhoto.ACL = PFACL(user: classVars.currentUser)
                userPhoto.setObject(classVars.currentUser, forKey: classVars.userKey)
                //save
                userPhoto.saveInBackgroundWithBlock({ (success, error) -> Void in
                    println("Saved new userPhoto to parse cloud")
                })
            }
        }
    }
    class func requestImage(pictureURL: NSURL){
        var query = PFQuery(className: classVars.userPhotoKey)
        query.whereKey(classVars.userKey, equalTo: classVars.currentUser)
        query.countObjectsInBackgroundWithBlock { (number, error) -> Void in
            if number == 0{
                //clean out old imageData if any
                classVars.imageData.length = 0
                //User has no image saved in parse yet, so download the user's facebook profile image and save to parse & coredata
                var request = NSURLRequest(URL: pictureURL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 4.0)
                var urlConnection = NSURLConnection(request: request, delegate: self)
                if urlConnection == nil{
                    println("Failed to download picture...")
                }
            }
        }
    }
    class func saveImageToCoreData(imageData: NSData){
        
        let fetchedResults = getUserImageFromCoreData()
        
        if let results = fetchedResults {
            //if user has a no picture mirrored locally yet
            if results.isEmpty == true{
                let entity = NSEntityDescription.entityForName(classVars.userPhotoKey, inManagedObjectContext: classVars.managedObjectContext!)
                let newUserPhoto = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: classVars.managedObjectContext!)
                newUserPhoto.setValue(classVars.currentUser.objectId, forKey: classVars.userKey)
                newUserPhoto.setValue(imageData, forKey: classVars.imageFileKey)
                
                if !classVars.managedObjectContext!.save(&classVars.errorPointer) {
                    println("Could not save \(classVars.errorPointer), \(classVars.errorPointer?.userInfo)")
                }else{
                    println("Saved new user image locally to CoreData")
                    
                }
                //if they do have a local mirrored pic, update it instead of adding new one
            }else{
                results[0].setValue(classVars.currentUser.objectId, forKey: classVars.userKey)
                results[0].setValue(imageData, forKey: classVars.imageFileKey)
                if !classVars.managedObjectContext!.save(&classVars.errorPointer) {
                    println("Could not save \(classVars.errorPointer), \(classVars.errorPointer?.userInfo)")
                }else{
                    println("Saved existing user image locally to CoreData")
                }
            }
        classVars.portrait.image = UIImage(data: imageData)
        }else {
            println("Could not fetch \(classVars.errorPointer), \(classVars.errorPointer!.userInfo)")
        }
        
    }
    class func saveSettingToParseAndNSUserDefaults (forKey: String, value: Any){
        //switch flipped by user
        if value is Bool {
            
            NSUserDefaults.standardUserDefaults().setBool(value as Bool, forKey: forKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            classVars.currentUser.setObject(value as Bool, forKey: forKey)
            classVars.currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
                println("user's \(forKey) changed on parse as type BOOL")
            }
            //org or account ID changed by user
        }else if value is String{
            
            NSUserDefaults.standardUserDefaults().setObject(value as String, forKey: forKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            var userProfile = classVars.currentUser.valueForKey(classVars.userProfileKey)! as Dictionary<String, String>
            userProfile[forKey] = value as? String
            classVars.currentUser.setObject(userProfile, forKey: classVars.userProfileKey)
            classVars.currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
                println("user's \(forKey) changed on parse as type STRING")
            }
            //user state changed by affiliate user
        }else if value is Int{
            
            NSUserDefaults.standardUserDefaults().setInteger(value as Int, forKey: forKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            classVars.currentUser.setObject(value as Int, forKey: classVars.stateKey)
            classVars.currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
                println("user's \(forKey) changed on parse as type INT")
            }
            //merchant disallowed states changed by merchant user
        }else if value is [Int]{
            
            NSUserDefaults.standardUserDefaults().setObject(value as [Int], forKey: forKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            classVars.currentUser.setObject(value as [Int], forKey: classVars.disallowedKey)
            classVars.currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
                println("user's \(forKey) changed on parse as type ARRAY")
            }
            
        }
    }
    class func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        classVars.imageData.appendData(data)
        println("Got some image data")
        
    }
    class func connectionDidFinishLoading(connection: NSURLConnection) {
        println("Tried to upload image")
        self.saveImageToParse(classVars.imageData)
    }

}