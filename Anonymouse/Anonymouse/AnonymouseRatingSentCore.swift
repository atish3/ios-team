//
//  AnonymouseRatingSentCore.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 11/11/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseRatingSentCore: NSObject, NSCoding {
    var rating: Int?
    var messageHash: String!
    convenience init(message: AnonymouseMessageCore) {
        self.init()
        self.rating = message.rating!.intValue
        self.messageHash = message.text!.sha1()
    }

    convenience init(reply: AnonymouseReplyCore) {
        self.init()
        self.rating = reply.rating!.intValue
        self.messageHash = reply.text!.sha1()
    }
    
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
