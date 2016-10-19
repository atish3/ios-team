//
//  AnonymouseMigrationPolicy.swift
//  Anonymouse
//
//  Created by LiQinye on 10/19/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import Foundation
import CoreData

class AnonymouseMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        if sInstance.entity.name == "AnonymouseMessageCore" {
            let friendName = sInstance.primitiveValue(forKey: "user") as! String
            let friend = NSEntityDescription.insertNewObject(forEntityName: "AnonymouseFriends", into: manager.destinationContext)
            friend.setValue(friendName, forKey: "user")
        }
    }
}
