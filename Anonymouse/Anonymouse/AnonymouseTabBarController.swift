//
//  AnonymouseTabBarController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 9/25/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData

class AnonymouseTabBarController: UITabBarController, UITabBarControllerDelegate {
    var composeNavigationController: AnonymouseNavigationStyleController = AnonymouseNavigationStyleController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
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
        
        let mostRecentTableViewController: AnonymouseTableViewController = AnonymouseTableViewController(withFetchRequest: mostRecentFetchRequest)
        let favoriteTableViewController: AnonymouseTableViewController = AnonymouseTableViewController(withFetchRequest: favoriteFetchRequest)
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
        
//        mostRecentNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.mostRecent, tag: 0)
//        favoriteNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.favorites, tag: 1)
        
        let mostRecentTabBarItem = UITabBarItem(title: "Most Recent", image: UIImage(named: "mostRecentEmpty")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "mostRecentFilled"))
        mostRecentTabBarItem.tag = 0
        mostRecentNavigationController.tabBarItem = mostRecentTabBarItem
        
        let favoriteTabBarItem = UITabBarItem(title: "Favorites", image: UIImage(named: "favoriteEmpty")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "favoriteFilled"))
        favoriteTabBarItem.tag = 1
        favoriteNavigationController.tabBarItem = favoriteTabBarItem
        
        let bestRatedTabBarItem = UITabBarItem(title: "Top Rated", image: UIImage(named: "upvoteEmptyTab")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "upvoteFilledTab"))
        bestRatedTabBarItem.tag = 2
        bestRatedNavigationController.tabBarItem = bestRatedTabBarItem
        
        let settingsTabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settingsIconEmpty")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "settingsIconFilled"))
        settingsTabBarItem.tag = 3
        let settingsNavigationController: AnonymouseNavigationStyleController = AnonymouseNavigationStyleController()
        let settingsViewController: AnonymouseSettingsViewController = AnonymouseSettingsViewController(style: UITableViewStyle.grouped)
        settingsNavigationController.viewControllers = [settingsViewController]
        settingsNavigationController.tabBarItem = settingsTabBarItem
        
        self.viewControllers = [mostRecentNavigationController, favoriteNavigationController, bestRatedNavigationController, settingsNavigationController]
        self.selectedIndex = 0
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = self.tabBar.bounds
        
        let topColor: UIColor = UIColor(colorLiteralRed: 242.0/255.0, green: 106.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        let bottomColor: UIColor = UIColor(colorLiteralRed: 255.0/255.0, green: 140.0/255.0, blue: 110.0/255.0, alpha: 1.0)
        gradientLayer.colors = [topColor, bottomColor].map{$0.cgColor}
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let greyColor: UIColor = UIColor(colorLiteralRed: 234.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        for item in self.tabBar.items! {
            let unselectedItem = [NSForegroundColorAttributeName: greyColor]
            
            let selectedItem = [NSForegroundColorAttributeName: UIColor.white]
            
            item.setTitleTextAttributes(unselectedItem, for: .normal)
            //item.
            item.setTitleTextAttributes(selectedItem, for: .selected)
        }
        tabBarItem.selectedImage = UIImage(named: "upvoteEmptyTab")!.withRenderingMode(.alwaysOriginal)

        self.tabBar.backgroundImage = image
        self.tabBar.tintColor = UIColor.white
    }
    
    func compose() {
        self.present(composeNavigationController, animated: true, completion: nil)
    }
}
