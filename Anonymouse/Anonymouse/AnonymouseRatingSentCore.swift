//
//  AnonymouseRatingSentCore.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 11/11/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

///A sublcass of `NSObject` that conforms to `NSCoding`. This class is used to send rating objects to nearby peers.
class AnonymouseRatingSentCore: NSObject, NSCoding {
    ///The integer rating of the message.
    var rating: Int?
    ///The sha1() hash of the text of the message this rating corresponds to.
    var messageHash: String!
    
    /**
     Initialize a sent rating object from a stored message.
     
     - Parameters:
        - message: The message from which to create a rating object.
     */
    convenience init(message: AnonymouseMessageCore) {
        self.init()
        self.rating = message.rating!.intValue
        self.messageHash = message.text!.sha1()
    }

    /**
     Intialize a sent rating object from a stored reply.
     
    - Parameters: 
        - reply: The reply from which to create a rating object.
     */
    convenience init(reply: AnonymouseReplyCore) {
        self.init()
        self.rating = reply.rating!.intValue
        self.messageHash = reply.text!.sha1()
    }
    
    /**
     Intialize a sent rating object with rating `rating` and parent `messageHash`.
     
     - Parameters:
        - rating: The integer rating of the message.
        - messageHash: the sha1() hash of the text of the message that this rating corresponds to.
    */
    convenience init(rating: Int, messageHash: String) {
        self.init()
        self.rating = rating
        self.messageHash = messageHash
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        let unarchivedRating: Int = aDecoder.decodeInteger(forKey: "rating")
        let unarchivedHash: String = aDecoder.decodeObject(forKey: "messageHash") as! String
        
        self.rating = unarchivedRating
        self.messageHash = unarchivedHash
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.rating!, forKey: "rating")
        aCoder.encode(self.messageHash!, forKey: "messageHash")
    }
    
}
