//
//  FirstViewController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class RoarNavigationController: UIViewController {
    var tableView: RoarTableViewController!
    var connectivityController: RoarConnectivityController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectivityController = RoarConnectivityController()
        connectivityController.tableViewController = tableView
        connectivityController.navigationController = self

        //let browseButton = UIBarButtonItem(title: "browse", style: UIBarButtonItemStyle.Plain , target: self, action: #selector(RoarNavigationController.toggleBrowser))
        //let advertiseButton = UIBarButtonItem(title: "advertise", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(RoarNavigationController.toggleAdvertiser))
        //self.navigationItem.leftBarButtonItems = [browseButton, advertiseButton]
        
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(45.0, target: self, selector: #selector(RoarNavigationController.startBrowsingAndAdvertising), userInfo: nil, repeats: true)
        

    }
    
    func startBrowsingAndAdvertising()
    {
        connectivityController.startBrowsingForPeers()
        connectivityController.createNewAdvertiser(withHashes: tableView.messageHashes)
        connectivityController.startAdvertisingPeer()
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
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    //prepareForSegue is a standard swift function that is called whenever a 
    //view "segues" (transitions) to another view. In this example, 
    //we use this function to load the tableView – since the tableView is inside
    //of this view, the segue to the table view is an "Embed" segue.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Embed"
        {
            tableView = segue.destinationViewController as! RoarTableViewController
        }
        else if segue.identifier == "composeSegue"
        {
            let destNav = segue.destinationViewController as! UINavigationController
            let composeVC = destNav.childViewControllers[0] as! RoarComposeViewController
            composeVC.roarTableVC = tableView
            composeVC.roarCC = connectivityController
        }
    }
}

