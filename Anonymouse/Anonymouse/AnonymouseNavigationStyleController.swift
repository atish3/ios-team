//
//  AnonymouseNavigationStyleController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 9/26/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

/**
 A child of `UINavigationController` with an orange gradient and white text.
 */
class AnonymouseNavigationStyleController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = self.navigationBar.bounds
        gradientLayer.frame.size.height += UIApplication.shared.statusBarFrame.height
        
        
        let topColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.9490196078, green: 0.4156862745, blue: 0.3137254902, alpha: 1)
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
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
    }
    
}


