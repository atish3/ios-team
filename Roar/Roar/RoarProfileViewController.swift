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
        aliasLabel.text = "psturm"
        
        // Do any additional setup after loading the view, typically from a nib.
        aliasTextField.delegate = self
        aliasTextField.borderStyle = UITextBorderStyle.roundedRect
        aliasTextField.isHidden = true
        
        self.view.addSubview(aliasTextField)
        self.view.addSubview(aliasLabel)
        
        editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RoarProfileViewController.toggleEditMode))
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    func toggleEditMode() {
        if isEditingProfile {
            editButton.title = "Edit"
            editButton.style = UIBarButtonItemStyle.plain
        } else {
            editButton.title = "Done"
            editButton.style = UIBarButtonItemStyle.done
        }
        isEditingProfile = !isEditingProfile
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //The line below doesn't do anything! We should discuss this in person.
        //RoarComposeViewController().changeAlias(newAlias: textField.text!);
    }
    
    // MARK: Actions
    @IBAction func setDefaultAlias(_ sender: UIButton) {
        //See above
        //RoarComposeViewController().changeAlias(newAlias: "Anonymouse");
    }
    
    
}
