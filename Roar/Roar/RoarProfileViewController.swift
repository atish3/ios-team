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
    var profileNavigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        aliasTextField.delegate = self
        profileNavigationBar.title = "Profile"
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
