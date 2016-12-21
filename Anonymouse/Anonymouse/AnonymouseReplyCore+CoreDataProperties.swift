//
//  AnonymouseReplyCore+CoreDataProperties.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 11/29/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import Foundation
import CoreData


extension AnonymouseReplyCore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnonymouseReplyCore> {
        return NSFetchRequest<AnonymouseReplyCore>(entityName: "AnonymouseReplyCore");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var likeStatus: NSNumber?
    @NSManaged public var rating: NSNumber?
    @NSManaged public var user: String?
    @NSManaged public var parentMessage: AnonymouseMessageCore?

}
