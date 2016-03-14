//
//  RoarTableViewController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//
import CryptoSwift
import UIKit

class RoarTableViewController: UITableViewController {
    //An array MCChatMessageData objects. This array is where all messages are stored.
    var cellDataArray = [RoarMessage]() //PERSISTENT STORAGE
    var messageHashes = [String]()      //PERSISTENT STORAGE!!!
    var ifCellRegistered = false

    override func viewDidLoad() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.tableView.separatorColor = UIColor.blackColor()
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        loadTestData()
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
            let cell: RoarTableViewCell
        
            if ifCellRegistered
            {
                //Create a cell of type MCChatTableViewCell
                let reusableCell: AnyObject = tableView.dequeueReusableCellWithIdentifier("RoarTableViewCell", forIndexPath: indexPath)
                cell = reusableCell as! RoarTableViewCell
            }
            else
            {
                //This else statement is only for technical purposes. Ignore it.
                let cellArray = NSBundle.mainBundle().loadNibNamed("RoarTableViewCell", owner: self, options: nil)
                cell = cellArray[0] as! RoarTableViewCell
                
                //register MCChatTableViewCell
                let nib = UINib(nibName: "RoarTableViewCell", bundle: NSBundle.mainBundle())
                self.tableView.registerNib(nib, forCellReuseIdentifier: "RoarTableViewCell")
                ifCellRegistered = true
            }
        
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.layoutMargins = UIEdgeInsetsZero
        
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
    
    //WHENEVER YOU NEED TO ADD A MESSAGE TO THE TABLE, USE THIS FUNCTION.
    //An all-purpose function that adds a message to the table and updates the tableView.
    func addMessage(text: String, date: NSDate, user: String) {
    
        //Create a MCChatMessage object from the input parameters.
        let message = RoarMessageCore(text: text, date: date, user:user)
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
        let cellData = RoarMessage(message: message, hideDate: ifHideDate)
        
        //Append it to our cellDataArray.
        cellDataArray.append(cellData)
        messageHashes.append(text.sha1())
        
        //Find the end of the tableView, and insert the message there.
        let indexPath = NSIndexPath(forRow: cellDataArray.count - 1, inSection: 0)
        
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        
        //Scroll to see the new message added to the tableView.
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    
        // Add test data here
    func loadTestData()
    {
        addMessage("Hi!", date: NSDate(timeIntervalSinceNow: -24*60*60*23), user: "Pascal")
        addMessage("Hello World!", date: NSDate(), user: "Pascal")
        addMessage("this is a string", date: NSDate(timeIntervalSinceNow: -12*60*60+30), user: "Pascal")
        addMessage("this is a very very very very very very very very very very very very very very very very very very very very very very very very very very very very long string", date: NSDate(timeIntervalSinceNow: -30), user: "Pascal")
       addMessage("Another message", date: NSDate(), user: "Pascal")
        
    }
}
