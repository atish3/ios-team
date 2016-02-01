//
//  MCChatNavigationViewController.swift
//  MCConnect
//
//  Created by Pascal Sturmfels on 1/27/16.
//  Copyright © 2016 Pascal Sturmfels. All rights reserved.
//

import UIKit

class MCChatNavigationController: UIViewController, UITextViewDelegate {
    
    var accessoryToolbar: UIToolbar = UIToolbar()
    var sendButton: UIBarButtonItem = UIBarButtonItem()
    var MCtextField: UITextView = UITextView()
    
    var tableView: MCChatTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.title = "MC Chat App"
        
        sendButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: "returnTextField")
        MCtextField = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: 30))
        MCtextField.layer.borderWidth = 0.3
        MCtextField.layer.borderColor = UIColor.grayColor().CGColor
        MCtextField.delegate = self
        MCtextField.layer.cornerRadius = 7.0
        MCtextField.font = UIFont(name: "Helvetica", size: 14.0)!
        
        accessoryToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 3 / 4, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: self, action: nil)
        fixedSpace.width = 20
        
        accessoryToolbar.items = [flexibleSpace, UIBarButtonItem(customView: MCtextField), fixedSpace, sendButton, flexibleSpace]
        MCtextField.becomeFirstResponder()
        
    }
    
    func returnTextField()
    {
        if let text = MCtextField.text where text.characters.count > 0 {
            UIView.animateWithDuration(0.3, delay: 0, options: [], animations: { () -> Void in
                self.sendButton.enabled = false
                self.MCtextField.backgroundColor = UIColor.greenColor()
                self.MCtextField.textColor = UIColor.whiteColor()
                self.MCtextField.layer.cornerRadius = 10.0
                self.MCtextField.layer.borderWidth = 0.0
                //self.sendButton.tintColor = UIColor.clearColor()
                }, completion: { (_) -> Void in
                UIView.animateWithDuration(0.3, delay: 0, options: [], animations: { () -> Void in
                    self.MCtextField.center.x += self.view.bounds.width
                    }, completion: { (_) -> Void in
                    //self.sendButton.tintColor = nil
                    self.sendButton.enabled = true
                    self.tableView.addMessage(text, date: NSDate(), type: MCChatMessageType.sentMessage)
                    self.MCtextField.text = ""
                    self.MCtextField.textColor = UIColor.blackColor()
                    self.MCtextField.backgroundColor = UIColor.whiteColor()
                    self.MCtextField.layer.cornerRadius = 7.0
                    self.MCtextField.layer.borderWidth = 0.3
                    self.MCtextField.center.x -= self.view.bounds.width
                })
            })
            //MCtextField.resignFirstResponder()
        }
    }
    
    override var inputAccessoryView: UIToolbar? {
        get {
            return self.accessoryToolbar
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Embed"
        {
            tableView = segue.destinationViewController as! MCChatTableViewController
        }
    }
    
    func dismissKeyboard()
    {
        MCtextField.resignFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
}
