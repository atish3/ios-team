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
    var date: Date!
    ///The text of the message.
    var text: String!
    ///The user that composed the message.
    var user: String!
    ///The public key of the message sender
    var pubKey: String!
    
    
    /**
        Initialize a sent message object from a stored message object.
     
        - Parameters:
            - message: The stored message to send.
     */
    convenience init(message: AnonymouseMessageCore) {
        self.init()
        self.date = message.date! as Date!
        self.text = message.text!
        self.user = message.user!
        self.pubKey = message.pubKey!
    }
    
    /**
        Initialize a sent message object with the text `text`, date `date`, and user `user`.
     
        - Parameters:
            - text: The text of the message.
            - date: The date the message was composed.
            - user: The user that composed the message.
     */
    convenience init(text: String, date: Date, user: String, pubKey: String) {
        self.init()
        
        self.date = date
        self.text = text
        self.user = user
        self.pubKey = pubKey
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        let unarchivedDate: Date = aDecoder.decodeObject(forKey: "date") as! Date
        let unarchivedText: String = aDecoder.decodeObject(forKey: "text") as! String
        let unarchivedUser: String = aDecoder.decodeObject(forKey: "user") as! String
        let unarchivedKey: String = aDecoder.decodeObject(forKey: "PublicKey") as! String
        
        self.date = unarchivedDate
        self.text = unarchivedText
        self.user = unarchivedUser
        self.pubKey = unarchivedKey
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.date!, forKey: "date")
        aCoder.encode(self.text!, forKey: "text")
        aCoder.encode(self.user!, forKey: "user")
        aCoder.encode(self.user!, forKey: "PublicKey")
    }
}
