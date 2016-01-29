//
//  ChatBubbleTableViewCell.swift
//  MCConnect
//
//  Created by Pascal Sturmfels on 1/25/16.
//  Copyright © 2016 Pascal Sturmfels. All rights reserved.
//

import UIKit

class MCChatTableViewCell : UITableViewCell
{


    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleImageView: UIImageView!

    let imageWidthIncrease: CGFloat = 30
    let imageHeightIncrease: CGFloat = 10
    let imageMargin: CGFloat = 10
    let messageXOffset: CGFloat = 18
    let messageYOffset: CGFloat = 5
    
    //Once we set the message data, update this cell's UI
    var data: MCChatMessageData?
    {
        didSet
        {
            updateCellUI()
        }
    }
    
    func updateCellUI() {
        if let cellData = data
        {
            //self.selectionStyle = UITableViewCellSelectionStyle.None
            self.userInteractionEnabled = false
            
            dateLabel.translatesAutoresizingMaskIntoConstraints = true
            messageLabel.translatesAutoresizingMaskIntoConstraints = true
            bubbleImageView.translatesAutoresizingMaskIntoConstraints = true
            
            var dateLabelOffset: CGFloat = 0
            dateLabel.hidden = cellData.hideDate
            if cellData.hideDate == false
            {
                //If the date should be shown:
                //Create a frame for the date label
                
                dateLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: cellData.dateLabelHeight)
                dateLabel.textAlignment = NSTextAlignment.Center
                
                //Set it to the date specified in cellData
                let dateFormatter = NSDateFormatter()
                dateFormatter.AMSymbol = "AM"
                dateFormatter.PMSymbol = "PM"
                
                if (NSCalendar.currentCalendar().isDateInToday(cellData.message.date))
                {
                    dateFormatter.dateFormat = "h:mm a"
                    let stringText = "Today \(dateFormatter.stringFromDate(cellData.message.date))"
                    let boldString = NSMutableAttributedString(string: stringText, attributes: [NSFontAttributeName: cellData.dateFont])
                    boldString.addAttribute(NSFontAttributeName, value: cellData.dateBoldFont, range: (stringText as NSString).rangeOfString("Today"))
                    dateLabel.attributedText = boldString
                }
                else if (NSCalendar.currentCalendar().isDateInYesterday(cellData.message.date))
                {
                    dateFormatter.dateFormat = "h:mm a"
                    let stringText = "Yesterday \(dateFormatter.stringFromDate(cellData.message.date))"
                    let boldString = NSMutableAttributedString(string: stringText, attributes: [NSFontAttributeName: cellData.dateFont])
                    boldString.addAttribute(NSFontAttributeName, value: cellData.dateBoldFont, range: (stringText as NSString).rangeOfString("Yesterday"))
                    dateLabel.attributedText = boldString
                }
                else
                {
                    dateFormatter.dateFormat = "EEE, MMM dd, h:mm a"
                    let stringText = dateFormatter.stringFromDate(cellData.message.date)
                    let boldString = NSMutableAttributedString(string: stringText, attributes: [NSFontAttributeName: cellData.dateFont])
                    var range = NSRange.init()
                    range.location = 0
                    range.length = (stringText as NSString).rangeOfString(",", options: .BackwardsSearch).location + 1
                    boldString.addAttribute(NSFontAttributeName, value: cellData.dateBoldFont, range: range)
                    dateLabel.attributedText = boldString
                }
                
                //Make the date have gray text
                dateLabel.textColor = UIColor.grayColor()
                dateLabelOffset = cellData.dateLabelHeight
            }
            
            //Make the messageLabel contain the cellData's text
            messageLabel.text = cellData.message.text
            messageLabel.font = cellData.messageFont
            messageLabel.numberOfLines = 0
            messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            
            //Width of background image is: message width + padding
            //Height of background image is: message height + padding
            //Note that the bubble should not include the date inside of it
            let bubbleBackgroundImageSize = CGSize(width: cellData.messageLabelSize.width + imageWidthIncrease, height: cellData.messageLabelSize.height + imageHeightIncrease)
            
            switch cellData.message.type
            {
            case .sentMessage:
                //If we are sending the message, we need to justify our messageLabel
                //to the right side of the cell. Note the extra padding.
                messageLabel.frame = CGRect(origin: CGPoint(x: self.frame.width - cellData.messageLabelSize.width - messageXOffset - imageMargin, y: dateLabelOffset + messageYOffset), size: cellData.messageLabelSize)
                
                messageLabel.textColor = UIColor.whiteColor()
                
                //Create the bubble image such that it wraps the entire text label
                bubbleImageView.frame = CGRect(origin: CGPoint(x: self.frame.width - bubbleBackgroundImageSize.width - imageMargin, y: dateLabelOffset + 1), size: bubbleBackgroundImageSize)
                
                bubbleImageView.image = UIImage(named: "myBubble")?.resizableImageWithCapInsets(UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18))
                
            case .receivedMessage:
                //If we received the message, we should left justify our messageLabel.
                messageLabel.frame = CGRect(origin: CGPoint(x: messageXOffset + imageMargin, y: dateLabelOffset + messageYOffset), size: cellData.messageLabelSize)
                messageLabel.textColor = UIColor.blackColor()
                
                //Create a bubble image such that it wraps the entire text label
                bubbleImageView.frame = CGRect(origin: CGPoint(x: imageMargin, y: dateLabelOffset + messageYOffset - 4), size: bubbleBackgroundImageSize)
                
                bubbleImageView.image = UIImage(named: "yourBubble")?.resizableImageWithCapInsets(UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18))
            }
        
        }
    }

}