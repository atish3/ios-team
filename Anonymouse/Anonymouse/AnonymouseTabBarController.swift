//
//  AnonymouseTabBarController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 9/25/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData

/**
 A subclass of `UITabBarController` that conforms to `UITabBarControllerDelegate`.
 This class has a custom orange gradient and white buttons.
 
 This class contains the three tableViews (Most Recent, Favorites, Top Rated) that display messages,
 as well as the settings view controller. It also connects the tableViews to the compose action, which
 brings up the message composition view.
 */
class AnonymouseTabBarController: UITabBarController, UITabBarControllerDelegate {
    ///An instance of `AnonymouseNavigationStyleController` that contains an `AnonymouseComposeViewController`.
    @objc var composeNavigationController: AnonymouseNavigationStyleController = AnonymouseNavigationStyleController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        ///A view controller to compose new messages.
        let composeViewController: AnonymouseComposeViewController = AnonymouseComposeViewController()
        composeNavigationController.viewControllers = [composeViewController]
        
        let mostRecentFetchRequest: NSFetchRequest<AnonymouseMessageCore> = NSFetchRequest<AnonymouseMessageCore>(entityName: "AnonymouseMessageCore")
        let mostRecentSortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let bestRatedSortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
        mostRecentFetchRequest.sortDescriptors = [mostRecentSortDescriptor, bestRatedSortDescriptor]
        
        let favoriteFetchRequest: NSFetchRequest<AnonymouseMessageCore> = NSFetchRequest<AnonymouseMessageCore>(entityName: "AnonymouseMessageCore")
        let favoriteSortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        favoriteFetchRequest.sortDescriptors = [favoriteSortDescriptor]
        let favoritePredicate: NSPredicate = NSPredicate(format: "isFavorite == %@", NSNumber(booleanLiteral: true))
        favoriteFetchRequest.predicate = favoritePredicate
        
        let bestRatedFetchRequest: NSFetchRequest<AnonymouseMessageCore> = NSFetchRequest<AnonymouseMessageCore>(entityName: "AnonymouseMessageCore")
        bestRatedFetchRequest.sortDescriptors = [bestRatedSortDescriptor, mostRecentSortDescriptor]
        
        ///Displays the most recent messages.
        let mostRecentTableViewController: AnonymouseTableViewController = AnonymouseTableViewController(withFetchRequest: mostRecentFetchRequest)
        ///Displays messages that the user has favorited.
        let favoriteTableViewController: AnonymouseTableViewController = AnonymouseTableViewController(withFetchRequest: favoriteFetchRequest)
        ///Displays the highest rated messages.
        let bestRatedTableViewController: AnonymouseTableViewController = AnonymouseTableViewController(withFetchRequest: bestRatedFetchRequest)
        
        mostRecentTableViewController.title = "Most Recent"
        favoriteTableViewController.title = "Favorites"
        bestRatedTableViewController.title = "Top Rated"
        
        let composeButtonA = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(AnonymouseTabBarController.compose))
        let composeButtonB = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(AnonymouseTabBarController.compose))
        let composeButtonC = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(AnonymouseTabBarController.compose))
        mostRecentTableViewController.navigationItem.rightBarButtonItem = composeButtonA
        favoriteTableViewController.navigationItem.rightBarButtonItem = composeButtonB
        bestRatedTableViewController.navigationItem.rightBarButtonItem = composeButtonC
        
        let mostRecentNavigationController: AnonymouseNavigationStyleController = AnonymouseNavigationStyleController()
        let favoriteNavigationController: AnonymouseNavigationStyleController = AnonymouseNavigationStyleController()
        let bestRatedNavigationController: AnonymouseNavigationStyleController = AnonymouseNavigationStyleController()
        mostRecentNavigationController.viewControllers = [mostRecentTableViewController]
        favoriteNavigationController.viewControllers = [favoriteTableViewController]
        bestRatedNavigationController.viewControllers = [bestRatedTableViewController]
        
        let mostRecentTabBarItem: UITabBarItem = UITabBarItem(title: "Most Recent", image: UIImage(named: "mostRecentEmpty")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "mostRecentFilled"))
        mostRecentTabBarItem.tag = 0
        mostRecentNavigationController.tabBarItem = mostRecentTabBarItem
        
        let favoriteTabBarItem: UITabBarItem = UITabBarItem(title: "Favorites", image: UIImage(named: "favoriteEmptyTab")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "favoriteFilled"))
        favoriteTabBarItem.tag = 1
        favoriteNavigationController.tabBarItem = favoriteTabBarItem
        
        let bestRatedTabBarItem: UITabBarItem = UITabBarItem(title: "Top Rated", image: UIImage(named: "upvoteEmptyTab")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "upvoteFilledTab"))
        bestRatedTabBarItem.tag = 2
        bestRatedNavigationController.tabBarItem = bestRatedTabBarItem
        
        let settingsTabBarItem: UITabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settingsIconEmpty")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "settingsIconFilled"))
        settingsTabBarItem.tag = 3
        let settingsNavigationController: AnonymouseNavigationStyleController = AnonymouseNavigationStyleController()
        ///A `viewController` to display the app's settings.
        let settingsViewController: AnonymouseSettingsViewController = AnonymouseSettingsViewController(style: UITableViewStyle.grouped)
        settingsNavigationController.viewControllers = [settingsViewController]
        settingsNavigationController.tabBarItem = settingsTabBarItem
        
        self.viewControllers = [mostRecentNavigationController, favoriteNavigationController, bestRatedNavigationController, settingsNavigationController]
        self.selectedIndex = 0
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = self.tabBar.bounds
        
        //let topColor: UIColor = UIColor(colorLiteralRed: 242.0/255.0, green: 106.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        //let bottomColor: UIColor = UIColor(colorLiteralRed: 255.0/255.0, green: 140.0/255.0, blue: 110.0/255.0, alpha: 1.0)
        let topColor = #colorLiteral(red: 0.9475640191, green: 0.415500217, blue: 0.3141004774, alpha: 1)
        let bottomColor = #colorLiteral(red: 1, green: 0.5478515625, blue: 0.4316134983, alpha: 1)
        gradientLayer.colors = [topColor, bottomColor].map{$0.cgColor}
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //let greyColor: UIColor = UIColor(colorLiteralRed: 234.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        let greyColor = #colorLiteral(red: 0.9185926649, green: 0.9169650608, blue: 0.9161783854, alpha: 1)
        for item in self.tabBar.items! {
            let unselectedItem = [NSAttributedStringKey.foregroundColor: greyColor]
            
            let selectedItem = [NSAttributedStringKey.foregroundColor: UIColor.white]
            
            item.setTitleTextAttributes(unselectedItem, for: .normal)
            //item.
            item.setTitleTextAttributes(selectedItem, for: .selected)
        }
        tabBarItem.selectedImage = UIImage(named: "upvoteEmptyTab")!.withRenderingMode(.alwaysOriginal)

        self.tabBar.backgroundImage = image
        self.tabBar.tintColor = UIColor.white
    }
    
    ///Display the compose view, which allows the user to write and send new messages.
    @objc func compose() {
        self.present(composeNavigationController, animated: true, completion: nil)
    }
}
