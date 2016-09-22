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
class RoarNavigationController: UIViewController {
    var tableView: RoarTableViewController!
    var connectivityController: RoarConnectivityController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Link the connectivityController to its owner and display
        connectivityController = RoarConnectivityController()
        connectivityController.tableViewController = tableView
        connectivityController.navigationController = self
        
        //Create the MC buttons. 
        //TODO: These need to be replaced by background processes.
        let browseButton: UIBarButtonItem = UIBarButtonItem(title: "browse", style: UIBarButtonItemStyle.plain , target: self, action: #selector(RoarNavigationController.toggleBrowser))
        let advertiseButton: UIBarButtonItem = UIBarButtonItem(title: "advertise", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RoarNavigationController.toggleAdvertiser))
        
        //Create a button to clear all the messages.
        //TODO: This needs to be replaced by a background process.
        let clearTableButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(RoarNavigationController.clearTable))
        
        self.navigationItem.leftBarButtonItems = [browseButton, advertiseButton, clearTableButton]
    }
    
    func clearTable() {
        //A function to clear the messages from the tableView
        let certainAlert: UIAlertController = UIAlertController(title: "Delete all messages", message: "Are you sure you want to delete all messages?", preferredStyle: .alert)
        certainAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
        
            //Iterate through every item in the coreData store, and remove it from
            //the context. then, save the changes.
            for managedObject in self.tableView.fetchedResultsController.fetchedObjects! {
                self.tableView.managedObjectContext.delete(managedObject as NSManagedObject)
            }
            do {
                try self.tableView.managedObjectContext.save()
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
            self.navigationItem.leftBarButtonItems![0].title = "browse"
        }
        else {
            connectivityController.startBrowsingForPeers()
            self.navigationItem.leftBarButtonItems![0].title = "stop browsing"
        }
    }
    
    func toggleAdvertiser() {
        if connectivityController.isAdvertising {
            connectivityController.stopAdvertisingPeer()
            self.navigationItem.leftBarButtonItems![1].title = "advertise"
        }
        else {
            connectivityController.createNewAdvertiser(withHashes: tableView.messageHashes)
            connectivityController.startAdvertisingPeer()
            self.navigationItem.leftBarButtonItems![1].title = "stop advertising"
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    //prepareForSegue is a standard swift function that is called whenever a
    //view "segues" (transitions) to another view. In this example,
    //we use this function to load the tableView – since the tableView is inside
    //of this view, the segue to the table view is an "Embed" segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Embed"
        {
            tableView = segue.destination as! RoarTableViewController
        }
        else if segue.identifier == "composeSegue"
        {
            let destNav: UINavigationController = segue.destination as! UINavigationController
            let composeVC: RoarComposeViewController = destNav.childViewControllers[0] as! RoarComposeViewController
            composeVC.roarTableVC = tableView
            composeVC.roarCC = connectivityController
        }
    }
}

