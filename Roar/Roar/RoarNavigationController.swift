//
//  FirstViewController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData

class RoarNavigationController: UIViewController {
    var tableView: RoarTableViewController!
    var connectivityController: RoarConnectivityController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectivityController = RoarConnectivityController()
        connectivityController.tableViewController = tableView
        connectivityController.navigationController = self
        
        let browseButton = UIBarButtonItem(title: "browse", style: UIBarButtonItemStyle.plain , target: self, action: #selector(RoarNavigationController.toggleBrowser))
        let advertiseButton = UIBarButtonItem(title: "advertise", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RoarNavigationController.toggleAdvertiser))
        
        let clearTableButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(RoarNavigationController.clearTable))
        
        self.navigationItem.leftBarButtonItems = [browseButton, advertiseButton, clearTableButton]
    }
    
    func clearTable() {
        
        let certainAlert = UIAlertController(title: "Delete all messages", message: "Are you sure you want to delete all messages?", preferredStyle: .alert)
        certainAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            for managedObject in self.tableView.fetchedResultsController.fetchedObjects! {
                self.tableView.managedObjectContext.delete(managedObject as NSManagedObject)
            }
            do {
                try self.tableView.managedObjectContext.save()
            } catch {
                let clearError = error as NSError
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
            let destNav = segue.destination as! UINavigationController
            let composeVC = destNav.childViewControllers[0] as! RoarComposeViewController
            composeVC.roarTableVC = tableView
            composeVC.roarCC = connectivityController
        }
    }
}

