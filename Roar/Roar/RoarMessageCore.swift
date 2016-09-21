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
    
    //A subclass of NSManagedObject. This class is the type that is stored
    //in the core data model.
    convenience init(text: String, date: Date, user: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "RoarMessageCore", in: managedContext)
        self.init(entity: entity!, insertInto: managedContext)
        self.date = date
        self.text = text
        self.user = user
    }
}

class RoarMessageSentCore: NSObject, NSCoding {
    var date: Date!
    var text: String!
    var user: String!
    
    //A subclass of NSObject that conforms to NSCoding Protocol. 
    //This class is the type that is sent through MC
    
    convenience init(message: RoarMessageCore) {
        self.init()
        self.date = message.date! as Date!
        self.text = message.text!
        self.user = message.user!
    }
    
    convenience init(text: String, date: Date, user: String) {
        self.init()
        
        self.date = date
        self.text = text
        self.user = user
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        let unarchivedDate = aDecoder.decodeObject(forKey: "date") as! Date
        let unarchivedText = aDecoder.decodeObject(forKey: "text") as! String
        let unarchivedUser = aDecoder.decodeObject(forKey: "user") as! String
        self.date = unarchivedDate
        self.text = unarchivedText
        self.user = unarchivedUser
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.date!, forKey: "date")
        aCoder.encode(self.text!, forKey: "text")
        aCoder.encode(self.user!, forKey: "user")
    }
}


