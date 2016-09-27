//
//  RoarTabBarController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 9/25/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class RoarTabBarController: UITabBarController, UITabBarControllerDelegate {
    var profileNavigationController: RoarProfileNavigationController = RoarProfileNavigationController()
    var tableNavigationController: RoarTableNavigationController = RoarTableNavigationController()
    var settingsNavigationController: RoarSettingsNavigationController = RoarSettingsNavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        self.tabBar.barTintColor = UIColor(red: 253.0/255.0, green: 108.0/255.0, blue: 79.0/255.0, alpha: 1.0)
        self.tabBar.tintColor = UIColor.white
        
        tableNavigationController.parentTabBarController = self
        profileNavigationController.parentTabBarController = self
        
        tableNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.mostRecent, tag: 0)
        profileNavigationController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), tag: 1)
        
        self.viewControllers = [tableNavigationController, profileNavigationController]
        self.selectedIndex = 0
    }
    
    func presentSettings() {
        self.present(settingsNavigationController, animated: true, completion: nil)
    }
}
