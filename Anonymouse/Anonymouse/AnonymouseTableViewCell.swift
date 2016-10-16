//
//  AnonymouseTableViewCell.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseTableViewCell : UITableViewCell {
    
    //MARK: Constant Class Properties
    fileprivate static let messageXOffset: CGFloat = 20
    fileprivate static let messageYOffset: CGFloat = 13
    fileprivate static let userMessageDistance: CGFloat = 25
    
    fileprivate static let dateFont: UIFont = UIFont(name: "Helvetica", size: 16.0)!
    fileprivate static let messageFont: UIFont = UIFont(name: "Helvetica", size: 16.0)!
    fileprivate static let userFont: UIFont = UIFont(name: "Helvetica-Bold", size: 19.0)!
    fileprivate static let spacing: CGFloat = 47.0
    
    static func getCellHeight(withMessageText text: String) -> CGFloat {
        let messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 340.0, height: CGFloat.greatestFiniteMagnitude))
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.font = messageFont
        messageLabel.text = text
        messageLabel.sizeToFit()
        return messageLabel.frame.size.height + spacing
    }
    
    static func getClippedCellHeight(withMessageText text: String) -> CGFloat {
        let messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 340.0, height: CGFloat.greatestFiniteMagnitude))
        messageLabel.numberOfLines = 3
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.font = messageFont
        messageLabel.text = text
        messageLabel.sizeToFit()
        return messageLabel.frame.size.height + spacing
    }
    
    //MARK: UIView Properties
    var dateLabel: UILabel?
    var messageLabel: UILabel?
    var userLabel: UILabel?
    var whiteBackdrop: UIView?
    
    //Once we set the message data, update this cell's UI
    var data: AnonymouseMessageCore?
        {
        didSet
        {
            updateCellUI()
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if let wb = whiteBackdrop {
            if highlighted {
                wb.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
            } else {
                wb.backgroundColor = UIColor.white
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if let wb = whiteBackdrop {
            if selected {
                wb.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
            } else {
                wb.backgroundColor = UIColor.white
            }
        }
    }
    
    //MARK: Initializers
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    //MARK: Creation/Update Methods
    func createDateLabel() {
        dateLabel = UILabel()
        dateLabel!.textAlignment = NSTextAlignment.center
        dateLabel!.textColor = UIColor.gray
        dateLabel!.font = AnonymouseTableViewCell.dateFont
    }
    
    func createUserLabel() {
        userLabel = UILabel()
        let darkOrange: UIColor = UIColor(colorLiteralRed: 242.0/255.0, green: 106.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        userLabel!.numberOfLines = 1
        userLabel!.textColor = darkOrange
        userLabel!.font = AnonymouseTableViewCell.userFont
    }
    
    func createMessageLabel(withNumberOfLines numberOfLines: Int) {
        messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 340.0, height: CGFloat.greatestFiniteMagnitude))
        messageLabel!.numberOfLines = numberOfLines
        messageLabel!.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        messageLabel!.textColor = UIColor.black
        messageLabel!.font = AnonymouseTableViewCell.messageFont
    }
    
    func createBackdrop() {
        whiteBackdrop = UIView(frame: self.bounds)
        whiteBackdrop!.frame.size.width -= 20
        whiteBackdrop!.frame.size.height -= 10
        whiteBackdrop!.frame.origin.y += 10
        whiteBackdrop!.frame.origin.x += 10
        whiteBackdrop!.layer.cornerRadius = 2.0
        whiteBackdrop!.layer.shadowOffset = CGSize(width: -1, height: 1)
        whiteBackdrop!.layer.shadowOpacity = 0.2
        whiteBackdrop!.backgroundColor = UIColor.white
        
        self.contentView.addSubview(whiteBackdrop!)
        self.contentView.sendSubview(toBack: whiteBackdrop!)
    }
    
    func updateCellUI()
    {
        //Safely unwrap data, since it is optional
        if let cellData = data
        {
            if whiteBackdrop == nil {
                createBackdrop()
            }
            
            if dateLabel == nil {
                createDateLabel()
            }
            
            if messageLabel == nil {
                createMessageLabel(withNumberOfLines: 3)
            }
            
            if userLabel == nil {
                createUserLabel()
            }
            
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            if (Calendar.current.isDateInToday(cellData.date! as Date))
            {
                var secondsSinceMessage: TimeInterval = abs(cellData.date!.timeIntervalSinceNow)
                secondsSinceMessage = floor(secondsSinceMessage)
                let stringText: String
                
                if secondsSinceMessage > 3600.0 {
                    stringText = "\(Int(secondsSinceMessage / 3600))h"
                } else if secondsSinceMessage > 60.0 {
                    stringText = "\(Int(secondsSinceMessage / 60))m"
                } else {
                    stringText = "Just now"
                }
                
                dateLabel!.text = stringText
            }
            else
            {
                dateFormatter.dateFormat = "MMM dd"
                let stringText: String = dateFormatter.string(from: cellData.date! as Date)
                dateLabel!.text = stringText
            }
            
            dateLabel!.sizeToFit()
            dateLabel!.frame.origin = CGPoint(x: self.bounds.width - (dateLabel?.frame.width)! - AnonymouseTableViewCell.messageXOffset, y: AnonymouseTableViewCell.messageYOffset)
            
            userLabel!.text = cellData.user
            userLabel!.sizeToFit()
            userLabel!.frame.origin = CGPoint(x: AnonymouseTableViewCell.messageXOffset, y: AnonymouseTableViewCell.messageYOffset)
            
            //Make the messageLabel contain the cellData's text
            messageLabel!.text = cellData.text
            messageLabel!.sizeToFit()
            messageLabel!.frame.origin = CGPoint(x: AnonymouseTableViewCell.messageXOffset, y: (userLabel?.frame.origin.y)! + AnonymouseTableViewCell.userMessageDistance)
            
            if !self.contentView.subviews.contains(dateLabel!) {
                self.contentView.addSubview(dateLabel!)
            }
            if !self.contentView.subviews.contains(userLabel!) {
                self.contentView.addSubview(userLabel!)
            }
            if !self.contentView.subviews.contains(messageLabel!) {
                self.contentView.addSubview(messageLabel!)
            }
        }
    }
    
    override func prepareForReuse() {
        dateLabel!.removeFromSuperview()
        messageLabel!.removeFromSuperview()
        userLabel!.removeFromSuperview()
        whiteBackdrop!.removeFromSuperview()
        
        dateLabel = nil
        messageLabel = nil
        userLabel = nil
        whiteBackdrop = nil
    }
}
