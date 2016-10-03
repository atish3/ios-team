//
//  AnonymouseComposeViewController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseComposeViewController: UIViewController, UITextViewDelegate {
    var composeTextView: UITextView!
    weak var tableViewController: AnonymouseTableViewController!
    weak var connectivityController: AnonymouseConnectivityController!
    let textViewMargins: Int = 20
    let placeholderText: String = "Post something to the world!"
    var placeholderLabel: UILabel!
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
    
        composeTextView = UITextView(frame: self.view.frame)
        self.view.addSubview(composeTextView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AnonymouseComposeViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(AnonymouseComposeViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        self.title = "Post to Feed"
  
        composeTextView.frame = CGRect(x: CGFloat(textViewMargins), y: 0, width: self.view.bounds.width - CGFloat(textViewMargins), height: self.view.bounds.height)
        composeTextView.delegate = self
        composeTextView.text = ""
        composeTextView.font = UIFont(name: "Helvetica", size: 14.0)!
        
        placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.font = composeTextView.font
        placeholderLabel.sizeToFit()
        composeTextView.addSubview(placeholderLabel)
        
        placeholderLabel.frame.origin = CGPoint(x: 26, y: 72)
        placeholderLabel.textColor = UIColor.lightGray
        
        self.view.addSubview(placeholderLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        composeTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        composeTextView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        if textView.text.characters.count > 0 {
            self.navigationItem.rightBarButtonItem!.isEnabled = true
        }
        else
        {
            self.navigationItem.rightBarButtonItem!.isEnabled = false
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.1, animations: {() -> Void in
            self.composeTextView.frame.size.height -= keyboardFrame.height
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.1, animations: {() -> Void in
            self.composeTextView.frame.size.height += keyboardFrame.height
        })
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func clearText() {
        composeTextView.text = ""
        placeholderLabel.isHidden = false
    }
    
    func post() {
        let userPreferences: UserDefaults = UserDefaults.standard
        let username: String = userPreferences.string(forKey: "username")!
    
        self.tableViewController.addMessage(self.composeTextView.text, date: Date(), user: username)
        if self.connectivityController.sessionObject.connectedPeers.count > 0 {
            self.connectivityController.sendIndividualMessage(AnonymouseMessageSentCore(text: self.composeTextView.text, date: Date(), user: username))
        }
        self.clearText()
    }

}
