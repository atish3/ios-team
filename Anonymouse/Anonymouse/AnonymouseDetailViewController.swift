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
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.groupTableViewBackground
    }
    
    func createNewCell(withData data: AnonymouseMessageCore) {
        if let cv = cellView {
            cv.removeFromSuperview()
        }
        
        let cellHeight: CGFloat = AnonymouseTableViewCell.getCellHeight(withMessageText: data.text!)
        cellView = AnonymouseTableViewCell()
        cellView!.frame.size.height = cellHeight
        cellView!.frame.size.width = self.view.frame.width
        cellView!.frame.origin = CGPoint.zero
        cellView!.setup()
        cellView!.createMessageLabel(withNumberOfLines: 0)
        
        cellView!.data = data
        self.view.addSubview(cellView!)
    }
    
}
