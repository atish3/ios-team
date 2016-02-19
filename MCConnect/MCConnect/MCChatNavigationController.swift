//
//  MCChatNavigationViewController.swift
//  MCConnect
//
//  Created by Pascal Sturmfels on 1/27/16.
//  Copyright © 2016 Pascal Sturmfels. All rights reserved.
//

import UIKit

//A subclass of UIViewController that conforms to the protocol of UITextViewDelegate.
//This class manages the MCChatTableViewController as a subViewController,
//And manages the toolbar + textView that rides at the bottom of the screen.
class MCChatNavigationController: UIViewController, UITextViewDelegate {
    
    //The toolbar at the bottom of the screen
    var accessoryToolbar: UIToolbar = UIToolbar()
    
    //The send button inside the toolbar
    var sendButton: UIBarButtonItem = UIBarButtonItem()
    
    //The textView inside the toolbar
    var MCtextView: UITextView = UITextView()
    
    //A tableview property that refers to the tableView containing the messages
    var tableView: MCChatTableViewController!
    var prevNumLines: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create a UITapGestureRecognizer that notifies us when the tableView is tapped.
        //When the tableView is tapped, we need to dismiss the keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //The title that appears at the top of the app in the navigation bar.
        self.title = "MC Chat App"
        
        //When the send button is tapped, we should dismiss the keyboard and
        //add the message written to the tableView
        sendButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: "returntextView")
        
        //Resize the textView to fit nicely in the toolBar.
        MCtextView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: 33))
        MCtextView.layer.borderWidth = 0.3
        MCtextView.layer.borderColor = UIColor.grayColor().CGColor
        
        //Set the deleage of the textView to be self. This models the delegate-object swift
        //pattern, where we have views that are objects, and viewControllers that behave
        //as "delegates" which control what happens with those views.
        MCtextView.delegate = self
        MCtextView.layer.cornerRadius = 7.0
        MCtextView.font = UIFont(name: "Helvetica", size: 14.0)!
        MCtextView.text = "X"
        MCtextView.frame.size.height = MCtextView.contentSize.height
        MCtextView.text = ""

        //Create the accessoryToolbar to fit correctly into the window
        accessoryToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 5 / 6, height: 44))
        
        //Create spacing items to space the textView and sendButton on the toolbar correctly.
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: self, action: nil)
        fixedSpace.width = 20
        
        //Put the textView and the sendButton onto the toolBar
        accessoryToolbar.items = [flexibleSpace, UIBarButtonItem(customView: MCtextView), fixedSpace, sendButton, flexibleSpace]
        
        MCtextView.becomeFirstResponder()
    }
    
    //This function is called when the sendButton is tapped. 
    //It animates the sending of the message, and then sends the text of the message
    //to the tableView.
    func returntextView()
    {
        //Unwrap the text if there are more than 0 characters
        if let text = MCtextView.text where text.characters.count > 0 {
        
        //This weird looking function, UIView.animateWithDuration, is how
        //iOS handles basic animations. It makes the changes in the block of code
        //happen over a period of time. The following block of code takes 0.3 seconds
        //with no delay after the animation finishes.
            UIView.animateWithDuration(0.3, delay: 0, options: [], animations: { () -> Void in
                
                //Turn off autocorrect once we send the message.
                self.MCtextView.autocorrectionType = .No
                
                //Change the textView to have a green background
                //and change the text color to white.
                self.sendButton.enabled = false
                self.MCtextView.backgroundColor = UIColor(red: 0.04, green: 0.93, blue: 0.094, alpha: 1.0)
                self.MCtextView.textColor = UIColor.whiteColor()
                self.MCtextView.layer.cornerRadius = 10.0
                self.MCtextView.layer.borderWidth = 0.0
                //self.sendButton.tintColor = UIColor.clearColor()
                
                //This syntax is fairly weird, but it is called a "closure." A closure is essentially
                //a block of code that is treated like a variable. We can pass a closure into a function
                //as we would a variable. In this case, the last argument to UIView.animateWithDuration
                //is called "completion:" which is a closure (a block of code) that executes
                //once the animateWithDuration finishes. In this way, we can chain animations together,
                //passing in each subsequent animation to the previous animation's compleition field.
                }, completion: { (_) -> Void in
                UIView.animateWithDuration(0.3, delay: 0, options: [], animations: { () -> Void in
                
                    //Move the textView passed the right of the screen.
                    self.MCtextView.center.x += self.view.bounds.width
                    }, completion: { (_) -> Void in
                    //self.sendButton.tintColor = nil
                    
                    //Return the textView to its normal parameters
                    //once the animation finishes.
                    self.sendButton.enabled = true
                    self.tableView.addMessage(text, date: NSDate(), type: MCChatMessageType.sentMessage)
                    self.MCtextView.text = ""
                    self.MCtextView.frame.size.height = self.MCtextView.contentSize.height
                    self.MCtextView.textColor = UIColor.blackColor()
                    self.MCtextView.backgroundColor = UIColor.whiteColor()
                    self.MCtextView.layer.cornerRadius = 7.0
                    self.MCtextView.layer.borderWidth = 0.3
                    self.MCtextView.center.x -= self.view.bounds.width
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                    //Also resize the toolBar to resize the textView correctly.
                        let offset = self.accessoryToolbar.frame.size.height - self.MCtextView.contentSize.height - 10
                        self.accessoryToolbar.frame.size.height = 44
                        self.accessoryToolbar.frame.origin.y += offset
                        self.MCtextView.autocorrectionType = .Yes
                    })
                })
            })
            //MCtextView.resignFirstResponder()
        }
    }
    
    //This function is part of the protocol of UITextViewDelegate. It is called
    //whenever the textView's text changes, e.g. whenever a user edits the text.
    //This function is used to resize the textView and the toolBar whenever the textView
    //enters a new line.
    func textViewDidChange(textView: UITextView) {
        //Calculate the current number of lines in the textView
        //where numLines = (textView height) / (height of each line of text)
        let numLines:Int = Int(textView.contentSize.height / textView.font!.lineHeight) - 1
        if numLines <= 4
        {
            //Resize the textView to encapsulate its text
            textView.frame.size.height = textView.contentSize.height
            if(numLines != prevNumLines)
            {
                //If the number of lines changed since the previous edit, 
                //resize the toolBar to encapsulate the textView.
                //When the toolBar's size is modified, it stretches vertically
                //and so we have to re-place it above the keyboard as well.
                if (numLines == 1)
                {
                    let offset = accessoryToolbar.frame.size.height - 44
                    accessoryToolbar.frame.size.height = 44
                    accessoryToolbar.frame.origin.y += offset
                }
                else
                {
                    let offset = accessoryToolbar.frame.size.height - textView.contentSize.height - 10
                    accessoryToolbar.frame.size.height = textView.contentSize.height + 10
                    accessoryToolbar.frame.origin.y += offset
                }
            }
        }
        prevNumLines = numLines
    }
    
    //Input accessory view is a property derived from UIViewController. 
    //Whatever this property is set to will constantly rest above the keyboard when
    //the keyboard is displayed. In this case, we want the toolBar to always
    //hover above the keyboard.
    override var inputAccessoryView: UIToolbar? {
        get {
            return self.accessoryToolbar
        }
    }
    
    //prepareForSegue is a standard swift function that is called whenever a 
    //view "segues" (transitions) to another view. In this example, 
    //we use this function to load the tableView – since the tableView is inside
    //of this view, the segue to the table view is an "Embed" segue.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Embed"
        {
            tableView = segue.destinationViewController as! MCChatTableViewController
        }
    }
    
    
    //A function that erases the currently written message and retracts the keyboard.
    func dismissKeyboard()
    {
        MCtextView.autocorrectionType = UITextAutocorrectionType.No
        MCtextView.text = ""
        MCtextView.frame.size.height = 33
        
        //This line is what retracts the keyboard.
        MCtextView.resignFirstResponder()
        
        MCtextView.autocorrectionType = UITextAutocorrectionType.Yes
    }
}
