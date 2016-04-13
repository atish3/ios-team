//
//  RoarTableViewCell.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class RoarTableViewCell : UITableViewCell {
    
    //Linked to IBOutlet properties
    //These outlets appear in the MCChatTableViewCell.xib
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    //Constant properties to fit the message nicely into the table relative to other messages
    let imageWidthIncrease: CGFloat = 30
    let imageHeightIncrease: CGFloat = 10
    let imageMargin: CGFloat = 5
    let messageXOffset: CGFloat = 13
    let messageYOffset: CGFloat = 5
    
    //Once we set the message data, update this cell's UI
    var data: RoarMessage?
        {
        //didSet is a "Swift-only" keyword. It means, whenever this
        //variable (data) was changed, call this block of code.
        didSet
        {
            updateCellUI()
        }
    }
    
    //A function that updates the UI of the cell:
    //It creates the cell with an appropriate size based on the text
    //And places it correctly in its superview (the table)
    func updateCellUI()
    {
        //Safely unwrap data, since it is optional
        if let cellData = data
        {
            //self.selectionStyle = UITableViewCellSelectionStyle.None
            
            //Messages shouldn't be editable or selectable
            self.userInteractionEnabled = false
            
            //translatesAutoresizingMaskIntoConstraints is a boolean property that if true,
            //allows you to modify the rendering frame(size, position) and autolayout constraints (relative position)
            //using code. This property is by default false for views created in the Interface Builder.
            //Often, if a view is created in Interface Builder, we don't need to modify its frame in code.
            //In this case, however, we do, so we set the property to true.
            dateLabel.translatesAutoresizingMaskIntoConstraints = true
            messageLabel.translatesAutoresizingMaskIntoConstraints = true
            userLabel.translatesAutoresizingMaskIntoConstraints = true
            
            //Create a frame for the date label that is 20 pixels high
            dateLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: cellData.dateLabelHeight)
            
            //Align then date's text to the center of the label
            dateLabel.textAlignment = NSTextAlignment.Center
            
            //Set it to the date specified in cellData
            let dateFormatter = NSDateFormatter()
            dateFormatter.AMSymbol = "AM"
            dateFormatter.PMSymbol = "PM"
            
            //Working with dates in swift is more complicated than I'd like.
            //What needs to be done is this:
            //1) Create an NSDateFormatter object (done above). This lets us display the date on the screen
            //2) Check whether the date passed in from our message is today or yesterday using NSCalendar
            //3) Create a date label using NSDateFormatter, which returns a properly formatted date string
            //4) Use NSMutableAttributedString to BOLD a part of the label
            //5) Set the dateLabel's attributedText to be the new string
            
            if (NSCalendar.currentCalendar().isDateInToday(cellData.message.date!))
            {
                dateFormatter.dateFormat = "h:mm a"
                let stringText = "Today \(dateFormatter.stringFromDate(cellData.message.date!))"
                let boldString = NSMutableAttributedString(string: stringText, attributes: [NSFontAttributeName: cellData.dateFont])
                boldString.addAttribute(NSFontAttributeName, value: cellData.dateBoldFont, range: (stringText as NSString).rangeOfString("Today"))
                dateLabel.attributedText = boldString
            }
            else if (NSCalendar.currentCalendar().isDateInYesterday(cellData.message.date!))
            {
                dateFormatter.dateFormat = "h:mm a"
                let stringText = "Yesterday \(dateFormatter.stringFromDate(cellData.message.date!))"
                let boldString = NSMutableAttributedString(string: stringText, attributes: [NSFontAttributeName: cellData.dateFont])
                boldString.addAttribute(NSFontAttributeName, value: cellData.dateBoldFont, range: (stringText as NSString).rangeOfString("Yesterday"))
                dateLabel.attributedText = boldString
            }
            else
            {
                dateFormatter.dateFormat = "EEE, MMM dd, h:mm a"
                let stringText = dateFormatter.stringFromDate(cellData.message.date!)
                let boldString = NSMutableAttributedString(string: stringText, attributes: [NSFontAttributeName: cellData.dateFont])
                var range = NSRange.init()
                range.location = 0
                range.length = (stringText as NSString).rangeOfString(",", options: .BackwardsSearch).location + 1
                boldString.addAttribute(NSFontAttributeName, value: cellData.dateBoldFont, range: range)
                dateLabel.attributedText = boldString
            }
            
            //Make the date have gray text
            dateLabel.textColor = UIColor.grayColor()
            
            userLabel.text = cellData.message.user
            userLabel.font = cellData.userFont
            userLabel.numberOfLines = 1
            userLabel.textColor = UIColor.blackColor()
            userLabel.frame = CGRect(origin: CGPoint(x: messageXOffset,
                y: (cellData.dateLabelHeight * 0.5 + messageYOffset)), size: cellData.userLabelSize)
            
            //Make the messageLabel contain the cellData's text
            messageLabel.text = cellData.message.text
            messageLabel.font = cellData.messageFont
            messageLabel.numberOfLines = 0
            messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.frame = CGRect(origin: CGPoint(x: messageXOffset + imageMargin,
                y: ((self.bounds.height + cellData.dateLabelHeight * 0.5 + userLabel.frame.height) / 2) -
                    (cellData.messageLabelSize.height / 2)), size: cellData.messageLabelSize)
            
            
        }
    }
}