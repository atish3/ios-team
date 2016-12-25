//
//  AnonymouseComposeViewController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

/**
 A subclass of `UIViewController` that allows the user to compose new messages.
 */
class AnonymouseComposeViewController: UIViewController, UITextViewDelegate {
    ///The `textView` in which the user inputs their message.
    var composeTextView: UITextView!
    ///The maximum number of characters that any message can be, minus one (don't ask, it was easier this way).
    let maxCharacters: Int = 301
    ///The number of pixels of padding between the sides of the screen and the `composeTextView`.
    let textViewMargins: Int = 20
    ///The text that appears over the `composeTextView`.
    let placeholderText: String = "Post something to the world!"
    ///The label that contains the `placeholderText`.
    var placeholderLabel: UILabel!
    ///The label that shows how many characters a user has left in their message.
    var charactersLeftLabel: UILabel!
    
    
    ///A weak reference to the `dataController` that allows the user to store the message they compose.
    weak var dataController: AnonymouseDataController!
    ///A weak reference to the `connectivityController` that allows the user to send the message they compose.
    weak var connectivityController: AnonymouseConnectivityController!
    
    //MARK: Navigation
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        
        unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        connectivityController = appDelegate.connectivityController
        
        composeTextView = UITextView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AnonymouseComposeViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(AnonymouseComposeViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        self.title = "Post to Feed"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(AnonymouseComposeViewController.cancelTapped))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(AnonymouseComposeViewController.postTapped))
        self.navigationItem.rightBarButtonItem!.isEnabled = false
        
        composeTextView.frame = CGRect(x: CGFloat(textViewMargins), y: 0, width: self.view.bounds.width - CGFloat(textViewMargins), height: self.view.bounds.height)
        composeTextView.delegate = self
        composeTextView.text = ""
        composeTextView.font = UIFont(name: "Helvetica", size: 17.0)!
        
        placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.font = composeTextView.font
        placeholderLabel.sizeToFit()
        
        placeholderLabel.frame.origin.x = 10
        placeholderLabel.frame.origin.y = 8
        
        placeholderLabel.textColor = UIColor.lightGray
        
        charactersLeftLabel = UILabel()
        charactersLeftLabel.font = composeTextView.font
        charactersLeftLabel.textColor = UIColor.lightGray
        charactersLeftLabel.text = "\(maxCharacters - 1)"
        charactersLeftLabel.sizeToFit()
        
        charactersLeftLabel.frame.origin.x = CGFloat(textViewMargins)
        
        composeTextView.addSubview(placeholderLabel)
        self.view.addSubview(composeTextView)
        self.view.addSubview(charactersLeftLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.rightBarButtonItem!.isEnabled = false
        composeTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        composeTextView.resignFirstResponder()
    }
    
    ///Called when the cancel button is tapped; dismisses `self` and clears the composed text.
    func cancelTapped() {
        self.dismiss(animated: true) { () -> Void in
            self.clearText()
        }
    }
    
    ///Called when the post button is tapped; dismisses `self` and calls `self.post()`.
    func postTapped() {
        self.dismiss(animated: true) { () -> Void in
            self.post()
        }
    }
    
    //MARK: TextView Methods
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let nsString: NSString = textView.text! as NSString
        let numCharacters: Int = nsString.replacingCharacters(in: range, with: text).characters.count
        let remainingCharacters: Int = maxCharacters - numCharacters
        
        if remainingCharacters < 40 {
            charactersLeftLabel.textColor = UIColor.red
            charactersLeftLabel.alpha = 0.7
        } else {
            charactersLeftLabel.textColor = UIColor.lightGray
            charactersLeftLabel.alpha = 1.0
        }
        
        if remainingCharacters < 1 {
            return false
        }
        
        charactersLeftLabel.text = "\(remainingCharacters - 1)"
        return true
    }
    
    //MARK: Keyboard Methods
    
    ///Called when the keyboard is about to be displayed.
    func keyboardWillShow(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.charactersLeftLabel.frame.origin.y = self.view.frame.height - keyboardFrame.height - 30.0
        
        UIView.animate(withDuration: 0.1, animations: {() -> Void in
            self.composeTextView.frame.size.height = self.charactersLeftLabel.frame.origin.y - 10.0
            self.composeTextView.frame.origin.y = 0
        })
    }
    
    ///Called when the keyboard is about to be dismissed.
    func keyboardWillHide(_ notification: Notification) {
        //        var info = (notification as NSNotification).userInfo!
        //        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //        UIView.animate(withDuration: 0.1, animations: {() -> Void in
        //            self.composeTextView.frame.size.height = self.view.bounds.height
        //            self.composeTextView.frame.origin.y = 0
        //        })
    }
    
    
    ///A property that allows this class to respond to UI events.
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    
    //MARK: Convenience methods
    
    ///Clears the text in the `composeTextView`.
    func clearText() {
        composeTextView.text = ""
        placeholderLabel.isHidden = false
        
        charactersLeftLabel.text = "\(maxCharacters - 1)"
        charactersLeftLabel.textColor = UIColor.lightGray
        charactersLeftLabel.alpha = 1.0
    }
    
    ///Posts the written message to the feed.
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
