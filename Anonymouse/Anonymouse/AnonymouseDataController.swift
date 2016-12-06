//
//  AnonymouseDataController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 10/12/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData

class AnonymouseDataController: NSObject {
    var managedObjectContext: NSManagedObjectContext
    let maxMessages: Int = 1000
    let blockSize: Int = 50
    
    override init() {
        
        //Get URL to Anonymouse.xcdatamodeld
        guard let modelURL: URL = Bundle.main.url(forResource: "Anonymouse", withExtension: "momd") else {
            fatalError("Fatal error loading Anonymouse.momd from main Bundle")
        }
        
        guard let managedObjectModel: NSManagedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Fatal error loading the managedObjectModel from \(modelURL)")
        }
        
        let persistentStoreCoordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        super.init()
        
        let URLPersistentStore = self.applicationStoresDirectory().appendingPathComponent("Anonymouse.sqlite")
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            do {
                // Add Persistent Store to Persistent Store Coordinator
                let options = [ NSMigratePersistentStoresAutomaticallyOption : true , NSInferMappingModelAutomaticallyOption : true ]
                
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: URLPersistentStore, options: options)
                
            } catch {
                let fm = FileManager.default
                if fm.fileExists(atPath: URLPersistentStore.path) {
                    let nameIncompatibleStore = self.nameForIncompatibleStore()
                    let URLCorruptPersistentStore = self.applicationIncompatibleStoresDirectory().appendingPathComponent(nameIncompatibleStore)
                    
                    do {
                        // Move Incompatible Store
                        try fm.moveItem(at: URLPersistentStore, to: URLCorruptPersistentStore)
                        
                        do {
                            // Declare Options
                            let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
                            
                            // Add Persistent Store to Persistent Store Coordinator
                            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: URLPersistentStore, options: options)
                            
                        } catch {
                            let storeError = error as NSError
                            NSLog("\(storeError), \(storeError.userInfo)")
                            // Update User Defaults
                            let userDefaults = UserDefaults.standard
                            userDefaults.set(true, forKey: "didDetectIncompatibleStore")
                        }
                    } catch {
                        let moveError = error as NSError
                        NSLog("\(moveError), \(moveError.userInfo)")
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Core Data Saving support
    fileprivate func applicationStoresDirectory() -> URL {
        let fm = FileManager.default
        
        // Fetch Application Support Directory
        let URLs = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let applicationSupportDirectory = URLs[(URLs.count - 1)]
        
        // Create Application Stores Directory
        let URL = applicationSupportDirectory.appendingPathComponent("Stores")
        
        if !fm.fileExists(atPath: URL.path) {
            do {
                // Create Directory for Stores
                try fm.createDirectory(at: URL, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                let createError = error as NSError
                print("\(createError), \(createError.userInfo)")
            }
        }
        
        return URL
    }
    
    fileprivate func nameForIncompatibleStore() -> String {
        // Initialize Date Formatter
        let dateFormatter = DateFormatter()
        
        // Configure Date Formatter
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        
        return "\(dateFormatter.string(from: Date())).sqlite"
    }
    
    fileprivate func applicationIncompatibleStoresDirectory() -> URL {
        let fm = FileManager.default
        
        // Create Application Incompatible Stores Directory
        let URL = applicationStoresDirectory().appendingPathComponent("Incompatible")
        
        if !fm.fileExists(atPath: URL.path) {
            do {
                // Create Directory for Stores
                try fm.createDirectory(at: URL, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                let createError = error as NSError
                NSLog("\(createError), \(createError.userInfo)")
            }
        }
        return URL
    }
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let fetchError: NSError = error as NSError
                fatalError("Failure to save context: \(fetchError)")
            }
        }
    }
    
    func addMessage(_ text: String, date: Date, user: String) {
        //Create a message object from the input parameters.
        let currentSize: Int = self.getSize()
        
        if currentSize > maxMessages {
            let numBlocksToDelete: Int = (currentSize - maxMessages) / blockSize
            for _ in 0..<numBlocksToDelete {
                self.deleteMessageBlock()
            }
        }
        
        //The creation of this object inserts it into the context
        let _: AnonymouseMessageCore = AnonymouseMessageCore(text: text, date: date, user: user)
        
        self.saveContext()
    }
    
    func addReply(withText text: String, date: Date, user: String, toMessage message: AnonymouseMessageCore) {
        let reply: AnonymouseReplyCore = AnonymouseReplyCore(text: text, date: date, user: user)
        reply.parentMessage = message
        self.saveContext()
    }
    
    func fetchObjects(withKey key: String, ascending: Bool) -> [AnonymouseMessageCore] {
        let fetchRequest: NSFetchRequest<AnonymouseMessageCore> = NSFetchRequest<AnonymouseMessageCore>(entityName: "AnonymouseMessageCore")
        
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: key, ascending: ascending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedMessages: [AnonymouseMessageCore] = try self.managedObjectContext.fetch(fetchRequest)
            return fetchedMessages
        } catch {
            let fetchError: NSError = error as NSError
            fatalError("Failure to fetch results: \(fetchError)")
        }
    }
    
    func fetchMessageHashes() -> [String] {
        let messageCoreArray: [AnonymouseMessageCore] = fetchObjects(withKey: "date", ascending: true)
        return messageCoreArray.map({ (messageCore) -> String in
            return messageCore.text!.sha1()
        })
    }
    
    func fetchReplies(withKey key: String, ascending: Bool) -> [AnonymouseReplyCore] {
        let fetchRequest: NSFetchRequest<AnonymouseReplyCore> = AnonymouseReplyCore.fetchRequest()
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: key, ascending: ascending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedReplies: [AnonymouseReplyCore] = try self.managedObjectContext.fetch(fetchRequest)
            return fetchedReplies
        } catch {
            let fetchError: NSError = error as NSError
            fatalError("Failure to fetch replies: \(fetchError)")
        }
    }
    
    func fetchReplyHashes() -> [String] {
        let replyCoreArray: [AnonymouseReplyCore] = fetchReplies(withKey: "date", ascending: true)
        return replyCoreArray.map({ (replyCore) -> String in
            return replyCore.text!.sha1()
        })
    }
    
    func clearContext() {
        for managedObject in self.fetchObjects(withKey: "date", ascending: true) {
            self.managedObjectContext.delete(managedObject)
        }
        
        self.saveContext()
    }
    
    func getSize() -> Int {
        //Get how many messages are in the core
        return fetchObjects(withKey: "date", ascending: true).count
    }
    
    func deleteMessageBlock() {
        let managedObjects: [AnonymouseMessageCore] = self.fetchObjects(withKey: "date", ascending: true)
        for managedObject in managedObjects[0..<blockSize] {
            self.managedObjectContext.delete(managedObject)
        }
        
        self.saveContext()
    }

    // MARK: for message tags
    func fetchMessageTag() -> [String:Int] {
        var tagCount = [String: Int]()
        let messageCoreArray: [AnonymouseMessageCore] = fetchObjects(withKey: "date", ascending: true)
        
        for messageCore in messageCoreArray {
            let tags: [String] = extractMessageTag(messageCore.text!)
            for tag in tags {
                if tagCount[tag] != nil {
                    tagCount[tag] = tagCount[messageCore.text!]! + 1
                } else {
                    tagCount[tag] = 1
                }
            }
        }
        
        return tagCount
    }
    
    func extractMessageTag(_ str: String) -> [String] {
        var tags: [String] = []
        let words: [String] = str.components(separatedBy: " ")
        for word in words {
            if word.hasPrefix("#") {
                tags.append(String(word.characters.dropFirst()))
            }
        }
        return tags
    }
}
