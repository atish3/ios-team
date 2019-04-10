//
//  AnonymouseSettingsViewController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 9/26/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

/**
 A sub-class of `UITableViewController` that displays the settings of the app in a static table view.
 Through this view controller, the user can start/stop broadcasting messages, change their username,
 and delete all of the stored messages.
 */
class AnonymouseSettingsViewController: UITableViewController {
    ///A weak reference to the connectivityController; this allows the user to toggle broadcast settings.
    weak var connectivityController: AnonymouseConnectivityController!
    ///A weak reference to the dataController; this allows the user to delete all messages from the settings view.
    weak var dataController: AnonymouseDataController!
    
    ///An instance of `AnonymouseProfileViewController` that allows users to change their usernames.
    var profileViewController = AnonymouseProfileViewController()
    
    ///The label on the broadcast button; has the text `"Stop Broadcasting"` or `"Begin Broadcasting"`.
    //var broadcastLabel: UILabel!
    
    override func viewDidLoad() {
        self.title = "Settings"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StaticCell")
        
        unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        connectivityController = appDelegate.connectivityController
    }
    
    //MARK: TableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        //case 0:
            //return "Connectivity"
        case 0:
            return "Change Screen Name"
        case 1:
            return "Danger"
        default:
            return "Default"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let staticCell = tableView.dequeueReusableCell(withIdentifier: "StaticCell", for: indexPath)
        let centerLabel = UILabel()
        centerLabel.frame.size.width  = staticCell.frame.width
        centerLabel.frame.size.height = staticCell.frame.height
        centerLabel.frame.origin = CGPoint.zero
        
        switch indexPath.section {
        //case 0:
           // centerLabel.text = "Stop Broadcasting"
            //centerLabel.textColor = UIColor.red
            //broadcastLabel = centerLabel
        case 0:
            centerLabel.text = "Profile"
            centerLabel.textColor = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
        case 1:
            centerLabel.text = "Delete all messages"
            centerLabel.textColor = UIColor.red
        default:
            break;
        }
        
        centerLabel.frame.origin.x += staticCell.frame.width * 0.05
        
        staticCell.addSubview(centerLabel)
        return staticCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
       // case 0:
            //toggleConnection()
           // self.tableView.deselectRow(at: indexPath, animated: true)
        case 0:
            self.navigationController!.pushViewController(profileViewController, animated: true)
        case 1:
            let certainAlert: UIAlertController = UIAlertController(title: "Delete all messages", message: "Are you sure you want to delete all messages?", preferredStyle: .alert)
            certainAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                self.dataController.clearContext()
            }))
            certainAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            }))
            
            present(certainAlert, animated: true) {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            
        default:
            print("Pressed row at indexPath: \(indexPath)")
        }
    }
    
    //MARK: Connection methods
    
    ///A function that toggles whether or not the user is broadcasting/receiving messages or not.
//    func toggleConnection() {
//        let userPreferences: UserDefaults = UserDefaults.standard
//    
//        if connectivityController.isBrowsing {
//            userPreferences.set(false, forKey: "isBroadcasting")
//            
//            connectivityController.stopBrowsingForPeers()
//            connectivityController.stopAdvertisingPeer()
//            broadcastLabel.text = "Begin Broadcasting"
//            broadcastLabel.textColor = UIColor.green
//        }
//        else {
//            userPreferences.set(true, forKey: "isBroadcasting")
//        
//            connectivityController.startBrowsingForPeers()
//            connectivityController.startAdvertisingPeer()
//            broadcastLabel.text = "Stop Broadcasting"
//            broadcastLabel.textColor = UIColor.red
//        }
//    }
}
