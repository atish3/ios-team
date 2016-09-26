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
class RoarNavigationController: UINavigationController {
    var tableViewController: RoarTableViewController!
    var connectivityController: RoarConnectivityController!
    var composeNavigationController: RoarComposeNavigationController!
    var tableView: UIView!
    
    var browseButton: UIBarButtonItem!
    var advertiseButton: UIBarButtonItem!
    var clearTableButton: UIBarButtonItem!
    var composeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create the tableView
        tableViewController = RoarTableViewController()
        
        //Link the connectivityController to its owner and display
        connectivityController = RoarConnectivityController()
        connectivityController.tableViewController = tableViewController
        connectivityController.navigationController = self
        
        composeNavigationController = RoarComposeNavigationController()
        composeNavigationController.tableViewController = tableViewController
        composeNavigationController.connectivityController = connectivityController
        
        self.viewControllers = [tableViewController]
        
        //Create the MC buttons. 
        //TODO: These need to be replaced by background processes.
        browseButton = UIBarButtonItem(title: "browse", style: UIBarButtonItemStyle.plain , target: self, action: #selector(RoarNavigationController.toggleBrowser))
        advertiseButton = UIBarButtonItem(title: "advertise", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RoarNavigationController.toggleAdvertiser))
        
        //Create a button to clear all the messages.
        //TODO: This needs to be replaced by a background process.
        clearTableButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(RoarNavigationController.clearTable))

        tableViewController.navigationItem.leftBarButtonItems = [browseButton, advertiseButton, clearTableButton]
    
        composeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(RoarNavigationController.compose))
        
        tableViewController.navigationItem.rightBarButtonItem = composeButton
    }
    
    func clearTable() {
        //A function to clear the messages from the tableView
        let certainAlert: UIAlertController = UIAlertController(title: "Delete all messages", message: "Are you sure you want to delete all messages?", preferredStyle: .alert)
        certainAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
        
            //Iterate through every item in the coreData store, and remove it from
            //the context. then, save the changes.
            for managedObject in self.tableViewController.fetchedResultsController.fetchedObjects! {
                self.tableViewController.managedObjectContext.delete(managedObject as NSManagedObject)
            }
            do {
                try self.tableViewController.managedObjectContext.save()
            } catch {
                let clearError: NSError = error as NSError
                print(clearError)
            }
        }))
        certainAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(certainAlert, animated: true, completion: nil)
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
            connectivityController.createNewAdvertiser(withHashes: tableViewController.messageHashes)
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

