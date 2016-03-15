//
//  RoarComposeViewController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class RoarComposeViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var composeTextView: UITextView!
    weak var roarTableVC: RoarTableViewController!
    let textViewMargins = 20
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelTapped")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .Done, target: self, action: "postTapped")
        self.navigationItem.rightBarButtonItem!.enabled = false
        
        self.title = "Post to Feed"
        
        composeTextView.translatesAutoresizingMaskIntoConstraints = true
        composeTextView.frame = CGRect(x: CGFloat(textViewMargins), y: 0, width: self.view.bounds.width - CGFloat(textViewMargins), height: self.view.bounds.height)
        composeTextView.delegate = self
        composeTextView.becomeFirstResponder()
    }
    
    
    func textViewDidChange(textView: UITextView) {
        if textView.text.characters.count > 0 {
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        else
        {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        UIView.animateWithDuration(0.1, animations: {() -> Void in
            self.composeTextView.frame.size.height -= keyboardFrame.height
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        UIView.animateWithDuration(0.1, animations: {() -> Void in
            self.composeTextView.frame.size.height += keyboardFrame.height
        })
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func cancelTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postTapped() {
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.roarTableVC.addMessage(self.composeTextView.text, date: NSDate(), user: "Pascal")
        }
    }
}