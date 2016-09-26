//
//  RoarProfileViewController.swift
//  Roar
//
//  Created by SunYufan on 9/25/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class RoarProfileViewController: UIViewController, UITextFieldDelegate {
    
    var aliasTextField: UITextField!
    var aliasLabel: UILabel!
    var editButton: UIBarButtonItem!
    var aliasHeader: UILabel!
    var isEditingProfile: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textFieldWidth: CGFloat = 250.0
        let textFieldHeight: CGFloat = 40.0
        let textFieldCenterX: CGFloat = self.view.frame.width * 0.5 - textFieldWidth * 0.5
        aliasTextField = UITextField(frame: CGRect(x: textFieldCenterX, y: 200.0, width: textFieldWidth, height: textFieldHeight))
        aliasLabel = UILabel(frame: aliasTextField.frame)
        aliasLabel.frame.origin.x += 7
        aliasLabel.frame.origin.y -= 1
        aliasLabel.text = "Anonymouse"
        
        aliasHeader = UILabel()
        aliasHeader.text = "Screen name:"
        aliasHeader.sizeToFit()
        aliasHeader.frame.origin = aliasLabel.frame.origin
        aliasHeader.frame.origin.y -= 30
        
        // Do any additional setup after loading the view, typically from a nib.
        aliasTextField.delegate = self
        aliasTextField.borderStyle = UITextBorderStyle.roundedRect
        aliasTextField.isHidden = true
        aliasTextField.keyboardType = UIKeyboardType.namePhonePad
        aliasTextField.autocorrectionType = UITextAutocorrectionType.no
        
        self.view.addSubview(aliasTextField)
        self.view.addSubview(aliasLabel)
        self.view.addSubview(aliasHeader)
        
        editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RoarProfileViewController.toggleEditMode))
        self.navigationItem.rightBarButtonItem = editButton
        
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RoarProfileViewController.returnKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func returnKeyboard() {
        aliasTextField.resignFirstResponder()
    }
    
    func toggleEditMode() {
        if isEditingProfile {
            if let text = aliasTextField.text, text.isEmpty {
                let emptyAliasAlert: UIAlertController = UIAlertController(title: "Username field is empty.", message: "Please enter a username", preferredStyle: UIAlertControllerStyle.alert)
                emptyAliasAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
                    self.aliasTextField.becomeFirstResponder()
                }))
                
                self.present(emptyAliasAlert, animated: true, completion: nil)
                return
            }
            
            returnKeyboard()
            aliasTextField.isHidden = true
            aliasLabel.isHidden = false
            
            aliasLabel.text = aliasTextField.text
        
            editButton.title = "Edit"
            editButton.style = UIBarButtonItemStyle.plain
        } else {
            aliasTextField.isHidden = false
            aliasLabel.isHidden = true
            
            aliasTextField.text = aliasLabel.text
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
        //RoarComposeViewController().changeAlias(newAlias: textField.text!);
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
