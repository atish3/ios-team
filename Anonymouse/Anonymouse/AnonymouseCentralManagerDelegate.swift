//
//  AnonymouseCentralManagerDelegate.swift
//  Anonymouse
//
//  Created by Atishay Singh on 10/12/18.
//  Copyright © 2018 1AM. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreLocation
import MultipeerConnectivity

class AnonymouseCentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    
    unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    weak var connectivityController: AnonymouseConnectivityController!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central State updated")
        switch(central.state){
        case .poweredOn:
            print("Powered on")
            break;
        case .unknown:
            print("Actually is unknown")
        default:
            print(central.state.rawValue);
            break;
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print(peripheral.name!)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(RSSI)
        print("FOUND ONE")
        connectivityController = appDelegate.connectivityController
        connectivityController.inBack = true
        connectivityController.stopBrowsingForPeers()
        connectivityController.startBrowsingForPeers()

    }
}
