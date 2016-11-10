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
    fileprivate static let featuresBarHeight: CGFloat = 30.0
    
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
        return messageLabel.frame.size.height + spacing + featuresBarHeight
    }
    
    static func getClippedCellHeight(withMessageText text: String) -> CGFloat {
        let messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 340.0, height: CGFloat.greatestFiniteMagnitude))
        messageLabel.numberOfLines = 3
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.font = messageFont
        messageLabel.text = text
        messageLabel.sizeToFit()
        return messageLabel.frame.size.height + spacing + featuresBarHeight
    }
    
    //MARK: UIView Properties
    var dateLabel: UILabel?
    var messageLabel: UILabel?
    var userLabel: UILabel?
    var whiteBackdrop: UIView?
    var grayLine: UIView?
    var grayFeatureBar: UIView?
    var upvoteButton: UIButton?
    var downvoteButton: UIButton?
    var favoriteButton: UIButton?
    var numLikes: UILabel?
    var divider: UIView?
    
    //Once we set the message data, update this cell's UI
    var data: AnonymouseMessageCore?
        {
        didSet
        {
            updateCellUI()
        }
    }
    
    func highlightBackground() {
        if let wb = whiteBackdrop, let gb = grayFeatureBar, let gl = grayLine {
            wb.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
            gb.backgroundColor = UIColor(white: 0.7, alpha: 1.0)
            gl.backgroundColor = UIColor(white: 0.6, alpha: 1.0)
        }
    }
    
    func releaseBackground() {
        if let wb = whiteBackdrop, let gb = grayFeatureBar, let gl = grayLine {
            wb.backgroundColor = UIColor.white
            gb.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
            gl.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            highlightBackground()
        } else {
            releaseBackground()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            highlightBackground()
        } else {
            releaseBackground()
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
        if grayLine == nil {
            createGrayLine()
        }
        
        if grayFeatureBar == nil {
            createGrayFeatureBar()
        }
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
        let darkOrange: UIColor = UIColor(colorLiteralRed: 255.0/255.0, green: 107.0/255.0, blue: 72.0/255.0, alpha: 1.0)
        userLabel!.numberOfLines = 1
        userLabel!.textColor = darkOrange
        userLabel!.font = AnonymouseTableViewCell.userFont
    }
    
    func createMessageLabel(withNumberOfLines numberOfLines: Int) {
        let messageWidth = UIScreen.main.bounds.width * 0.9
        messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: messageWidth, height: CGFloat.greatestFiniteMagnitude))
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
        
        grayLine!.frame.size.width = whiteBackdrop!.frame.width
        grayLine!.frame.origin.y = whiteBackdrop!.frame.height - AnonymouseTableViewCell.featuresBarHeight + 9
        
        grayFeatureBar!.frame.size.width = whiteBackdrop!.frame.width
        grayFeatureBar!.frame.origin.y = grayLine!.frame.origin.y + 1
        
        updateFeatureBar()
    }
    
    func updateFeatureBar() {
        guard let messageData = data else {
            return
        }
        guard let likeStatus = messageData.likeStatus as? Int else {
            return
        }

        guard let isFavorite = messageData.isFavorite as? Bool else {
            return
        }
        
        guard let rating = messageData.rating as? Int else {
            return
        }
       
        
        numLikes!.text = "\(rating)"
        
        if likeStatus == 1 {
            upvoteButton!.setImage(UIImage(named: "upvoteFilled"), for: UIControlState.normal)
            downvoteButton!.setImage(UIImage(named: "downvoteEmpty"), for: UIControlState.normal)
        }
        else if likeStatus == 2 {
            upvoteButton!.setImage(UIImage(named: "upvoteEmpty"), for: UIControlState.normal)
            downvoteButton!.setImage(UIImage(named: "downvoteFilled"), for: UIControlState.normal)
        }
        else {
            upvoteButton!.setImage(UIImage(named: "upvoteEmpty"), for: UIControlState.normal)
            downvoteButton!.setImage(UIImage(named: "downvoteEmpty"), for: UIControlState.normal)
        }
        

        if isFavorite {
            favoriteButton!.setImage(UIImage(named: "favoriteFilled"), for: UIControlState.normal)
        }
        else {
            favoriteButton!.setImage(UIImage(named: "favoriteEmpty"), for: UIControlState.normal)
        }

        upvoteButton!.frame.origin.x = grayFeatureBar!.frame.width - 30
        numLikes!.frame.origin.x = upvoteButton!.frame.origin.x - numLikes!.frame.width - 5
        downvoteButton!.frame.origin.x = numLikes!.frame.origin.x - 30
        divider!.frame.origin.x = downvoteButton!.frame.origin.x - 10
        favoriteButton!.frame.origin.x = divider!.frame.origin.x - 35
    }
    
    func createGrayLine() {
        grayLine = UIView()
        grayLine!.frame.size.height = 1.0
        grayLine!.frame.origin.x = 10
        grayLine!.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        
        self.contentView.addSubview(grayLine!)
    }
    
    func createGrayFeatureBar() {
        grayFeatureBar = UIView()
        grayFeatureBar!.frame.origin.x = 10
        grayFeatureBar!.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        grayFeatureBar!.frame.size.height = AnonymouseTableViewCell.featuresBarHeight
        
        self.contentView.addSubview(grayFeatureBar!)
        
        let buttonY: CGFloat = 2.5
        upvoteButton = UIButton(frame: CGRect(x: 0.0, y: buttonY, width: 25, height: 25))
        upvoteButton!.tag = 0
        upvoteButton!.alpha = 0.5
        upvoteButton!.setImage(UIImage(named: "upvoteEmpty"), for: UIControlState.normal)
        upvoteButton!.addTarget(self, action: #selector(AnonymouseTableViewCell.featureBarButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        self.grayFeatureBar!.addSubview(upvoteButton!)
        
        downvoteButton = UIButton(frame: CGRect(x: 0.0, y: buttonY, width: 25, height: 25))
        downvoteButton!.tag = 1
        downvoteButton!.alpha = 0.5
        downvoteButton!.setImage(UIImage(named: "downvoteEmpty"), for: UIControlState.normal)
        downvoteButton!.addTarget(self, action: #selector(AnonymouseTableViewCell.featureBarButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        self.grayFeatureBar!.addSubview(downvoteButton!)
        

        favoriteButton = UIButton(frame: CGRect(x: 0.0, y: buttonY, width: 25, height: 25))
        favoriteButton!.tag = 2
        favoriteButton!.alpha = 0.5
        favoriteButton!.setImage(UIImage(named: "favoriteEmpty"), for: UIControlState.normal)
        favoriteButton!.addTarget(self, action: #selector(AnonymouseTableViewCell.featureBarButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        self.grayFeatureBar!.addSubview(favoriteButton!)

        numLikes = UILabel()
        numLikes!.font = AnonymouseTableViewCell.dateFont
        numLikes!.text = "0000"
        numLikes!.sizeToFit()
        numLikes!.text = "0"
        numLikes!.textAlignment = NSTextAlignment.center
        numLikes!.frame.origin.y = 2 * buttonY
        numLikes!.textColor = UIColor.gray
        self.grayFeatureBar!.addSubview(numLikes!)
        
        let dividerHeight: CGFloat = 25
        divider = UIView(frame: CGRect( x: 0.0, y: buttonY, width: 1, height: dividerHeight))
        divider?.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        self.grayFeatureBar!.addSubview(divider!)

    }
    
    
    //MARK: Button Methods
    func expandAnimate(imageNamed name: String, fromPoint point: CGPoint, withSuperView superView: UIView) {
        let expandImage: UIImageView = UIImageView(image: UIImage(named: name))
        expandImage.alpha = 0.5
        superView.addSubview(expandImage)
        expandImage.frame.origin = point
        UIImageView.animate(withDuration: 0.4, animations: {
            expandImage.frame.origin.y -= 20
            expandImage.frame.size.width *= 2
            expandImage.frame.size.height *= 2
            expandImage.alpha = 0
        }) { (didFinish) in
            expandImage.removeFromSuperview()
        }
    }
    
    func upvoteTapped() {
        guard let messageData = data else {
            return
        }
        guard let likeStatus = messageData.likeStatus as? Int else {
            return
        }
        if likeStatus != 1 {
            upvoteButton!.setImage(UIImage(named: "upvoteFilled"), for: UIControlState.normal)
            downvoteButton!.setImage(UIImage(named: "downvoteEmpty"), for: UIControlState.normal)
            
            if likeStatus == 2 {
                messageData.rating = NSNumber(integerLiteral: messageData.rating!.intValue + 1)
            }
            messageData.rating = NSNumber(integerLiteral: messageData.rating!.intValue + 1)
            
            messageData.likeStatus = 1
            expandAnimate(imageNamed: "upvoteFilled", fromPoint: upvoteButton!.frame.origin, withSuperView: grayFeatureBar!)
        } else {
            upvoteButton!.setImage(UIImage(named: "upvoteEmpty"), for: UIControlState.normal)
            
            messageData.likeStatus = 0
            messageData.rating = NSNumber(integerLiteral: messageData.rating!.intValue - 1)
        }
    }
    
    func downvoteTapped() {
        guard let messageData = data else {
            return
        }
        guard let likeStatus = messageData.likeStatus as? Int else {
            return
        }
        
        //Downvote Tapped
        if likeStatus != 2 {
            upvoteButton!.setImage(UIImage(named: "upvoteEmpty"), for: UIControlState.normal)
            downvoteButton!.setImage(UIImage(named: "downvoteFilled"), for: UIControlState.normal)
            expandAnimate(imageNamed: "downvoteFilled", fromPoint: downvoteButton!.frame.origin, withSuperView: grayFeatureBar!)
            
            if likeStatus == 1 {
                messageData.rating = NSNumber(integerLiteral: messageData.rating!.intValue - 1)
            }
            messageData.rating = NSNumber(integerLiteral: messageData.rating!.intValue - 1)
            
            messageData.likeStatus = 2
        } else {
            downvoteButton!.setImage(UIImage(named: "downvoteEmpty"), for: UIControlState.normal)
            
            messageData.likeStatus = 0
            messageData.rating = NSNumber(integerLiteral: messageData.rating!.intValue + 1)
        }
    }
    
    func favoriteTapped() {
        guard let messageData = data else {
            return
        }
        guard let favoriteStatus = messageData.isFavorite as? Bool else {
            return
        }
        
        //Favorite Tapped
        if !favoriteStatus {
            favoriteButton!.setImage(UIImage(named: "favoriteFilled"), for: UIControlState.normal)

            expandAnimate(imageNamed: "favoriteFilled", fromPoint: favoriteButton!.frame.origin, withSuperView: grayFeatureBar!)
            
            messageData.isFavorite = NSNumber(booleanLiteral: true)
            
        } else {
            favoriteButton!.setImage(UIImage(named: "favoriteEmpty"), for: UIControlState.normal)
            
            messageData.isFavorite = NSNumber(booleanLiteral: false)
        }
    }
    
    func featureBarButtonTapped(sender: AnyObject) {
        switch sender.tag {
        case 0:
            upvoteTapped()
            updateFeatureBar()
        case 1:
            downvoteTapped()
            updateFeatureBar()
        case 2:
            favoriteTapped()
            updateFeatureBar()
        default:
            break
        }
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
