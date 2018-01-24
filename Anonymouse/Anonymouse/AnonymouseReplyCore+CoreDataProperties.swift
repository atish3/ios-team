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

    /// - Returns: The default `NSFetchRequest` object for this class.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnonymouseReplyCore> {
        return NSFetchRequest<AnonymouseReplyCore>(entityName: "AnonymouseReplyCore");
    }

    ///The date this reply was composed.
    @NSManaged public var date: NSDate?
    ///The text of the reply.
    @NSManaged public var text: String?
    ///1 if the the user liked this reply, 2 if the user disliked this reply; 0 otherwise.
    @NSManaged public var likeStatus: NSNumber?
    ///The integer rating of the reply.
    @NSManaged public var rating: NSNumber?
    ///The user that composed this reply.
    @NSManaged public var user: String?
    ///The parent message that this reply is replying to.
    @NSManaged public var parentMessage: AnonymouseMessageCore?
    ///The array that contains all the rating object hashes associated with this reply
    @NSManaged public var ratingHashes: [AnonymouseRatingSentCore]
    //The public key associated with the user
    @NSManaged public var pubKey: String?

}
