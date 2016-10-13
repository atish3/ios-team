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
        
        
        self.tabBar.backgroundImage = image
        self.tabBar.tintColor = UIColor.white
        
        tableNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.mostRecent, tag: 0)
        
        let settingsTabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settingsIconEmpty"), selectedImage: UIImage(named: "settingsIconFilled"))
        settingsTabBarItem.tag = 1
        
        settingsNavigationController.tabBarItem = settingsTabBarItem
        
        self.viewControllers = [tableNavigationController, settingsNavigationController]
        self.selectedIndex = 0
    }
    
}
