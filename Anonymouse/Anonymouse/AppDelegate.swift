//
//  AppDelegate.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundTask: UIBackgroundTaskIdentifier!
    var connectivityController: AnonymouseConnectivityController!
    var dataController: AnonymouseDataController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController = AnonymouseDataController()
        connectivityController = AnonymouseConnectivityController()
        
        let mainTabBarController: AnonymouseTabBarController = AnonymouseTabBarController()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.white
        self.window!.rootViewController = mainTabBarController
        self.window!.makeKeyAndVisible()

        let userPreferences: UserDefaults = UserDefaults.standard
        if userPreferences.string(forKey: "username") == nil {
            userPreferences.set("Anonymouse", forKey: "username")
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.dataController.saveContext()
        
        self.backgroundTask = application.beginBackgroundTask(withName: "backgroundTask", expirationHandler: {
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
        })
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
            var nextValue: Double = application.backgroundTimeRemaining.nextUp
            while !application.backgroundTimeRemaining.isLess(than: 50.0) {
                if application.backgroundTimeRemaining.isLess(than: nextValue) {
                    print(application.backgroundTimeRemaining)
                    nextValue -= 5.0
                }
            }
            
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.dataController.saveContext()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("\(application) called performFetchWithCompletionHandler")
        completionHandler(UIBackgroundFetchResult.noData)
    }
}
