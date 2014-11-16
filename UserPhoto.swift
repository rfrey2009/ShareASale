//
//  UserPhoto.swift
//  ShareASale
//
//  Created by Ryan Frey on 11/16/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import Foundation
import CoreData

class UserPhoto: NSManagedObject {

    @NSManaged var imageFile: AnyObject
    @NSManaged var user: String

}
