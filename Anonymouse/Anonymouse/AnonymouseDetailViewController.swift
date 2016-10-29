//
//  AnonymouseDetailViewController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 10/16/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseDetailViewController: UIViewController {
    var cellView: AnonymouseTableViewCell?
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.groupTableViewBackground
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.groupTableViewBackground
        self.view.addSubview(scrollView)
    }
    
    func createNewCell(withData data: inout AnonymouseMessageCore) {
        if let cv = cellView {
            cv.removeFromSuperview()
        }
        
        let cellHeight: CGFloat = AnonymouseTableViewCell.getCellHeight(withMessageText: data.text!)
        cellView = AnonymouseTableViewCell()
        cellView!.setup()
        cellView!.frame.size.height = cellHeight
        cellView!.frame.size.width = self.view.frame.width
        cellView!.frame.origin = CGPoint.zero
        cellView!.createMessageLabel(withNumberOfLines: 0)
        
        cellView!.data = data
        
        // make the size of scrollView equal to size of cellViewFrame
        var cellViewFrame: UIView?
        cellViewFrame = UIView(frame: CGRect( x: 0.0, y: 0.0, width: self.view.frame.width, height: cellHeight + 120))
        scrollView.contentSize = (cellViewFrame?.bounds.size)!
        self.scrollView.addSubview(cellView!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let parentNavigationController = self.navigationController as? AnonymouseNavigationStyleController {
            if let tableVC = parentNavigationController.viewControllers[0] as? AnonymouseTableViewController {
                tableVC.tableView.reloadData()
                return
            }
        }
        abort()
    }
}
