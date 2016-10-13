//
//  AnonymouseTableViewCell.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseTableViewCell : UITableViewCell {
    
    var dateLabel: UILabel!
    var messageLabel: UILabel!
    var userLabel: UILabel!
    var whiteBackdrop: UIView!
    
    //Constant properties to fit the message nicely into the table relative to other messages
    let imageWidthIncrease: CGFloat = 30
    let imageHeightIncrease: CGFloat = 10
    let messageXOffset: CGFloat = 20
    let messageYOffset: CGFloat = 13
    let userMessageDistance: CGFloat = 25
    
    //Once we set the message data, update this cell's UI
    var data: AnonymouseMessage?
        {
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
            whiteBackdrop = UIView(frame: self.bounds)
            whiteBackdrop.frame.size.width -= 20
            whiteBackdrop.frame.size.height -= 10
            whiteBackdrop.frame.origin.y += 10
            whiteBackdrop.frame.origin.x += 10
            whiteBackdrop.layer.cornerRadius = 2.0
            whiteBackdrop.layer.shadowOffset = CGSize(width: -1, height: 1)
            whiteBackdrop.layer.shadowOpacity = 0.2
            whiteBackdrop.backgroundColor = UIColor.white
            
            self.contentView.addSubview(whiteBackdrop)
            self.contentView.sendSubview(toBack: whiteBackdrop)
            self.contentView.backgroundColor = UIColor.clear
            self.backgroundColor = UIColor.clear
            
            //self.selectionStyle = UITableViewCellSelectionStyle.None
            //Messages shouldn't be editable or selectable
            self.isUserInteractionEnabled = false
            
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
                var secondsSinceMessage: TimeInterval = abs(cellData.message.date!.timeIntervalSinceNow)
                secondsSinceMessage = floor(secondsSinceMessage)
                let stringText: String
                
                if secondsSinceMessage > 3600.0 {
                    stringText = "\(Int(secondsSinceMessage / 3600))h"
                } else if secondsSinceMessage > 60.0 {
                    stringText = "\(Int(secondsSinceMessage / 60))m"
                } else {
                    stringText = "Just now"
                }
                
                dateLabel.text = stringText
            }
            else
            {
                dateFormatter.dateFormat = "MMM dd"
                let stringText: String = dateFormatter.string(from: cellData.message.date! as Date)
                dateLabel.text = stringText
            }
            
            //Make the date have gray text
            dateLabel.font = cellData.dateFont
            dateLabel.textColor = UIColor.gray
            dateLabel.sizeToFit()
            
            //Create a frame for the date label that is 20 pixels high
            dateLabel.frame.origin = CGPoint(x: self.bounds.width - dateLabel.frame.width - messageXOffset, y: 1.5 * messageYOffset)
            
            let darkOrange: UIColor = UIColor(colorLiteralRed: 242.0/255.0, green: 106.0/255.0, blue: 80.0/255.0, alpha: 1.0)
            userLabel.text = cellData.message.user
            userLabel.font = cellData.userFont
            userLabel.numberOfLines = 1
            userLabel.textColor = darkOrange
            userLabel.frame = CGRect(origin: CGPoint(x: messageXOffset,
                                                     y: messageYOffset), size: cellData.userLabelSize)
            
            //Make the messageLabel contain the cellData's text
            messageLabel.text = cellData.message.text
            messageLabel.font = cellData.messageFont
            messageLabel.numberOfLines = 0
            messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            messageLabel.textColor = UIColor.black
            messageLabel.frame = CGRect(origin: CGPoint(x: messageXOffset,
                                                        y: userLabel.frame.origin.y + userMessageDistance), size: cellData.messageLabelSize)
            
            self.contentView.addSubview(dateLabel)
            self.contentView.addSubview(messageLabel)
            self.contentView.addSubview(userLabel)
        }
    }
}
