//
//  RoarProfileViewController.swift
//  Roar
//
//  Created by SunYufan on 9/25/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class RoarProfileViewController: UIViewController, UITextFieldDelegate {
    
    var usernameTextField: UITextField!
    var usernameLabel: UILabel!
    var editButton: UIBarButtonItem!
    var usernameHeader: UILabel!
    var isEditingProfile: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textFieldWidth: CGFloat = 250.0
        let textFieldHeight: CGFloat = 40.0
        let textFieldCenterX: CGFloat = self.view.frame.width * 0.5 - textFieldWidth * 0.5
        usernameTextField = UITextField(frame: CGRect(x: textFieldCenterX, y: 200.0, width: textFieldWidth, height: textFieldHeight))
        usernameLabel = UILabel(frame: usernameTextField.frame)
        usernameLabel.frame.origin.x += 7
        usernameLabel.frame.origin.y -= 1
        usernameLabel.text = "Anonymouse"
        
        usernameHeader = UILabel()
        usernameHeader.text = "Screen name:"
        usernameHeader.sizeToFit()
        usernameHeader.frame.origin = usernameLabel.frame.origin
        usernameHeader.frame.origin.y -= 30
        
        // Do any additional setup after loading the view, typically from a nib.
        usernameTextField.delegate = self
        usernameTextField.borderStyle = UITextBorderStyle.roundedRect
        usernameTextField.isHidden = true
        usernameTextField.keyboardType = UIKeyboardType.namePhonePad
        usernameTextField.autocorrectionType = UITextAutocorrectionType.no
        
        self.view.addSubview(usernameTextField)
        self.view.addSubview(usernameLabel)
        self.view.addSubview(usernameHeader)
        
        editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RoarProfileViewController.toggleEditMode))
        self.navigationItem.rightBarButtonItem = editButton
        
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RoarProfileViewController.returnKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func returnKeyboard() {
        usernameTextField.resignFirstResponder()
    }
    
    func toggleEditMode() {
        if isEditingProfile {
            if let text = usernameTextField.text, text.isEmpty {
                let emptyUsernameAlert: UIAlertController = UIAlertController(title: "Username field is empty.", message: "Please enter a username", preferredStyle: UIAlertControllerStyle.alert)
                emptyUsernameAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
                    self.usernameTextField.becomeFirstResponder()
                }))
                
                self.present(emptyUsernameAlert, animated: true, completion: nil)
                return
            }
            
            returnKeyboard()
            usernameTextField.isHidden = true
            usernameLabel.isHidden = false
            
            usernameLabel.text = usernameTextField.text
            //Username is set here. This is a bit of a hack
            let userPreferences: UserDefaults = UserDefaults.standard
            userPreferences.set(usernameLabel.text!, forKey: "username")
        
            editButton.title = "Edit"
            editButton.style = UIBarButtonItemStyle.plain
        } else {
            usernameTextField.isHidden = false
            usernameLabel.isHidden = true
            
            usernameTextField.text = usernameLabel.text
            editButton.title = "Done"
            editButton.style = UIBarButtonItemStyle.done
        }
        isEditingProfile = !isEditingProfile
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        toggleEditMode()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //The line below doesn't do anything! We should discuss this in person.
        //RoarComposeViewController().changeusername(newusername: textField.text!);
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            let nsString = textField.text! as NSString
            textField.text = nsString.replacingCharacters(in: range, with: "_")
            return false
        }
        return true
    }
}
