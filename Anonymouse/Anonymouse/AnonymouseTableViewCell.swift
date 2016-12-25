//
//  AnonymouseTableViewCell.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

///A custom `UITableViewCell` that displays messages in the main tables.
class AnonymouseTableViewCell : UITableViewCell {
    
    //MARK: Constant Class Properties
    ///The distance from the left side of the white cell to the message.
    static let messageXOffset: CGFloat = 8
    ///The distance from the top of the white cell to the username.
    static let messageYOffset: CGFloat = 5
    ///The vertical distance from the username to the message body.
    static let userMessageDistance: CGFloat = 25
    ///The height of the gray feature bar below the white cell.
    static let featuresBarHeight: CGFloat = 30.0
    
    ///The font of the date label.
    static let dateFont: UIFont = UIFont(name: "Helvetica", size: 16.0)!
    ///The font of the message label.
    static let messageFont: UIFont = UIFont(name: "Helvetica", size: 16.0)!
    ///The font of the username label.
    static let userFont: UIFont = UIFont(name: "Helvetica-Bold", size: 19.0)!
    ///The amount of extra space needed to define the height of the cell.
    static let spacing: CGFloat = 47.0
    
    
    /**
        - Returns: The height an instance of `AnonymouseTableViewCell` would have if it had the given text.
    
        - Parameters:
            - text: The text to put in the message body to determine the height of the cell.
    */
    static func getCellHeight(withMessageText text: String) -> CGFloat {
        let messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 340.0, height: CGFloat.greatestFiniteMagnitude))
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.font = messageFont
        messageLabel.text = text
        messageLabel.sizeToFit()
        return messageLabel.frame.size.height + spacing + featuresBarHeight
    }
    
    /**
        - Returns: The height an instance of `AnonymouseTableViewCell` would have if it had the given text, clipped at three maximum lines of text.
     
        - Parameters:
            - text: The text to put in the message body to determine the height of the cell.
     */
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
    ///Displays the date the message was composed.
    var dateLabel: UILabel?
    ///Displays the main body of the message.
    var messageLabel: UILabel?
    ///Displays the user that composed the message.
    var userLabel: UILabel?
    ///The white rectangle that defines each cell.
    var whiteBackdrop: UIView?
    ///The gray rectangle that defines the feature bar.
    var grayFeatureBar: UIView?
    ///The like button.
    var upvoteButton: UIButton?
    ///The dislike button.
    var downvoteButton: UIButton?
    ///The favorite button.
    var favoriteButton: UIButton?
    ///Displays the rating of the given message.
    var numLikes: UILabel?
    ///The line between the dislike button and the favorite button.
    var divider1: UIView?
    ///The line between the favorite button and the reply button.
    var divider2: UIView?
    ///The reply button.
    var replyButton: UIButton?
    //TODO: Make this display the number of replies the message has.
    var replyLabel: UILabel?
    
    ///`true` if this message is in a table of other messages, `false` if this message is alone in the detail view.
    var isInTable: Bool = true
    
    ///The variable that holds the data of the message.
    var data: AnonymouseMessageCore? {
        didSet
        {
            updateCellUI()
        }
    }
    
    ///Called when the cell is tapped; selects the cell.
    func highlightBackground() {
        guard let wb = whiteBackdrop else { return }
        wb.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        wb.layer.borderColor = UIColor(white: 0.6, alpha: 1.0).cgColor
        
        guard let gb = grayFeatureBar else { return }
        gb.backgroundColor = UIColor(white: 0.7, alpha: 1.0)
        gb.layer.borderColor = UIColor(white: 0.6, alpha: 1.0).cgColor
        
        guard let d1 = divider1 else { return }
        d1.backgroundColor = UIColor(white: 0.6, alpha: 1.0)
        
        guard let d2 = divider2 else { return }
        d2.backgroundColor = UIColor(white: 0.6, alpha: 1.0)
    }
    
    ///Called when the cell is released; deselects the cell.
    func releaseBackground() {
        guard let wb = whiteBackdrop else { return }
        wb.backgroundColor = UIColor.white
        wb.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        
        guard let gb = grayFeatureBar else { return }
        gb.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        gb.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        
        guard let d1 = divider1 else { return }
        d1.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        
        guard let d2 = divider2 else { return }
        d2.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
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
    
    ///Called when the cell is first created. Sets default UI properties common to all cells.
    func setup() {
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        if grayFeatureBar == nil {
            createGrayFeatureBar()
        }
    }
    
    //MARK: Creation/Update Methods
    ///Creates the label that displays the date.
    func createDateLabel() {
        dateLabel = UILabel()
        dateLabel!.textAlignment = NSTextAlignment.center
        dateLabel!.textColor = UIColor.gray
        dateLabel!.font = AnonymouseTableViewCell.dateFont
    }
    
    ///Creates the label that displays the username.
    func createUserLabel() {
        userLabel = UILabel()
        let darkOrange: UIColor = UIColor(colorLiteralRed: 255.0/255.0, green: 107.0/255.0, blue: 72.0/255.0, alpha: 1.0)
        userLabel!.numberOfLines = 1
        userLabel!.textColor = darkOrange
        userLabel!.font = AnonymouseTableViewCell.userFont
    }
    
    /**
     Creates the label that displays the message body.
     
     - Parameters: 
        - numberOfLines: The maximum number of lines the message body should have; clips if the message
            body exceeds the number of lines.
     */
    func createMessageLabel(withNumberOfLines numberOfLines: Int) {
        let messageWidth: CGFloat = self.frame.width - 5 * AnonymouseTableViewCell.messageXOffset
        messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: messageWidth, height: CGFloat.greatestFiniteMagnitude))
        messageLabel!.numberOfLines = numberOfLines
        messageLabel!.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        messageLabel!.textColor = UIColor.black
        messageLabel!.font = AnonymouseTableViewCell.messageFont
    }
    
    ///Creates the white rectangle that defines the cell.
    func createBackdrop() {
        whiteBackdrop = UIView(frame: self.bounds)
        whiteBackdrop!.frame.size.width -= 20
        whiteBackdrop!.frame.size.height -= 10
        whiteBackdrop!.frame.origin.y += 10
        whiteBackdrop!.frame.origin.x += 10
        whiteBackdrop!.layer.cornerRadius = 2.0
        whiteBackdrop!.backgroundColor = UIColor.white
        whiteBackdrop!.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        whiteBackdrop!.layer.borderWidth = 1.0
        
        self.contentView.addSubview(whiteBackdrop!)
        self.contentView.sendSubview(toBack: whiteBackdrop!)
        
        grayFeatureBar!.frame.size.width = whiteBackdrop!.frame.width
        grayFeatureBar!.frame.origin.y = whiteBackdrop!.frame.height - AnonymouseTableViewCell.featuresBarHeight + 10
        grayFeatureBar!.frame.origin.x = whiteBackdrop!.frame.origin.x
        
        updateFeatureBar()
    }
    
    ///Updates the feature bar to correctly reflect the rating of the message, and whether or not it is favorited.
    func updateFeatureBar() {
        
        guard let messageData = data else {
            return
        }
        let likeStatus: Int = messageData.likeStatus as! Int
        let isFavorite: Bool = messageData.isFavorite as! Bool
        let rating: Int = messageData.rating as! Int
        
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
        
        if isFavorite {
            favoriteButton!.setImage(UIImage(named: "favoriteFilled"), for: UIControlState.normal)
        }
        else {
            favoriteButton!.setImage(UIImage(named: "favoriteEmpty"), for: UIControlState.normal)
        }
        
        divider1!.frame.origin.x = downvoteButton!.frame.origin.x - 10
        favoriteButton!.frame.origin.x = divider1!.frame.origin.x - 35
        divider2!.frame.origin.x = favoriteButton!.frame.origin.x - 10
        replyButton!.frame.origin.x = divider2!.frame.origin.x - 35
    }
    
    ///Create the gray feature bar at the bottom of the cell.
    func createGrayFeatureBar() {
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
        divider1 = UIView(frame: CGRect( x: 0.0, y: buttonY, width: 1, height: dividerHeight))
        divider1?.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        self.grayFeatureBar!.addSubview(divider1!)
        
        divider2 = UIView(frame: CGRect( x: 0.0, y: buttonY, width: 1, height: dividerHeight))
        divider2?.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        self.grayFeatureBar!.addSubview(divider2!)
        
        replyButton = UIButton(frame: CGRect(x: 0.0, y: buttonY, width: 25, height: 25))
        replyButton!.tag = 3
        replyButton!.alpha = 0.5
        replyButton!.setImage(UIImage(named: "replyEmpty"), for: UIControlState.normal)
        replyButton!.setImage(UIImage(named: "replyFilled"), for: UIControlState.highlighted)
        replyButton!.addTarget(self, action: #selector(AnonymouseTableViewCell.featureBarButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        self.grayFeatureBar!.addSubview(replyButton!)
    }
    
    
    //MARK: Button Methods
    
    /**
     Animates the image named `name` at point `point`, expanding outwards and fading out over the duration of 0.4 seconds.
     
     - Parameters:  
        - name: The string name of the image to animate outwards.
        - point: The `CGPoint` at which to place the animation.
        - superView: The view to add the animation to.
     */
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
    
    /**
        Called when the reply button is tapped.
        Transitions to the detail view if the message is in the table, 
        displays the `replyTextView` of the detail view if the cell is in the detail view already.
     */
    func replyTapped() {
        if isInTable {
            NotificationCenter.default.post(name: NSNotification.Name("performDetailTransitionFromMessage"), object: nil, userInfo: ["cell": self])
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("replyTextViewBecomeFirstResponder"), object: nil)
        }
    }
    
    ///Called when the like button is tapped. Likes the message, and displays a like animation.
    func upvoteTapped() {
        guard let messageData = data else {
            return
        }
        let likeStatus: Int = Int(messageData.likeStatus!)
        messageData.like()
        
        if likeStatus != 1 {
            upvoteButton!.setImage(UIImage(named: "upvoteFilled"), for: UIControlState.normal)
            downvoteButton!.setImage(UIImage(named: "downvoteEmpty"), for: UIControlState.normal)
            expandAnimate(imageNamed: "upvoteFilled", fromPoint: upvoteButton!.frame.origin, withSuperView: grayFeatureBar!)
        } else {
            upvoteButton!.setImage(UIImage(named: "upvoteEmpty"), for: UIControlState.normal)
        }
    }
    
    ///Called when the dislike button is tapped. Dislikes the message, and displays a dislike animation.
    func downvoteTapped() {
        guard let messageData = data else {
            return
        }
        let likeStatus: Int = Int(messageData.likeStatus!)
        messageData.dislike()
        
        //Downvote Tapped
        if likeStatus != 2 {
            upvoteButton!.setImage(UIImage(named: "upvoteEmpty"), for: UIControlState.normal)
            downvoteButton!.setImage(UIImage(named: "downvoteFilled"), for: UIControlState.normal)
            expandAnimate(imageNamed: "downvoteFilled", fromPoint: downvoteButton!.frame.origin, withSuperView: grayFeatureBar!)
        } else {
            downvoteButton!.setImage(UIImage(named: "downvoteEmpty"), for: UIControlState.normal)
        }
    }
    
    ///Called when the favorite button is tapped. Favorites the message, and displays a favorite animation.
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
    
    ///Called when any of the feature bar buttons are tapped; calls the correct method depending on which button was tapped.
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
        case 3:
            replyTapped()
            updateFeatureBar()
        default:
            break
        }
    }
    
    ///Called when the property `data` is set. Updates the UI to reflect the current `data`.
    func updateCellUI() {
        guard let cellData = data else {
            return
        }
        ///The optional date from `data`.
        let dataDate: NSDate? = cellData.date
        ///The optional text from `data`.
        let dataText: String? = cellData.text
        ///The optional user from `data`.
        let dataUser: String? = cellData.user
        
        
        //Safely unwrap data, since it is optional
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
        
        if (Calendar.current.isDateInToday(dataDate as! Date))
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
            let stringText: String = dateFormatter.string(from: dataDate as! Date)
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
