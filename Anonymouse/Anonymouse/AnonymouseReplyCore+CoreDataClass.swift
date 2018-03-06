//
//  AnonymouseReplyCore+CoreDataClass.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 11/29/16.
//  Copyright © 2016 1AM. All rights reserved.
//
import UIKit
import CoreData

///A subclass of `NSManagedObject`. This class is the type that represents reply in the core data model.
class AnonymouseReplyCore: NSManagedObject {
    @objc convenience init(text: String, date: Date, user: String) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.dataController.managedObjectContext
        let entity: NSEntityDescription? = NSEntityDescription.entity(forEntityName: "AnonymouseReplyCore", in: managedContext)
        self.init(entity: entity!, insertInto: managedContext)
        self.date = date as NSDate?
        self.text = text
        self.user = user
        self.rating = NSNumber(integerLiteral: 0)
        self.likeStatus = NSNumber(integerLiteral: 0)
    }
    
    ///Likes the reply; changes the like status to 1, and sends a like message to nearby peers.
    @objc func like() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let connectivityController: AnonymouseConnectivityController = appDelegate.connectivityController
        guard let likeStatus = self.likeStatus as? Int else {
            return
        }
        if likeStatus != 1 {
            if likeStatus == 2 {
                self.rating = NSNumber(integerLiteral: self.rating!.intValue + 2)
                let sentRatingObject: AnonymouseRatingSentCore = AnonymouseRatingSentCore(rating: 2, messageHash: self.text!.sha1())
                connectivityController.send(individualRating: sentRatingObject)
            } else {
                self.rating = NSNumber(integerLiteral: self.rating!.intValue + 1)
                let sentRatingObject: AnonymouseRatingSentCore = AnonymouseRatingSentCore(rating: 1, messageHash: self.text!.sha1())
                connectivityController.send(individualRating: sentRatingObject)
            }
            self.likeStatus = 1
        } else {
            self.likeStatus = 0
            self.rating = NSNumber(integerLiteral: self.rating!.intValue - 1)
            let sentRatingObject: AnonymouseRatingSentCore = AnonymouseRatingSentCore(rating: -1, messageHash: self.text!.sha1())
            connectivityController.send(individualRating: sentRatingObject)
        }
    }
    
    ///Dislikes the reply; changes the like status to 2, and sends a dislike message to nearby peers.
    @objc func dislike() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let connectivityController: AnonymouseConnectivityController = appDelegate.connectivityController
        guard let likeStatus = self.likeStatus as? Int else {
            return
        }
        if likeStatus != 2 {
            if likeStatus == 1 {
                self.rating = NSNumber(integerLiteral: self.rating!.intValue - 2)
                let sentRatingObject: AnonymouseRatingSentCore = AnonymouseRatingSentCore(rating: -2, messageHash: self.text!.sha1())
                connectivityController.send(individualRating: sentRatingObject)
            } else {
                self.rating = NSNumber(integerLiteral: self.rating!.intValue - 1)
                let sentRatingObject: AnonymouseRatingSentCore = AnonymouseRatingSentCore(rating: -1, messageHash: self.text!.sha1())
                connectivityController.send(individualRating: sentRatingObject)
            }
            self.likeStatus = 2
        } else {
            self.likeStatus = 0
            self.rating = NSNumber(integerLiteral: self.rating!.intValue + 1)
            let sentRatingObject: AnonymouseRatingSentCore = AnonymouseRatingSentCore(rating: 1, messageHash: self.text!.sha1())
            connectivityController.send(individualRating: sentRatingObject)
        }
    }
}
