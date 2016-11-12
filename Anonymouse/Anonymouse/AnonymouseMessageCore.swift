//
//  AnonymouseMessageCore.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 4/13/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData

class AnonymouseMessageCore: NSManagedObject {
    // Insert code here to add functionality to your managed object subclass
    
    //A subclass of NSManagedObject. This class is the type that is stored
    //in the core data model.
    convenience init(text: String, date: Date, user: String) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.dataController.managedObjectContext
        let entity: NSEntityDescription? = NSEntityDescription.entity(forEntityName: "AnonymouseMessageCore", in: managedContext)
        self.init(entity: entity!, insertInto: managedContext)
        self.date = date
        self.text = text
        self.user = user
        self.rating = NSNumber(integerLiteral: 0)
        self.likeStatus = NSNumber(integerLiteral: 0)
        self.isFavorite = NSNumber(booleanLiteral: false)
    }
    
    func like() {
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
    
    func dislike() {
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
