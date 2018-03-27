//
//  iBeaconViewController.swift
//  Anonymouse
//
//  Created by Eli Masjedi on 3/23/18.
//  Copyright © 2018 1AM. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth
import UIKit

struct ItemConstant {
    static let nameKey = "name"
    static let uuidKey = "uuid"
    static let majorKey = "major"
    static let minorKey = "minor"
}

class Item: NSObject {
    let name: String
    let uuid: UUID
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    var beacon: CLBeacon?
    
    init(name: String, uuid: UUID, majorValue: Int, minorValue: Int) {
        self.name = name
        self.uuid = uuid
        self.majorValue = CLBeaconMajorValue(majorValue)
        self.minorValue = CLBeaconMinorValue(minorValue)
    }
    
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: uuid,
                              major: majorValue,
                              minor: minorValue,
                              identifier: name)
    }
}



let storedItemsKey = "storedItems"

class ItemsViewController: UIViewController, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let locationManager = CLLocationManager()
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        peripheralManager.delegate = self
        
    }
    
    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        
        let localBeaconUUID = "CBA87AB2-AB69-495C-9B82-2FE741D6689D"
        let localBeaconMajor: CLBeaconMajorValue = 123
        let localBeaconMinor: CLBeaconMinorValue = 456
        
        let uuid = UUID(uuidString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "Anonymouse.beacon")
        
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            print("error" + (error?.localizedDescription)!)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        print("dict \(dict)")
    }
    
    func startMonitoringItem(_ item: Item) {
        let beaconRegion = item.asBeaconRegion()
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func stopMonitoringItem(_ item: Item) {
        let beaconRegion = item.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    

func advertiseDevice(region : CLBeaconRegion) {
    let peripheral = CBPeripheralManager(delegate: self, queue: nil)
    let peripheralData = region.peripheralData(withMeasuredPower: nil)
    
    
    peripheral.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
    
}
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        print("started advertising")
        print(peripheral)
    }
    
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("peripheral state updated")
        print("\(peripheral.description)")
    }
    
}

extension ItemsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        // Find the same beacons in the table.
        for beacon in beacons {
            for row in 0..<items.count {
                NSLog("\(row) \(nameForProximity(beacon.proximity))")
                // TODO: Determine if item is equal to ranged beacon
            }
        }
    }
}

func ==(item: Item, beacon: CLBeacon) -> Bool {
    return ((beacon.proximityUUID.uuidString == item.uuid.uuidString)
        && (Int(beacon.major) == Int(item.majorValue))
        && (Int(beacon.minor) == Int(item.minorValue)))
}

func nameForProximity(_ proximity: CLProximity) -> String {
    switch proximity {
    case .unknown:
        return "Unknown"
    case .immediate:
        return "Immediate"
    case .near:
        return "Near"
    case .far:
        return "Far"
    }
}

func createBeacon() {
    let UUIDspecific = UUID.init(uuidString: "CBA87AB2-AB69-495C-9B82-2FE741D6689D")
    let item = Item.init(name: "Anonymouse.beacon", uuid: UUIDspecific!, majorValue: 123, minorValue: 456)
    let localbeacon = item.asBeaconRegion()
    let view = ItemsViewController()
    view.advertiseDevice(region: localbeacon)
}


    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    var localBeacon: CLBeaconRegion!
//    var beaconPeripheralData: NSDictionary!
//    var peripheralManager: CBPeripheralManager!
//    let locationManager = CLLocationManager()
//
//    func initLocalBeacon() {
//        if localBeacon != nil {
//            stopLocalBeacon()
//            NSLog("Beacon Stoppped")
//        }
//
//        let localBeaconUUID = "CBA87AB2-AB69-495C-9B82-2FE741D6689D"
//        let localBeaconMajor: CLBeaconMajorValue = 123
//        let localBeaconMinor: CLBeaconMinorValue = 456
//
//        let uuid = UUID(uuidString: localBeaconUUID)!
//        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "Anonymouse.beacon")
//
//        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
//        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
//        NSLog("Hi I'm a beacon")
//    }
//
//    func stopLocalBeacon() {
//        peripheralManager.stopAdvertising()
//        peripheralManager = nil
//        beaconPeripheralData = nil
//        localBeacon = nil
//        NSLog("Hi I'm not a beacon")
//    }
//
//    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
//        if peripheral.state == .poweredOn {
//            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
//        } else if peripheral.state == .poweredOff {
//            peripheralManager.stopAdvertising()
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Ask for Authorisation from the User.
//        self.locationManager.requestAlwaysAuthorization()
//
//        // For use in foreground
//        self.locationManager.requestWhenInUseAuthorization()
//
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.delegate = self as? CLLocationManagerDelegate
//            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
//        }
//
//    }
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedAlways {
//            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
//                if CLLocationManager.isRangingAvailable() {
//                    startScanning()
//                }
//            }
//        }
//    }
//
//    func startScanning() {
//        NSLog("I'm scanning")
//        let uuid = UUID(uuidString: "CBA87AB2-AB69-495C-9B82-2FE741D6689D")!
//        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "Anonymouse.beacon")
//
//        locationManager.startMonitoring(for: beaconRegion)
//        locationManager.startRangingBeacons(in: beaconRegion)
//    }
//
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        NSLog("Happened")
//    }
//
//    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        NSLog("location manager")
//        if beacons.count > 0 {
//            updateDistance(beacons[0].proximity)
//        } else {
//            updateDistance(.unknown)
//        }
//    }
//
//    func updateDistance(_ distance: CLProximity) {
//        UIView.animate(withDuration: 0.8) {
//            switch distance {
//            case .unknown:
//                NSLog("Unknown")
//            case .far:
//                NSLog("Far")
//
//            case .near:
//                NSLog("Near")
//
//            case .immediate:
//                NSLog("Immediate")
//            }
//        }
//    }
// }
