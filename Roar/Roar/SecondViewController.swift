//
//  SecondViewController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        profileImage = UIImageView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        profileImage.image = UIImage(named: "profile_default")
        
        self.view.addSubview(profileImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

