//
//  AnonymouseSettingsNavigationController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 9/27/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseSettingsNavigationController: AnonymouseNavigationStyleController {
    var settingsViewController: AnonymouseSettingsViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsViewController = AnonymouseSettingsViewController(style: UITableViewStyle.grouped)
        self.viewControllers = [settingsViewController]
    }
    
}
