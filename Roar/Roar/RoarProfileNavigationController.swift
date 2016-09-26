//
//  RoarProfileNavigationController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 9/26/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
class RoarProfileNavigationController: RoarSettingsNavigationController {
    var profileViewController: RoarProfileViewController!
    
    override func viewDidLoad() {
        profileViewController = RoarProfileViewController()
        self.viewControllers = [profileViewController]
        super.viewDidLoad()
    }
    
}
