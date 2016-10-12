//
//  AnonymouseTabBarController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 9/25/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseTabBarController: UITabBarController, UITabBarControllerDelegate {
    var tableNavigationController: AnonymouseTableNavigationController = AnonymouseTableNavigationController()
    var settingsNavigationController: AnonymouseSettingsNavigationController = AnonymouseSettingsNavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        self.tabBar.barTintColor = UIColor(red: 253.0/255.0, green: 108.0/255.0, blue: 79.0/255.0, alpha: 1.0)
        self.tabBar.tintColor = UIColor.white
        
        tableNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.mostRecent, tag: 0)
        
        let settingsTabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settingsIconEmpty"), selectedImage: UIImage(named: "settingsIconFilled"))
        settingsTabBarItem.tag = 1
        
        settingsNavigationController.tabBarItem = settingsTabBarItem
        
        self.viewControllers = [tableNavigationController, settingsNavigationController]
        self.selectedIndex = 0
    }
    
}
