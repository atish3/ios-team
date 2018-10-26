//
//  AnonymousePeripheralManagerDelegate.swift
//  Anonymouse
//
//  Created by Atishay Singh on 10/7/18.
//  Copyright © 2018 1AM. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreLocation


class AnonymousePeripheralManagerDelegate: NSObject, CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager){
        print("State updated")
        switch(peripheral.state){
        case .poweredOn:
            print("Powered on")
            break;
        case .unknown:
            print("Actually is unknown")
        default:
            print(peripheral.state.rawValue);
            break;
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if(error != nil){
            print(error!)
        }
        else{
            print("Started Advertising Successfully")
        }
    }
    
}
