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
    weak var roarCC: RoarConnectivityController!
    let textViewMargins = 20
    let placeholderText = "Post something to the world!"
    var placeholderLabel: UILabel!
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoarComposeViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoarComposeViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
    
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(RoarComposeViewController.cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .Done, target: self, action: #selector(RoarComposeViewController.postTapped))
        self.navigationItem.rightBarButtonItem!.enabled = false
        
        self.title = "Post to Feed"
        
        composeTextView.translatesAutoresizingMaskIntoConstraints = true
        composeTextView.frame = CGRect(x: CGFloat(textViewMargins), y: 0, width: self.view.bounds.width - CGFloat(textViewMargins), height: self.view.bounds.height)
        composeTextView.delegate = self
        composeTextView.text = ""
        
        placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.font = composeTextView.font
        placeholderLabel.sizeToFit()
        composeTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, composeTextView.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor.lightGrayColor()
        
        composeTextView.becomeFirstResponder()
    }
    
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty
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
            if self.roarCC.sessionObject.connectedPeers.count > 0 {
                self.roarCC.sendIndividualMessage(RoarMessageCore(text: self.composeTextView.text, date: NSDate(), user: "Pascal"))
            }
        }
    }
}