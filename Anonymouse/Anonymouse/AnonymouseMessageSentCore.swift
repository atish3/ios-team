//
//  AnonymouseMessageSentCore.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 10/16/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseMessageSentCore: NSObject, NSCoding {
    var date: Date!
    var text: String!
    var user: String!
    var messageHash: String!
    
    //A subclass of NSObject that conforms to NSCoding Protocol. 
    //This class is the type that is sent through MC
    
    convenience init(message: AnonymouseMessageCore) {
        self.init()
        self.date = message.date! as Date!
        self.text = message.text!
        self.user = message.user!
        self.messageHash = text.sha1()
    }
    
    convenience init(text: String, date: Date, user: String) {
        self.init()
        
        self.date = date
        self.text = text
        self.user = user
        self.messageHash = text.sha1()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        let unarchivedDate: Date = aDecoder.decodeObject(forKey: "date") as! Date
        let unarchivedText: String = aDecoder.decodeObject(forKey: "text") as! String
        let unarchivedUser: String = aDecoder.decodeObject(forKey: "user") as! String
        self.date = unarchivedDate
        self.text = unarchivedText
        self.user = unarchivedUser
        self.messageHash = text.sha1()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.date!, forKey: "date")
        aCoder.encode(self.text!, forKey: "text")
        aCoder.encode(self.user!, forKey: "user")
    }
}
