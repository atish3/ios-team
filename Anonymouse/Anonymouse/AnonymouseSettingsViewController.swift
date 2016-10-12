//
//  AnonymouseSettingsViewController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 9/26/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseSettingsViewController: UITableViewController {
    weak var connectivityController: AnonymouseConnectivityController!
    weak var dataController: AnonymouseDataController!
    
    var profileViewController = AnonymouseProfileViewController()
    var broadcastLabel: UILabel!
    
    override func viewDidLoad() {
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Connectivity Stuff"
        case 1:
            return "Here Be You"
        case 2:
            return "Danger Zone"
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
        case 0:
            centerLabel.text = "Stop Broadcasting"
            centerLabel.textColor = UIColor.red
            broadcastLabel = centerLabel
        case 1:
            centerLabel.text = "Profile"
            centerLabel.textColor = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
        case 2:
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
        case 0:
            toggleConnection()
            self.tableView.deselectRow(at: indexPath, animated: true)
        case 1:
            self.navigationController!.pushViewController(profileViewController, animated: true)
            
        case 2:
            let certainAlert: UIAlertController = UIAlertController(title: "Delete all messages", message: "Are you sure you want to delete all messages?", preferredStyle: .alert)
            certainAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                //NEEDS TO BE IMPLEMENTED IN CORE DATA CONTROLLER
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
    func toggleConnection() {
        if connectivityController.isBrowsing {
            connectivityController.stopBrowsingForPeers()
            connectivityController.stopAdvertisingPeer()
            broadcastLabel.text = "Begin Broadcasting"
            broadcastLabel.textColor = UIColor.green
        }
        else {
            connectivityController.startBrowsingForPeers()
            connectivityController.startAdvertisingPeer()
            broadcastLabel.text = "Stop Broadcasting"
            broadcastLabel.textColor = UIColor.red
        }
    }
}
