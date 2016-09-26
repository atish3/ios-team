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
class RoarTableNavigationController: RoarSettingsNavigationController {
    var connectivityController: RoarConnectivityController!
    var composeNavigationController: RoarComposeNavigationController!
    var tableViewController: RoarTableViewController!
    
    var tableView: UIView!
    
    var browseButton: UIBarButtonItem!
    var advertiseButton: UIBarButtonItem!
    var clearTableButton: UIBarButtonItem!
    var composeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        tableViewController = RoarTableViewController()
        self.viewControllers = [tableViewController]
        super.viewDidLoad()
        
        //Link the connectivityController to its owner and display
        connectivityController = RoarConnectivityController()
        connectivityController.tableViewController = tableViewController
        
        composeNavigationController = RoarComposeNavigationController()
        composeNavigationController.tableViewController = tableViewController
        composeNavigationController.connectivityController = connectivityController
        
        //Create the MC buttons. 
        //TODO: These need to be replaced by background processes.
        browseButton = UIBarButtonItem(title: "browse", style: UIBarButtonItemStyle.plain , target: self, action: #selector(RoarTableNavigationController.toggleBrowser))
        advertiseButton = UIBarButtonItem(title: "advertise", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RoarTableNavigationController.toggleAdvertiser))
        
        //Create a button to clear all the messages.
        //TODO: This needs to be replaced by a background process.
        clearTableButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self.tableViewController, action: #selector(RoarTableViewController.clearTable))

        //tableViewController.navigationItem.leftBarButtonItems = [browseButton, advertiseButton, clearTableButton]
    
        composeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(RoarTableNavigationController.compose))
        
        tableViewController.navigationItem.rightBarButtonItem = composeButton
    }
    
    func toggleBrowser() {
        if connectivityController.isBrowsing {
            connectivityController.stopBrowsingForPeers()
            browseButton.title = "browse"
        }
        else {
            connectivityController.startBrowsingForPeers()
            browseButton.title = "stop browsing"
        }
    }
    
    func toggleAdvertiser() {
        if connectivityController.isAdvertising {
            connectivityController.stopAdvertisingPeer()
            advertiseButton.title = "advertise"
        }
        else {
            connectivityController.createNewAdvertiser(withHashes: self.tableViewController.messageHashes)
            connectivityController.startAdvertisingPeer()
            advertiseButton.title = "stop advertising"
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func compose() {
        self.present(composeNavigationController, animated: true, completion: nil)
    }
}

