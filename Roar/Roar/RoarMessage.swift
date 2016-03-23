//
//  RoarMessage.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

//The core data necessary for a message
class RoarMessageCore: NSObject, NSCoding {
    var date: NSDate
    var text: String
    var user: String
    
    init(text: String, date: NSDate, user: String) {
        self.text = text
        self.date = date
        self.user = user
        
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let unarchivedDate = aDecoder.decodeObjectForKey("date") as! NSDate
        let unarchivedText = aDecoder.decodeObjectForKey("text") as! String
        let unarchivedUser = aDecoder.decodeObjectForKey("user") as! String
        
        self.init(text: unarchivedText, date: unarchivedDate, user: unarchivedUser)
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.date, forKey: "date")
        aCoder.encodeObject(self.text, forKey: "text")
        aCoder.encodeObject(self.user, forKey: "user")
    }
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURLMessage = DocumentsDirectory.URLByAppendingPathComponent("messageCore")
    static let ArchiveURLHash = DocumentsDirectory.URLByAppendingPathComponent("hash")
}

//Contains all of the necessary information to render a message within a table view cell. 
//Does not contain data needed to position that message within the table view cell
class RoarMessage {
    let message: RoarMessageCore
    
    let hideDate: Bool
    let dateFont: UIFont
    let dateBoldFont: UIFont
    let dateLabelHeight: CGFloat
    
    let messageFont: UIFont
    let messageLabelSize: CGSize
    
    let userFont: UIFont
    let userLabelSize: CGSize
    
    private let spacing:CGFloat = 10
    let cellHeight: CGFloat

    init(message: RoarMessageCore, hideDate: Bool) {
        self.message = message
        
        self.hideDate = hideDate
        self.dateLabelHeight = hideDate ? 0 : 20
        self.dateFont = UIFont(name: "Helvetica", size: 10.0)!
        self.dateBoldFont = UIFont(name: "Helvetica-Bold", size: 10.0)!
        
        self.messageFont = UIFont(name: "Helvetica", size: 14.0)!
        self.userFont = UIFont(name: "Helvetica-Bold", size: 12.0)!
        
        let userLabel = UILabel(frame: CGRectMake(0, 0, 260, CGFloat.max))
        userLabel.numberOfLines = 0
        userLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        userLabel.font = userFont
        userLabel.text = message.user
        userLabel.sizeToFit()
        self.userLabelSize = userLabel.frame.size
        
        //Create a message label with the inputted text.
        //This message label is a "dummy label" and is never actually seen on screen.
        //Instead, it is used to calculate how big the text will be once it appears on screen.
        let messageLabel = UILabel(frame: CGRectMake(0, 0, 260, CGFloat.max))
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        messageLabel.font = messageFont
        messageLabel.text = message.text
        messageLabel.sizeToFit()
        //Use this "dummy" message label to tell what size our actual label should be
        self.messageLabelSize = messageLabel.frame.size
        //Notice that the messageLabel is never presented.
        
        //Add some extra padding for the message bubble cell
        self.cellHeight = self.messageLabelSize.height + self.userLabelSize.height + dateLabelHeight + spacing
    }
}