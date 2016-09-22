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
    let textViewMargins: Int = 20
    let placeholderText: String = "Post something to the world!"
    var placeholderLabel: UILabel!
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(RoarComposeViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(RoarComposeViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(RoarComposeViewController.cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(RoarComposeViewController.postTapped))
        self.navigationItem.rightBarButtonItem!.isEnabled = false
        
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
        placeholderLabel.frame.origin = CGPoint(x: 5, y: composeTextView.font!.pointSize / 2 + 1)
        placeholderLabel.textColor = UIColor.lightGray
        
        composeTextView.becomeFirstResponder()
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
    
    func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func postTapped() {
        self.dismiss(animated: true) { () -> Void in
            self.roarTableVC.addMessage(self.composeTextView.text, date: Date(), user: "Pascal")
            if self.roarCC.sessionObject.connectedPeers.count > 0 {
                self.roarCC.sendIndividualMessage(RoarMessageSentCore(text: self.composeTextView.text, date: Date(), user: "Pascal"))
            }
        }
    }
}
