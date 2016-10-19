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
    let textViewMargins: Int = 20
    let placeholderText: String = "Post something to the world!"
    var placeholderLabel: UILabel!
    
    weak var dataController: AnonymouseDataController!
    weak var connectivityController: AnonymouseConnectivityController!
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        
        unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        connectivityController = appDelegate.connectivityController
        
        composeTextView = UITextView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AnonymouseComposeViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(AnonymouseComposeViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        self.title = "Post to Feed"
        
        composeTextView.frame = CGRect(x: CGFloat(textViewMargins), y: 0, width: self.view.bounds.width - CGFloat(textViewMargins), height: self.view.bounds.height)
        composeTextView.delegate = self
        composeTextView.text = ""
        composeTextView.font = UIFont(name: "Helvetica", size: 17.0)!
        
        placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.font = composeTextView.font
        placeholderLabel.sizeToFit()
        
        placeholderLabel.frame.origin.x = 5
        placeholderLabel.frame.origin.y = 8.3
        
        placeholderLabel.textColor = UIColor.lightGray
        
        self.view.addSubview(placeholderLabel)
        composeTextView.addSubview(placeholderLabel)
        self.view.addSubview(composeTextView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.rightBarButtonItem!.isEnabled = false
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
        
        var messageText = self.composeTextView.text!
        messageText = messageText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        self.dataController.addMessage(messageText, date: Date(), user: username)
        if self.connectivityController.sessionObject.connectedPeers.count > 0 {
            self.connectivityController.send(individualMessage: AnonymouseMessageSentCore(text: self.composeTextView.text, date: Date(), user: username))
        }
        self.clearText()
    }
    
}
