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
    var rating: Int!
    var messageHash: String!
    
    //A subclass of NSObject that conforms to NSCoding Protocol.
    //This class is the type that is sent through MC
    
    convenience init(message: AnonymouseMessageCore) {
        self.init()
        self.date = message.date! as Date!
        self.text = message.text!
        self.user = message.user!
        self.rating = message.rating!.intValue
        self.messageHash = text.sha1()
    }
    
    convenience init(text: String, date: Date, user: String, rating: NSNumber) {
        self.init()
        
        self.date = date
        self.text = text
        self.user = user
        self.rating = rating.intValue
        self.messageHash = text.sha1()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        let unarchivedDate: Date = aDecoder.decodeObject(forKey: "date") as! Date
        let unarchivedText: String = aDecoder.decodeObject(forKey: "text") as! String
        let unarchivedUser: String = aDecoder.decodeObject(forKey: "user") as! String
        let unarchivedRating: Int = aDecoder.decodeObject(forKey: "rating") as! Int
        
        self.date = unarchivedDate
        self.text = unarchivedText
        self.user = unarchivedUser
        self.rating = unarchivedRating
        self.messageHash = text.sha1()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.date!, forKey: "date")
        aCoder.encode(self.text!, forKey: "text")
        aCoder.encode(self.user!, forKey: "user")
        aCoder.encode(self.rating!, forKey: "rating")
    }
}
