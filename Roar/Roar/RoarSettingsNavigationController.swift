//
//  RoarSettingsNavigationController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 9/27/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class RoarSettingsNavigationController: RoarNavigationStyleController {
    var settingsViewController: RoarSettingsViewController!
    var backButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsViewController = RoarSettingsViewController(style: UITableViewStyle.grouped)
        settingsViewController.messageTableViewController = parentTabBarController.tableNavigationController.tableViewController
        settingsViewController.connectivityController = parentTabBarController.connectivityController
        
        self.viewControllers = [settingsViewController]
    }
    
}
