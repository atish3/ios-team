//
//  AnonymouseComposeNavigationController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 9/25/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseComposeNavigationController: AnonymouseNavigationStyleController {
    var composeViewController: AnonymouseComposeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        composeViewController = AnonymouseComposeViewController()
        
        composeViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(AnonymouseComposeNavigationController.cancelTapped))
        
        composeViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(AnonymouseComposeNavigationController.postTapped))
        
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
