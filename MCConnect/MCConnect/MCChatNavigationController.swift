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
    var MCtextView: UITextView = UITextView()
    
    var tableView: MCChatTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.title = "MC Chat App"
        
        sendButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: "returnTextField")
        MCtextView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: 30))
        MCtextView.layer.borderWidth = 0.3
        MCtextView.layer.borderColor = UIColor.grayColor().CGColor
        MCtextView.delegate = self
        MCtextView.layer.cornerRadius = 7.0
        MCtextView.font = UIFont(name: "Helvetica", size: 14.0)!
        MCtextView.text = "X"
        MCtextView.frame.size.height = MCtextView.contentSize.height
        MCtextView.text = ""

        accessoryToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 5 / 6, height: 44))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: self, action: nil)
        fixedSpace.width = 20
        
        accessoryToolbar.items = [flexibleSpace, UIBarButtonItem(customView: MCtextView), fixedSpace, sendButton, flexibleSpace]
        
        MCtextView.becomeFirstResponder()
    }
    
    func returnTextField()
    {
        if let text = MCtextView.text where text.characters.count > 0 {
            UIView.animateWithDuration(0.3, delay: 0, options: [], animations: { () -> Void in
                self.sendButton.enabled = false
                self.MCtextView.backgroundColor = UIColor(red: 0.04, green: 0.93, blue: 0.094, alpha: 1.0)
                self.MCtextView.textColor = UIColor.whiteColor()
                self.MCtextView.layer.cornerRadius = 10.0
                self.MCtextView.layer.borderWidth = 0.0
                //self.sendButton.tintColor = UIColor.clearColor()
                }, completion: { (_) -> Void in
                UIView.animateWithDuration(0.3, delay: 0, options: [], animations: { () -> Void in
                    self.MCtextView.center.x += self.view.bounds.width
                    }, completion: { (_) -> Void in
                    //self.sendButton.tintColor = nil
                    self.sendButton.enabled = true
                    self.tableView.addMessage(text, date: NSDate(), type: MCChatMessageType.sentMessage)
                    self.MCtextView.text = ""
                    self.MCtextView.frame.size.height = self.MCtextView.contentSize.height
                    self.MCtextView.textColor = UIColor.blackColor()
                    self.MCtextView.backgroundColor = UIColor.whiteColor()
                    self.MCtextView.layer.cornerRadius = 7.0
                    self.MCtextView.layer.borderWidth = 0.3
                    self.MCtextView.center.x -= self.view.bounds.width
                })
            })
            //MCtextView.resignFirstResponder()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        let numLines = textView.contentSize.height / textView.font!.lineHeight
        if numLines <= 5
        {
            textView.frame.size.height = textView.contentSize.height
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
        MCtextView.resignFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
}
