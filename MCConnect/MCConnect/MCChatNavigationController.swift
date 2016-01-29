//
//  MCChatNavigationViewController.swift
//  MCConnect
//
//  Created by Pascal Sturmfels on 1/27/16.
//  Copyright © 2016 Pascal Sturmfels. All rights reserved.
//

import UIKit

class MCChatNavigationController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var MCtextField: UITextField!
    @IBAction func sendTapped(sender: AnyObject) {
        if let text = MCtextField.text where text.characters.count > 0
        {
            tableView.addMessage(text, date: NSDate(), type: MCChatMessageType.sentMessage)
        }
    }
    
    var tableView: MCChatTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
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
