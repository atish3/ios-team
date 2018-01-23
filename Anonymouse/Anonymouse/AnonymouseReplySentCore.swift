//
//  AnonymouseReplySentCore.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 12/3/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

///A sublcass of `NSObject` that conforms to `NSCoding`. This class is used to send replies to nearby peers.
class AnonymouseReplySentCore: NSObject, NSCoding {
    ///The date the reply was composed.
    @objc var date: Date!
    ///The text of the reply.
    @objc var text: String!
    ///The user that composed the reply.
    @objc var user: String!
    ///The sha1() hash of the text of the parent message, used to find the parent.
    @objc var parentHash: String!
    
    /**
        Initialize a sent reply object from a stored reply object.
     
        - Parameters:
            - reply: The stored reply to send.
     */
    @objc convenience init(reply: AnonymouseReplyCore) {
        self.init()
        self.date = reply.date! as Date!
        self.text = reply.text!
        self.user = reply.user!
        self.parentHash = reply.parentMessage!.text!.sha1()
    }
    
    /**
        Initialize a send reply object with the text `text`, date `date`, and user `user`.
    
        - Parameters:
            - text: The text of the reply.
            - date: The date the reply was composed.
            - user: The user that composed the reply.
            - parentText: The sha1() hash of the text of the parent message.
     */
    @objc convenience init(text: String, date: Date, user: String, parentText: String) {
        self.init()
        
        self.date = date
        self.text = text
        self.user = user
        self.parentHash = parentText.sha1()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        let unarchivedDate: Date = aDecoder.decodeObject(forKey: "date") as! Date
        let unarchivedText: String = aDecoder.decodeObject(forKey: "text") as! String
        let unarchivedUser: String = aDecoder.decodeObject(forKey: "user") as! String
        let unarchivedParent: String = aDecoder.decodeObject(forKey: "parentHash") as! String
        
        self.date = unarchivedDate
        self.text = unarchivedText
        self.user = unarchivedUser
        self.parentHash = unarchivedParent
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.date!, forKey: "date")
        aCoder.encode(self.text!, forKey: "text")
        aCoder.encode(self.user!, forKey: "user")
        aCoder.encode(self.parentHash!, forKey: "parentHash")
    }
}
