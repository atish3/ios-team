//
//  AnonymouseTableViewCell.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseTableViewCell : UITableViewCell {
    
    //Linked to IBOutlet properties
    //These outlets appear in the MCChatTableViewCell.xib
    var dateLabel: UILabel!
    var messageLabel: UILabel!
    var userLabel: UILabel!
    
    //Constant properties to fit the message nicely into the table relative to other messages
    let imageWidthIncrease: CGFloat = 30
    let imageHeightIncrease: CGFloat = 10
    let imageMargin: CGFloat = 5
    let messageXOffset: CGFloat = 13
    let messageYOffset: CGFloat = 5
    
    //Once we set the message data, update this cell's UI
    var data: AnonymouseMessage?
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
            dateLabel = UILabel()
            messageLabel = UILabel()
            userLabel = UILabel()
            //self.selectionStyle = UITableViewCellSelectionStyle.None
            
            //Messages shouldn't be editable or selectable
            self.isUserInteractionEnabled = false
            
            //Create a frame for the date label that is 20 pixels high
            dateLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: cellData.dateLabelHeight)
            
            //Align then date's text to the center of the label
            dateLabel.textAlignment = NSTextAlignment.center
            
            //Set it to the date specified in cellData
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            //Working with dates in swift is more complicated than I'd like.
            //What needs to be done is this:
            //1) Create an NSDateFormatter object (done above). This lets us display the date on the screen
            //2) Check whether the date passed in from our message is today or yesterday using NSCalendar
            //3) Create a date label using NSDateFormatter, which returns a properly formatted date string
            //4) Use NSMutableAttributedString to BOLD a part of the label
            //5) Set the dateLabel's attributedText to be the new string
            
            if (Calendar.current.isDateInToday(cellData.message.date! as Date))
            {
                dateFormatter.dateFormat = "h:mm a"
                let stringText: String = "Today \(dateFormatter.string(from: cellData.message.date! as Date))"
                let boldString: NSMutableAttributedString = NSMutableAttributedString(string: stringText, attributes: [NSFontAttributeName: cellData.dateFont])
                boldString.addAttribute(NSFontAttributeName, value: cellData.dateBoldFont, range: (stringText as NSString).range(of: "Today"))
                dateLabel.attributedText = boldString
            }
            else if (Calendar.current.isDateInYesterday(cellData.message.date! as Date))
            {
                dateFormatter.dateFormat = "h:mm a"
                let stringText: String = "Yesterday \(dateFormatter.string(from: cellData.message.date! as Date))"
                let boldString: NSMutableAttributedString = NSMutableAttributedString(string: stringText, attributes: [NSFontAttributeName: cellData.dateFont])
                boldString.addAttribute(NSFontAttributeName, value: cellData.dateBoldFont, range: (stringText as NSString).range(of: "Yesterday"))
                dateLabel.attributedText = boldString
            }
            else
            {
                dateFormatter.dateFormat = "EEE, MMM dd, h:mm a"
                let stringText: String = dateFormatter.string(from: cellData.message.date! as Date)
                let boldString: NSMutableAttributedString = NSMutableAttributedString(string: stringText, attributes: [NSFontAttributeName: cellData.dateFont])
                var range: NSRange = NSRange.init()
                range.location = 0
                range.length = (stringText as NSString).range(of: ",", options: .backwards).location + 1
                boldString.addAttribute(NSFontAttributeName, value: cellData.dateBoldFont, range: range)
                dateLabel.attributedText = boldString
            }
            
            //Make the date have gray text
            dateLabel.textColor = UIColor.gray
            
            
            userLabel.text = cellData.message.user
            userLabel.font = cellData.userFont
            userLabel.numberOfLines = 1
            userLabel.textColor = UIColor.black
            userLabel.frame = CGRect(origin: CGPoint(x: messageXOffset,
                y: (cellData.dateLabelHeight * 0.5 + messageYOffset)), size: cellData.userLabelSize)
            
            //Make the messageLabel contain the cellData's text
            messageLabel.text = cellData.message.text
            messageLabel.font = cellData.messageFont
            messageLabel.numberOfLines = 0
            messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            messageLabel.textColor = UIColor.black
            messageLabel.frame = CGRect(origin: CGPoint(x: messageXOffset + imageMargin,
                y: ((self.bounds.height + cellData.dateLabelHeight * 0.5 + userLabel.frame.height) / 2) -
                    (cellData.messageLabelSize.height / 2)), size: cellData.messageLabelSize)
            
            self.addSubview(dateLabel)
            self.addSubview(messageLabel)
            self.addSubview(userLabel)
        }
    }
}
