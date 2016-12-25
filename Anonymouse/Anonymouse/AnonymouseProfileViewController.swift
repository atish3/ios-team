//
//  AnonymouseProfileViewController.swift
//  Anonymouse
//
//  Created by SunYufan on 9/25/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

///A subclass of `UITextField` that does not allow pasting; used to input the username.
class NoPasteTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UITextField.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

/**
 A subclass of `UIViewController` that is displayed when
 the user wants to change their username. 
 
 Prevents usernames that are greater than 15 characters; removes all spaces from usernames
 and prevents pasting. Also prevents the user from changing their username 
 more than once a week.
 */
class AnonymouseProfileViewController: UIViewController, UITextFieldDelegate {
    
    ///The `textField` in which the user enters their username.
    var usernameTextField: NoPasteTextField!
    ///The label which displays the username when it is not being edited.
    var usernameLabel: UILabel!
    ///The button that allows a user to edit their username.
    var editButton: UIBarButtonItem!
    ///The label above the `usernameTextField` that says `"Screen name:"`.
    var usernameHeader: UILabel!
    ///`true` if the user is currently editing their username; false otherwise.
    var isEditingProfile: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile"
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        let textFieldWidth: CGFloat = 250.0
        let textFieldHeight: CGFloat = 40.0
        let textFieldCenterX: CGFloat = self.view.frame.width * 0.5 - textFieldWidth * 0.5
        usernameTextField = NoPasteTextField(frame: CGRect(x: textFieldCenterX, y: 200.0, width: textFieldWidth, height: textFieldHeight))
        usernameLabel = UILabel(frame: usernameTextField.frame)
        usernameLabel.frame.origin.x += 7
        usernameLabel.frame.origin.y -= 1
        
        if let userName = UserDefaults.standard.string(forKey: "username") {
            usernameLabel.text = userName
        } else {
            usernameLabel.text = "Anonymouse"
        }
        
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
        
        editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AnonymouseProfileViewController.toggleEditMode))
        self.navigationItem.rightBarButtonItem = editButton
        
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AnonymouseProfileViewController.returnKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    ///Dismisses the keyboard if it is currently active.
    func returnKeyboard() {
        usernameTextField.resignFirstResponder()
    }
    
    /**
     Saves the inputted username and returns the keyboard if the user is editing.
     Displays the keyboard and the `usernameTextField` if the user is not editing.
     */
    func toggleEditMode() {
        if isEditingProfile {
            if let text = usernameTextField.text, text.isEmpty {
                let emptyUsernameAlert: UIAlertController = UIAlertController(title: "Username field is empty", message: "Please enter a username.", preferredStyle: UIAlertControllerStyle.alert)
                emptyUsernameAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
                    self.usernameTextField.becomeFirstResponder()
                }))
                
                self.present(emptyUsernameAlert, animated: true, completion: nil)
                return
            }
            
            returnKeyboard()
            usernameTextField.isHidden = true
            usernameLabel.isHidden = false
            
            if usernameLabel.text != usernameTextField.text {
                usernameLabel.text = usernameTextField.text
                //Username is set here. This is a bit of a hack
                let userPreferences: UserDefaults = UserDefaults.standard
                userPreferences.set(usernameLabel.text!, forKey: "username")
                userPreferences.set(Date(), forKey: "timeUpdateUsername")
            }
            
            editButton.title = "Edit"
            editButton.style = UIBarButtonItemStyle.plain
        } else {
            //Get the last time the user updated the uername
            if let lastTimeUpdateUsername = UserDefaults.standard.object(forKey: "timeUpdateUsername") as! Date! {
                
                //Calculate the date difference since last update of username
                let secondsSinceLastUpdate: TimeInterval = abs(lastTimeUpdateUsername.timeIntervalSinceNow)
                
                // Disable update of username if it has been less than seven days since last update
                if secondsSinceLastUpdate < 604800 {
                    let unableUpdateUsernameAlert: UIAlertController = UIAlertController(title: "Unable to update username", message: "Please do not update username more than once in a week", preferredStyle: UIAlertControllerStyle.alert)
                    unableUpdateUsernameAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
                        self.usernameTextField.becomeFirstResponder()
                    }))
                    
                    self.present(unableUpdateUsernameAlert, animated: true, completion: nil)
                    return
                }
            }
            
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString: NSString = textField.text! as NSString
        if string == " " {
            textField.text = nsString.replacingCharacters(in: range, with: "_")
            return false
        }
        if nsString.replacingCharacters(in: range, with: string).characters.count > 15 {
            let tooManyCharactersAlert: UIAlertController = UIAlertController(title: "Too many characters", message: "The username field is limited to 15 characters.", preferredStyle: UIAlertControllerStyle.alert)
            tooManyCharactersAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
                self.usernameTextField.becomeFirstResponder()
            }))
            
            self.present(tooManyCharactersAlert, animated: true, completion: nil)
            return false
        }
        return true
    }
}
