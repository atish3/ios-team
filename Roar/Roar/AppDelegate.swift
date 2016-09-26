//
//  AppDelegate.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let mainTabBarController: RoarTabBarController = RoarTabBarController()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.white
        self.window!.rootViewController = mainTabBarController
        self.window!.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "io.github.qinyeli.Roar" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Roar", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // URL Documents Directory
        let URLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let applicationDocumentsDirectory = URLs[(URLs.count - 1)]
        
        // URL Persistent Store
        let URLPersistentStore = self.applicationStoresDirectory().appendingPathComponent("Roar.sqlite")
    
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
                        print("\(storeError), \(storeError.userInfo)")                        
                        // Update User Defaults
                        let userDefaults = UserDefaults.standard
                        userDefaults.set(true, forKey: "didDetectIncompatibleStore")
                    }
                    
                } catch {
                    let moveError = error as NSError
                    print("\(moveError), \(moveError.userInfo)")
                }
                
            }
        }
        
        return persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
     fileprivate func applicationStoresDirectory() -> URL {
        let fm = FileManager.default
        
        // Fetch Application Support Directory
        let URLs = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)
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
                print("\(createError), \(createError.userInfo)")
            }
        }
        return URL
    }
    
    func saveContext () {
        print(managedObjectContext.hasChanges)
        if managedObjectContext.hasChanges {
            do {
                print(managedObjectContext.updatedObjects)
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

