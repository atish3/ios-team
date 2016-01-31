//
//  ChatTableView.swift
//  MCConnect
//
//  Created by Pascal Sturmfels on 1/25/16.
//  Copyright © 2016 Pascal Sturmfels. All rights reserved.
//

import UIKit

class MCChatTableViewController : UITableViewController
{
    var cellDataArray = [MCChatMessageData]()
    var ifCellRegistered = false
    
    override func viewDidLoad() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        loadTestData()
    }
    
    //Number of rows in tableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let data = cellDataArray[indexPath.row]
            let cell: MCChatTableViewCell
            
            if ifCellRegistered
            {
                let reusableCell: AnyObject = tableView.dequeueReusableCellWithIdentifier("MCChatTableViewCell", forIndexPath: indexPath)
                cell = reusableCell as! MCChatTableViewCell
            }
            else
            {
                let cellArray = NSBundle.mainBundle().loadNibNamed("MCChatTableViewCell", owner: self, options: nil)
                cell = cellArray[0] as! MCChatTableViewCell
                
                //register MCChatTableViewCell
                let nib = UINib(nibName: "MCChatTableViewCell", bundle: NSBundle.mainBundle())
                self.tableView.registerNib(nib, forCellReuseIdentifier: "MCChatTableViewCell")
                ifCellRegistered = true
            }
        
            cell.frame.size.width = self.tableView.frame.width
            cell.data = data
        
            return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellDataArray[indexPath.row].cellHeight
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 10))
        headerLabel.font = UIFont(name: "Helvetica", size: 10.0)!
        headerLabel.text = "Message Stream"
        headerLabel.textAlignment = NSTextAlignment.Center
        headerLabel.textColor = UIColor.grayColor()
        return headerLabel
    }
    
    
    //use to add a message
    func addMessage(text: String, date: NSDate, type: MCChatMessageType) {
        let message = MCChatMessage(text: text, date: date, type: type)
        let ifHideDate: Bool
        if cellDataArray.count == 0 || date.timeIntervalSinceDate(cellDataArray[cellDataArray.count - 1].message.date) > 60
        {
            ifHideDate = false
        }
        else
        {
            ifHideDate = true
        }
        let cellData = MCChatMessageData(message: message, hideDate: ifHideDate)
        cellDataArray.append(cellData)
        let indexPath = NSIndexPath(forRow: cellDataArray.count - 1, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
        // Add test data here
    func loadTestData()
    {
        addMessage("Hi!", date: NSDate(timeIntervalSinceNow: -24*60*60*23), type: MCChatMessageType.sentMessage)
        addMessage("Hello World!", date: NSDate(), type: MCChatMessageType.receivedMessage)
        addMessage("this is a string", date: NSDate(timeIntervalSinceNow: -12*60*60+30), type: MCChatMessageType.receivedMessage)
        addMessage("this is a very very very very very very very very very very very very very very very very very very very very very very very very very very very very long string", date: NSDate(timeIntervalSinceNow: -30), type: MCChatMessageType.sentMessage)
        addMessage("Another message", date: NSDate(), type: MCChatMessageType.receivedMessage)
        
    }
}