//
//  RoarMessage.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

//Contains all of the necessary information to render a message within a table view cell. 
//Does not contain data needed to position that message within the table view cell
class RoarMessage {
    let message: RoarMessageCore
    
    let dateFont: UIFont
    let dateBoldFont: UIFont
    let dateLabelHeight: CGFloat
    
    let messageFont: UIFont
    let messageLabelSize: CGSize
    
    let userFont: UIFont
    let userLabelSize: CGSize
    
    fileprivate let spacing:CGFloat = 10
    let cellHeight: CGFloat

    init(message: RoarMessageCore) {
        self.message = message
        
        self.dateLabelHeight = 20
        self.dateFont = UIFont(name: "Helvetica", size: 10.0)!
        self.dateBoldFont = UIFont(name: "Helvetica-Bold", size: 10.0)!
        
        self.messageFont = UIFont(name: "Helvetica", size: 14.0)!
        self.userFont = UIFont(name: "Helvetica-Bold", size: 12.0)!
        
        let userLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 260, height: CGFloat.greatestFiniteMagnitude))
        userLabel.numberOfLines = 0
        userLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        userLabel.font = userFont
        userLabel.text = message.user
        userLabel.sizeToFit()
        self.userLabelSize = userLabel.frame.size
        
        //Create a message label with the inputted text.
        //This message label is a "dummy label" and is never actually seen on screen.
        //Instead, it is used to calculate how big the text will be once it appears on screen.
        let messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 260, height: CGFloat.greatestFiniteMagnitude))
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
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
