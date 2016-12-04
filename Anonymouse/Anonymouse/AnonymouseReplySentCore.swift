//
//  AnonymouseReplySentCore.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 12/3/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseReplySentCore: NSObject, NSCoding {
    var date: Date!
    var text: String!
    var user: String!
    var parentHash: String!
    
    convenience init(reply: AnonymouseReplyCore) {
        self.init()
        self.date = reply.date! as Date!
        self.text = reply.text!
        self.user = reply.user!
        self.parentHash = reply.parentMessage!.text!.sha1()
    }
    
    convenience init(text: String, date: Date, user: String, parentText: String) {
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
