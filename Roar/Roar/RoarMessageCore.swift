//
//  RoarMessageCore.swift
//  Roar
//
//  Created by Pascal Sturmfels on 4/13/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData


class RoarMessageCore: NSManagedObject {
    // Insert code here to add functionality to your managed object subclass
    
    convenience init(text: String, date: NSDate, user: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("RoarMessageCore", inManagedObjectContext: managedContext)
        self.init(entity: entity!, insertIntoManagedObjectContext: managedContext)
        self.date = date
        self.text = text
        self.user = user
    }
}

class RoarMessageSentCore: NSObject, NSCoding {
    var date: NSDate!
    var text: String!
    var user: String!
    
    
    convenience init(message: RoarMessageCore) {
        self.init()
        self.date = message.date!
        self.text = message.text!
        self.user = message.user!
    }
    
    convenience init(text: String, date: NSDate, user: String) {
        self.init()
        
        self.date = date
        self.text = text
        self.user = user
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        let unarchivedDate = aDecoder.decodeObjectForKey("date") as! NSDate
        let unarchivedText = aDecoder.decodeObjectForKey("text") as! String
        let unarchivedUser = aDecoder.decodeObjectForKey("user") as! String
        self.date = unarchivedDate
        self.text = unarchivedText
        self.user = unarchivedUser
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.date!, forKey: "date")
        aCoder.encodeObject(self.text!, forKey: "text")
        aCoder.encodeObject(self.user!, forKey: "user")
    }
}


