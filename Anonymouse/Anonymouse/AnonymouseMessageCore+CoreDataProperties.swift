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

    /// - Returns: The default `NSFetchRequest` object for this class.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnonymouseMessageCore> {
        return NSFetchRequest<AnonymouseMessageCore>(entityName: "AnonymouseMessageCore");
    }
    
    ///The date of the sent message.
    @NSManaged public var date: NSDate?
    ///`true` if this message has been favorited by the user.
    @NSManaged public var isFavorite: NSNumber?
    ///1 if the user has liked the message, 2 if the user has disliked, 0 otherwise.
    @NSManaged public var likeStatus: NSNumber?
    ///The integer rating of this message.
    @NSManaged public var rating: NSNumber?
    ///The text of this message.
    @NSManaged public var text: String?
    ///The user that composed this message.
    @NSManaged public var user: String?
    ///The replies to this message.
    @NSManaged public var ownedMessages: NSSet?
    //The number of replies to the message
    @NSManaged public var numReplies: NSNumber?

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

extension AnonymouseMessageFilter{
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnonymouseMessageFilter> {
        return NSFetchRequest<AnonymouseMessageFilter>(entityName: "AnonymouseMessageFilter");
    }
    @NSManaged public var sha_value: String
}
