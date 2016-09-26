//
//  RoarTabBarController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 9/25/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class RoarTabBarController: UITabBarController, UITabBarControllerDelegate {
    var roarNavigationController: RoarNavigationController!
    var roarProfileViewController: RoarProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        roarNavigationController = RoarNavigationController()
        self.viewControllers = [roarNavigationController]
        self.selectedIndex = 0
    }

}
