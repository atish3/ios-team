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
            print("Unknown")
            break;
        case .poweredOff:
            print("Turn on Bluetooth")
            //Prompt user to turn on Bluetooth
            break;
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
            print(peripheral.isAdvertising)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                                    didAdd service: CBService,
                                    error: Error?){
        if(error != nil){
            print(error!)
        }
        else{
            print("Added successfully")
        }
    }
    
}
