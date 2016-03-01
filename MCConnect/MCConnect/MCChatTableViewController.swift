//
//  ChatTableView.swift
//  MCConnect
//
//  Created by Pascal Sturmfels on 1/25/16.
//  Copyright © 2016 Pascal Sturmfels. All rights reserved.
//

import UIKit
import CryptoSwift


//A subclass of UITableViewController. This class handles all of the outward display of messages, 
//And is what occupies the majority of the screen when the app is running.
class MCChatTableViewController : UITableViewController
{
    //An array MCChatMessageData objects. This array is where all messages are stored.
    var cellDataArray = [MCChatMessageData]()
    var ifCellRegistered = false
    
    //A variable of type MCConnectivityController. 
    //This variable handles sending and receiving messages.
    var connectivityController = MCConnectivityController()
    
    
    override func viewDidLoad() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        //loadTestData()
        
        //This line allows the connectivityController to reference the tableView.
        connectivityController.tableViewController = self
        
    }
    
    //This function is part of UITableViewController's built-in classes.
    //It asks for the number of rows in tableView = number of messages = size of cellDataArray.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count
    }
    
    //This function is part of UITableViewController's built-in classes.
    //In it, we tell the tableView which message to render at each index of the table.
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            //Grab the appropriate data from our cellDataArray.
            let data = cellDataArray[indexPath.row]
            let cell: MCChatTableViewCell
        
            if ifCellRegistered
            {
                //Create a cell of type MCChatTableViewCell
                let reusableCell: AnyObject = tableView.dequeueReusableCellWithIdentifier("MCChatTableViewCell", forIndexPath: indexPath)
                cell = reusableCell as! MCChatTableViewCell
            }
            else
            {
                //This else statement is only for technical purposes. Ignore it.
                let cellArray = NSBundle.mainBundle().loadNibNamed("MCChatTableViewCell", owner: self, options: nil)
                cell = cellArray[0] as! MCChatTableViewCell
                
                //register MCChatTableViewCell
                let nib = UINib(nibName: "MCChatTableViewCell", bundle: NSBundle.mainBundle())
                self.tableView.registerNib(nib, forCellReuseIdentifier: "MCChatTableViewCell")
                ifCellRegistered = true
            }
        
            //Set the cell's width to be the width of the screen.
            cell.frame.size.width = self.tableView.frame.width
        
            //Set the cell's data to be the appropriate data. 
            //Notice that in this line, MCChatTableViewCell's property, data, is set. 
            //After it is set, the didSet keyword will be called, calling updateCellUI()
            cell.data = data
        
            return cell
    }
    
    //This function is part of UITableViewController's built-in classes.
    //In it, we determine the height of each cell in the tableView.
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //Notice that MCChatCellData already have a property called cellHeight
        //that depends on the size of the message.
        return cellDataArray[indexPath.row].cellHeight
    }
    
    //This function is part of UITableViewController's built-in classes.
    //This function provides the table label that appears at the top of the table.
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 10))
        headerLabel.font = UIFont(name: "Helvetica", size: 10.0)!
        headerLabel.text = "Message Stream"
        headerLabel.textAlignment = NSTextAlignment.Center
        headerLabel.textColor = UIColor.grayColor()
        return headerLabel
    }
    
    
    
    //WHENEVER YOU NEED TO ADD A MESSAGE TO THE TABLE, USE THIS FUNCTION.
    //An all-purpose function that adds a message to the table and updates the tableView.
    func addMessage(text: String, date: NSDate, type: MCChatMessageType) {
    
        //Create a MCChatMessage object from the input parameters.
        let message = MCChatMessage(text: text, date: date, type: type)
        let ifHideDate: Bool
        if cellDataArray.count == 0 || date.timeIntervalSinceDate(cellDataArray[cellDataArray.count - 1].message.date) > 60
        {
            //Display the date if it's been longer than an hour since the last message.
            ifHideDate = false
        }
        else
        {
            //Otherwise, don't display the date.
            ifHideDate = true
        }
        
        //Create an MCChatMessageData object from the given MCChatMessage object.
        let cellData = MCChatMessageData(message: message, hideDate: ifHideDate)
        
        //Append it to our cellDataArray.
        cellDataArray.append(cellData)
        
        //Find the end of the tableView, and insert the message there.
        let indexPath = NSIndexPath(forRow: cellDataArray.count - 1, inSection: 0)
        
        if (type == MCChatMessageType.sentMessage)
        {
            //Slide the message in from the right if it is a sent message.
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        }
        else
        {
            //Slide the message in from the left if it is a received message.
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        }
        
        //Scroll to see the new message added to the tableView.
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        
        //Send the message to the connectivityController if it is a sent message.
        if type == MCChatMessageType.sentMessage {
            connectivityController.message = text
        }
        
        print(text.sha1())

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