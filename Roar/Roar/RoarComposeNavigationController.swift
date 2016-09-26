//
//  RoarComposeNavigationController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 9/25/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class RoarComposeNavigationController: RoarNavigationStyleController {
    var composeViewController: RoarComposeViewController!
    weak var tableViewController: RoarTableViewController!
    weak var connectivityController: RoarConnectivityController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        composeViewController = RoarComposeViewController()
        
        composeViewController.tableViewController = tableViewController
        composeViewController.connectivityController = connectivityController
        
        composeViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(RoarComposeNavigationController.cancelTapped))
        
        composeViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(RoarComposeNavigationController.postTapped))
        
        composeViewController.navigationItem.rightBarButtonItem!.isEnabled = false
        
        self.viewControllers = [composeViewController]
    }
    
    func cancelTapped() {
        self.dismiss(animated: true) { () -> Void in
            self.composeViewController.clearText()
        }
    }
    
    func postTapped() {
        self.dismiss(animated: true) { () -> Void in
            self.composeViewController.post()
        }
    }
}
