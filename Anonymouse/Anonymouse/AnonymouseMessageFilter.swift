//
//  AnonymouseMessageFilter.swift
//  Anonymouse
//
//  Created by Chen, Shibo on 4/3/18.
//  Copyright © 2018 1AM. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AnonymouseMessageFilter: NSManagedObject {
    convenience init(sha: String) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.dataController.managedObjectContext
        let entity: NSEntityDescription? = NSEntityDescription.entity(forEntityName: "AnonymouseMessageFilter", in: managedContext)
        self.init(entity: entity!, insertInto: managedContext)
        self.sha_value = sha
    }
}
