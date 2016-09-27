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
        settingsViewController = RoarSettingsViewController()
        
        backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: self, action: #selector(RoarSettingsNavigationController.dismissSettings))
        
        settingsViewController.navigationItem.leftBarButtonItem = backButton
        self.viewControllers = [settingsViewController]
    }
    
    func dismissSettings() {
        self.dismiss(animated: true, completion: nil)
    }
}
