//
//  RoarTabBarController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 9/25/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class RoarTabBarController: UITabBarController, UITabBarControllerDelegate {
    var topNavigationController: RoarNavigationController!
    var profileViewController: RoarProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        topNavigationController = RoarNavigationController()
        profileViewController = RoarProfileViewController()
        
        topNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.mostRecent, tag: 0)
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), tag: 1)
        
        self.viewControllers = [topNavigationController, profileViewController]
        self.selectedIndex = 0
    }
}
