//
//  RoarMessageCore+CoreDataProperties.swift
//  Roar
//
//  Created by Pascal Sturmfels on 4/13/16.
//  Copyright © 2016 1AM. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension RoarMessageCore {

    @NSManaged var date: NSDate?
    @NSManaged var text: String?
    @NSManaged var user: String?

}
