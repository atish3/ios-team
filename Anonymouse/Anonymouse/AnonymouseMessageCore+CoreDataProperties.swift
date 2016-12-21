//
//  AnonymouseMessageCore+CoreDataProperties.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 11/29/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import Foundation
import CoreData


extension AnonymouseMessageCore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnonymouseMessageCore> {
        return NSFetchRequest<AnonymouseMessageCore>(entityName: "AnonymouseMessageCore");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var isFavorite: NSNumber?
    @NSManaged public var likeStatus: NSNumber?
    @NSManaged public var rating: NSNumber?
    @NSManaged public var text: String?
    @NSManaged public var user: String?
    @NSManaged public var ownedMessages: NSSet?

}

// MARK: Generated accessors for ownedMessages
extension AnonymouseMessageCore {

    @objc(addOwnedMessagesObject:)
    @NSManaged public func addToOwnedMessages(_ value: AnonymouseReplyCore)

    @objc(removeOwnedMessagesObject:)
    @NSManaged public func removeFromOwnedMessages(_ value: AnonymouseReplyCore)

    @objc(addOwnedMessages:)
    @NSManaged public func addToOwnedMessages(_ values: NSSet)

    @objc(removeOwnedMessages:)
    @NSManaged public func removeFromOwnedMessages(_ values: NSSet)

}
