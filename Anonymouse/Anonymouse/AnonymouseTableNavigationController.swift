//
//  FirstViewController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData

//The navigation controller for the "First" view on the tab bar
class AnonymouseTableNavigationController: AnonymouseNavigationStyleController {
    var composeNavigationController: AnonymouseComposeNavigationController = AnonymouseComposeNavigationController()
    var tableViewController: AnonymouseTableViewController = AnonymouseTableViewController()
    
    var composeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        self.viewControllers = [tableViewController]
        super.viewDidLoad()
        
        composeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(AnonymouseTableNavigationController.compose))
        
        tableViewController.navigationItem.rightBarButtonItem = composeButton
    }

    func compose() {
        self.present(composeNavigationController, animated: true, completion: nil)
    }
}

