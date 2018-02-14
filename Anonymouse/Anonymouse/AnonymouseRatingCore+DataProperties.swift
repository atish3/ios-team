//
//  AnonymouseRatingCore+DataProperties.swift
//  Anonymouse
//
//  Created by Atishay Singh on 2/14/18.
//  Copyright © 2018 1AM. All rights reserved.
//

import Foundation


import Foundation
import CoreData


extension AnonymouseRatingCore {
    
    /// - Returns: The default `NSFetchRequest` object for this class.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnonymouseRatingCore> {
        return NSFetchRequest<AnonymouseRatingCore>(entityName: "AnonymouseRatingCore");
    }
    
    ///The date of the sent rating.
    @NSManaged public var date: NSDate?
    ///The integer rating of this rating.
    @NSManaged public var rating: NSNumber?
    ///The parent's message hash for this rating
    @NSManaged public var parent: String?
    
}
