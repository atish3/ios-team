//
//  AnonymouseMessageSentCore.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 10/16/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

///A subclass of `NSObject` that conforms to `NSCoding`. This class is used to send messages to nearby peers.
class AnonymouseMessageSentCore: NSObject, NSCoding {
    ///The date the message was composed.
    @objc var date: Date!
    ///The text of the message.
    @objc var text: String!
    ///The user that composed the message.
    @objc var user: String!
    
    
    /**
        Initialize a sent message object from a stored message object.
     
        - Parameters:
            - message: The stored message to send.
     */
    @objc convenience init(message: AnonymouseMessageCore) {
        self.init()
        self.date = message.date! as Date!
        self.text = message.text!
        self.user = message.user!
    }
    
    /**
        Initialize a sent message object with the text `text`, date `date`, and user `user`.
     
        - Parameters:
            - text: The text of the message.
            - date: The date the message was composed.
            - user: The user that composed the message.
     */
    @objc convenience init(text: String, date: Date, user: String) {
        self.init()
        
        self.date = date
        self.text = text
        self.user = user
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        let unarchivedDate: Date = aDecoder.decodeObject(forKey: "date") as! Date
        let unarchivedText: String = aDecoder.decodeObject(forKey: "text") as! String
        let unarchivedUser: String = aDecoder.decodeObject(forKey: "user") as! String
        
        self.date = unarchivedDate
        self.text = unarchivedText
        self.user = unarchivedUser
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.date!, forKey: "date")
        aCoder.encode(self.text!, forKey: "text")
        aCoder.encode(self.user!, forKey: "user")
    }
}
