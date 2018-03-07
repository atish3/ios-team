//
//  AnonymouseRatingCore.swift
//  Anonymouse
//
//  Created by Atishay Singh on 2/14/18.
//  Copyright © 2018 1AM. All rights reserved.
//

import CoreData
import UIKit

class AnonymouseRatingCore:NSManagedObject{
    convenience init (rating: Int, parent: String, date: Date){
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.dataController.managedObjectContext
        let entity: NSEntityDescription? = NSEntityDescription.entity(forEntityName: "AnonymouseRatingCore", in: managedContext)
        self.init(entity: entity!, insertInto: managedContext)
        self.rating = rating as NSNumber
        self.parent = parent
        self.date = date as NSDate
    }
}
