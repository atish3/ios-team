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
class RoarNavigationController: RoarNavigationStyleController {
    var connectivityController: RoarConnectivityController!
    var composeNavigationController: RoarComposeNavigationController!
    var mainTabBarController: RoarTabBarController!
    
    var tableView: UIView!
    
    var browseButton: UIBarButtonItem!
    var advertiseButton: UIBarButtonItem!
    var clearTableButton: UIBarButtonItem!
    var composeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTabBarController = RoarTabBarController()
        
        //Link the connectivityController to its owner and display
        connectivityController = RoarConnectivityController()
        connectivityController.tableViewController = mainTabBarController.tableViewController
        connectivityController.navigationController = self
        
        composeNavigationController = RoarComposeNavigationController()
        composeNavigationController.tableViewController = mainTabBarController.tableViewController
        composeNavigationController.connectivityController = connectivityController
        
        self.viewControllers = [mainTabBarController]
        
        //Create the MC buttons. 
        //TODO: These need to be replaced by background processes.
        browseButton = UIBarButtonItem(title: "browse", style: UIBarButtonItemStyle.plain , target: self, action: #selector(RoarNavigationController.toggleBrowser))
        advertiseButton = UIBarButtonItem(title: "advertise", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RoarNavigationController.toggleAdvertiser))
        
        //Create a button to clear all the messages.
        //TODO: This needs to be replaced by a background process.
        clearTableButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self.mainTabBarController.tableViewController, action: #selector(RoarTableViewController.clearTable))

        mainTabBarController.navigationItem.leftBarButtonItems = [browseButton, advertiseButton, clearTableButton]
    
        composeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(RoarNavigationController.compose))
        
        mainTabBarController.navigationItem.rightBarButtonItem = composeButton
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
            connectivityController.createNewAdvertiser(withHashes: self.mainTabBarController.tableViewController.messageHashes)
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

