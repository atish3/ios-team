//
//  SecondViewController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    var clickMeButton: UIButton!

    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        clickMeButton = UIButton(type: .System)
        clickMeButton.setTitle("Click Me!", forState: UIControlState.Normal)
        clickMeButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        clickMeButton.sizeToFit()
        clickMeButton.addTarget(self, action: #selector(SecondViewController.changeText), forControlEvents: .TouchUpInside)
        clickMeButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(clickMeButton)
        let centerXConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: clickMeButton, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: clickMeButton, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 100)
        
        self.view.addConstraints([centerXConstraint, centerYConstraint])
    }

    func changeText() {
        textLabel.text = String(arc4random_uniform(1000))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

