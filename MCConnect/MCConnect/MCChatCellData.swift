//
//  MCChatCellData.swift
//  MCConnect
//
//  Created by Pascal Sturmfels on 1/25/16.
//  Copyright © 2016 Pascal Sturmfels. All rights reserved.
//

import UIKit


//Contains all of the necessary information to render a message within a table view cell. 
//Does not contain data needed to position that message within the table view cell (see MCChatTableViewCell)
class MCChatMessageData {
    let message: MCChatMessage
    
    let hideDate: Bool
    let dateFont: UIFont
    let dateBoldFont: UIFont
    let dateLabelHeight: CGFloat
    
    let messageFont: UIFont
    let messageLabelSize: CGSize
    
    private let spacing:CGFloat = 15
    let cellHeight: CGFloat

    init(message: MCChatMessage, hideDate: Bool)
    {
        self.message = message
        
        self.hideDate = hideDate
        self.dateLabelHeight = hideDate ? 0 : 20
        self.dateFont = UIFont(name: "Helvetica", size: 10.0)!
        self.dateBoldFont = UIFont(name: "Helvetica-Bold", size: 10.0)!
        
        self.messageFont = UIFont(name: "Helvetica", size: 14.0)!
        
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
        self.cellHeight = self.messageLabelSize.height + dateLabelHeight + spacing
    }
}
