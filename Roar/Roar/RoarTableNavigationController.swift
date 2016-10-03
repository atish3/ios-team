//
//  FirstViewController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData

//The navigation controller for the "First" view on the tab bar
class RoarTableNavigationController: RoarNavigationStyleController {
    var connectivityController: RoarConnectivityController!
    var composeNavigationController: RoarComposeNavigationController = RoarComposeNavigationController()
    var tableViewController: RoarTableViewController = RoarTableViewController()
    
    var tableView: UIView!
    
    var clearTableButton: UIBarButtonItem!
    var composeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        self.viewControllers = [tableViewController]
        super.viewDidLoad()
        
        //Link the connectivityController to its owner and display
        connectivityController.tableViewController = tableViewController
        
        composeNavigationController.tableViewController = tableViewController
        composeNavigationController.connectivityController = connectivityController
        
        //Create a button to clear all the messages.
        //TODO: This needs to be replaced by a background process.
        clearTableButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self.tableViewController, action: #selector(RoarTableViewController.clearTable))
    
        composeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(RoarTableNavigationController.compose))
        
        tableViewController.navigationItem.rightBarButtonItem = composeButton
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func compose() {
        self.present(composeNavigationController, animated: true, completion: nil)
    }
}

