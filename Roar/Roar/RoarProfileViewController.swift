//
//  SecondViewController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class RoarProfileViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    var profileImage: UIImageView!
    var usernameTextField: UITextField!
    var number of messagessent: int = 0
    
    func incrementsentmessages(){
        numberofmesagesent +=1
        messagesentlabel.text = "number of messages sent: \(numberofmessagessent)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        profileImage = UIImageView(frame: CGRect(x: 50, y: 100, width: 100, height: 100))
        profileImage.image = UIImage(named: "profile_default")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.changeProfileImage))

        profileImage.addGestureRecognizer(tap)
        profileImage.userInteractionEnabled = true
        
        usernameTextField = UITextField()
        usernameTextField.text = "Default user"
        usernameTextField.borderStyle = .None
        usernameTextField.sizeToFit()
        usernameTextField.frame.origin.x = profileImage.frame.origin.x + profileImage.frame.size.width + 20
        usernameTextField.frame.origin.y = profileImage.frame.origin.y
        usernameTextField.userInteractionEnabled = false
        usernameTextField.delegate = self
        
        let editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(self.editTapped))
        self.navigationItem.rightBarButtonItem = editButton
        
        self.view.addSubview(profileImage)
        self.view.addSubview(usernameTextField)
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        let dummyTextField = UITextField()
        dummyTextField.text = newString
        dummyTextField.borderStyle = .RoundedRect
        dummyTextField.sizeToFit()
        
        if(dummyTextField.frame.width < 200){
            textField.text = newString
            textField.sizeToFit()
        }
        
        return false
        
        

    }
    func editTapped(){
        if self.navigationItem.rightBarButtonItem!.title == "Edit"{
            self.usernameTextField.frame.origin.x -= 10
            self.usernameTextField.userInteractionEnabled = true
            self.usernameTextField.borderStyle = .RoundedRect
            self.navigationItem.rightBarButtonItem!.title = "Done"
        }
        else{
            self.navigationItem.rightBarButtonItem!.title = "Edit"
            self.usernameTextField.frame.origin.x += 10
            self.usernameTextField.userInteractionEnabled = false
            self.usernameTextField.borderStyle = .None
        }
    }
    func changeProfileImage() {
        print("Image was tapped")
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        imagePickerController.delegate = self
        presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        profileImage.image = image
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

