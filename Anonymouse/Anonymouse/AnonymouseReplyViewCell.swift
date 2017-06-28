//
//  AnonymouseReplyViewCell.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 11/30/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

///A subclass of `AnonymouseTableViewCell` that displays replies in the detail view.
class AnonymouseReplyViewCell: AnonymouseTableViewCell {
    ///The amount of indent applied to replies relative to the main message.
    static let leftPadding: CGFloat = 20.0
    
    ///The reply to display in the cell.
    var reply: AnonymouseReplyCore? {
        didSet {
            updateCellUI()
        }
    }
    
    ///Moves the cell right by `leftPadding` pixels.
    func pushRight() {
        whiteBackdrop!.frame.origin.x += AnonymouseReplyViewCell.leftPadding
        grayFeatureBar!.frame.origin.x += AnonymouseReplyViewCell.leftPadding
    }
    
    ///Creates the gray feature bar at the bottom of the cell, without the reply or favorite buttons.
    override func createGrayFeatureBar() {
        grayFeatureBar = UIView()
        grayFeatureBar!.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        grayFeatureBar!.frame.size.height = AnonymouseTableViewCell.featuresBarHeight
        grayFeatureBar!.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        grayFeatureBar!.layer.borderWidth = 1.0
        
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
        
        numLikes = UILabel()
        numLikes!.font = AnonymouseTableViewCell.dateFont
        numLikes!.text = "0000"
        numLikes!.sizeToFit()
        numLikes!.text = "0"
        numLikes!.textAlignment = NSTextAlignment.center
        numLikes!.frame.origin.y = 2 * buttonY
        numLikes!.textColor = UIColor.gray
        self.grayFeatureBar!.addSubview(numLikes!)
    }
    
    ///Updates the UI to correctly reflect the rating of the reply.
    override func updateFeatureBar() {
        guard let replyData = reply else {
            return
        }
        
        let likeStatus: Int = replyData.likeStatus as! Int
        let rating: Int = replyData.rating as! Int
        
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
        
        upvoteButton!.frame.origin.x = grayFeatureBar!.frame.width - 30
        numLikes!.frame.origin.x = upvoteButton!.frame.origin.x - numLikes!.frame.width - 5
        downvoteButton!.frame.origin.x = numLikes!.frame.origin.x - 30
    }
    
    ///Called when the `reply` property is set. Updates the UI to reflect the current reply.
    override func updateCellUI() {
        guard let replyData = reply else {
            return
        }
        
        let dataDate: NSDate? = replyData.date
        let dataText: String? = replyData.text
        let dataUser: String? = replyData.user
        
        //Safely unwrap data, since it is optional
        if whiteBackdrop == nil {
            createBackdrop()
            pushRight()
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
        
        if (Calendar.current.isDateInToday(dataDate! as Date))
        {
            var secondsSinceMessage: TimeInterval = abs(dataDate!.timeIntervalSinceNow)
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
            let stringText: String = dateFormatter.string(from: dataDate! as Date)
            dateLabel!.text = stringText
        }
        
        dateLabel!.sizeToFit()
        dateLabel!.frame.origin = CGPoint(x: self.whiteBackdrop!.frame.width - (dateLabel?.frame.width)! - AnonymouseTableViewCell.messageXOffset, y: AnonymouseTableViewCell.messageYOffset)
        
        let baseX: CGFloat = AnonymouseTableViewCell.messageXOffset
        
        userLabel!.text = dataUser
        userLabel!.sizeToFit()
        userLabel!.frame.origin = CGPoint(x: baseX, y: AnonymouseTableViewCell.messageYOffset)
        
        //Make the messageLabel contain the cellData's text
        messageLabel!.text = dataText
        messageLabel!.sizeToFit()
        messageLabel!.frame.origin = CGPoint(x: baseX, y: (userLabel?.frame.origin.y)! + AnonymouseTableViewCell.userMessageDistance)
        
        if !self.whiteBackdrop!.subviews.contains(dateLabel!) {
            self.whiteBackdrop!.addSubview(dateLabel!)
        }
        if !self.whiteBackdrop!.subviews.contains(userLabel!) {
            self.whiteBackdrop!.addSubview(userLabel!)
        }
        if !self.whiteBackdrop!.subviews.contains(messageLabel!) {
            self.whiteBackdrop!.addSubview(messageLabel!)
        }
    }
    
    ///Called when the like button is tapped. Likes the current reply.
    override func upvoteTapped() {
        guard let replyData = reply else {
            return
        }
        let likeStatus: Int = Int(replyData.likeStatus!)
        replyData.like()
        
        if likeStatus != 1 {
            upvoteButton!.setImage(UIImage(named: "upvoteFilled"), for: UIControlState.normal)
            downvoteButton!.setImage(UIImage(named: "downvoteEmpty"), for: UIControlState.normal)
            expandAnimate(imageNamed: "upvoteFilled", fromPoint: upvoteButton!.frame.origin, withSuperView: grayFeatureBar!)
        } else {
            upvoteButton!.setImage(UIImage(named: "upvoteEmpty"), for: UIControlState.normal)
        }
    }
    
    ///Called when the dislike button is tapped. Dislikes the current reply.
    override func downvoteTapped() {
        guard let replyData = reply else {
            return
        }
        let likeStatus: Int = Int(replyData.likeStatus!)
        replyData.dislike()
        
        
        //Downvote Tapped
        if likeStatus != 2 {
            upvoteButton!.setImage(UIImage(named: "upvoteEmpty"), for: UIControlState.normal)
            downvoteButton!.setImage(UIImage(named: "downvoteFilled"), for: UIControlState.normal)
            expandAnimate(imageNamed: "downvoteFilled", fromPoint: downvoteButton!.frame.origin, withSuperView: grayFeatureBar!)
        } else {
            downvoteButton!.setImage(UIImage(named: "downvoteEmpty"), for: UIControlState.normal)
        }
    }
    
}
