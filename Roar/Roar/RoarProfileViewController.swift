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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aliasTextField = UITextField(frame: CGRect(x: 200.0, y: 50.0, width: self.view.frame.width - 100.0, height: 40.0))
        
        // Do any additional setup after loading the view, typically from a nib.
        aliasTextField.delegate = self
        
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
