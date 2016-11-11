//
//  AnonymouseDetailViewController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 10/16/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseDetailViewController: UITableViewController {
    var cellData: AnonymouseMessageCore!
    
    override func viewDidLoad() {
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.allowsSelection = false
        self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
        
        tableView.register(AnonymouseTableViewCell.self, forCellReuseIdentifier: "StaticMessage")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let text = cellData.text else {
            return
        }
        
        self.title = text
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 //Needs to be number of replies
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell: AnonymouseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "StaticMessage", for: indexPath) as! AnonymouseTableViewCell
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
                cell.frame.size.width = self.tableView.frame.width
                cell.createMessageLabel(withNumberOfLines: 0)
                
                cell.data = cellData
                return cell
            }
        }
        
        return AnonymouseTableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if let text = cellData.text {
                    return AnonymouseTableViewCell.getCellHeight(withMessageText: text)
                }
            }
        }
        return 0.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let parentNavigationController = self.navigationController as? AnonymouseNavigationStyleController {
            if let tableVC = parentNavigationController.viewControllers[0] as? AnonymouseTableViewController {
                tableVC.tableView.reloadData()
                return
            }
        }
    }
}
