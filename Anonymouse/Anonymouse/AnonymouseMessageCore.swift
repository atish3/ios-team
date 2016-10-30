//
//  AnonymouseMessageCore.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 4/13/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData

class AnonymouseMessageCore: NSManagedObject {
    // Insert code here to add functionality to your managed object subclass
    
    //A subclass of NSManagedObject. This class is the type that is stored
    //in the core data model.
    convenience init(text: String, date: Date, user: String) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.dataController.managedObjectContext
        let entity: NSEntityDescription? = NSEntityDescription.entity(forEntityName: "AnonymouseMessageCore", in: managedContext)
        self.init(entity: entity!, insertInto: managedContext)
        self.date = date
        self.text = text
        self.user = user
        self.rating = NSNumber(integerLiteral: 0)
        self.likeStatus = NSNumber(integerLiteral: 0)
        self.isFavorite = NSNumber(booleanLiteral: false)
    }
}
