//
//  AnonymouseNavigationStyleController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 9/26/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseNavigationStyleController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = self.navigationBar.bounds
        gradientLayer.frame.size.height += UIApplication.shared.statusBarFrame.height
        
        
        let topColor: UIColor = UIColor(colorLiteralRed: 181.0/255.0, green: 41.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        let bottomColor: UIColor = UIColor(colorLiteralRed: 242.0/255.0, green: 106.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        gradientLayer.colors = [topColor, bottomColor].map{$0.cgColor}
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Set the UIImage as background property
        navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        
        self.navigationBar.tintColor = UIColor.white
        //self.navigationBar.barTintColor = UIColor(red: 253.0/255.0, green: 108.0/255.0, blue: 79.0/255.0, alpha: 1.0)
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
    }
    
}


