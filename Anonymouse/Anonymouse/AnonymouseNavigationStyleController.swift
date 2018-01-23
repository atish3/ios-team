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
        
        
        //let topColor: UIColor = UIColor(colorLiteralRed: 181.0/255.0, green: 41.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        //let bottomColor: UIColor = UIColor(colorLiteralRed: 242.0/255.0, green: 106.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        let bottomColor = #colorLiteral(red: 0.9501768284, green: 0.1613365005, blue: 0.1470532534, alpha: 1)
        let topColor = #colorLiteral(red: 0.7098039216, green: 0.1607843137, blue: 0.1450980392, alpha: 1)
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


