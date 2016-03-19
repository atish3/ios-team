//
//  RoarConnectivityController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import MultipeerConnectivity

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
    
}

class RoarConnectivityController : NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    //An MCPeerID is a unique identifier used to identify one's phone on the multipeer network.
    var myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    
    //serviceType is a 15-character or less string that describes
    //the function that the app is broadcasting.
    let myServiceType = "MDP-broadcast"
    
    //A property that allows this class to push messages to the tableView
    weak var tableViewController: RoarTableViewController?
    
    weak var navigationController: RoarNavigationController?
    
    //An object of type MCNearbyServiceBrowser that handles searching for and finding 
    //other phones on the network.
    var serviceBrowser: MCNearbyServiceBrowser!
    
    //An object of type MCNearbyServiceAdvertiser that handles broadcasting one's
    //presence on the network.
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    
    var isBrowsing = false
    var isAdvertising = false
    var isReceivingHashes = false
    var isReceivingMessages = false
    var peerHashes: [String]!
    
    lazy var sessionObject: MCSession = {
        let session = MCSession(peer: self.myPeerId)
        session.delegate = self
        return session
    }()
    
    func createNewAdvertiser(withHashes messageHashes: [String]) {
        var dictionary = [String: String]()
        for hash in messageHashes {
            dictionary[hash] = ""
        }
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: dictionary, serviceType: myServiceType)
        serviceAdvertiser.delegate = self
    }
    
    func startAdvertisingPeer() {
        serviceAdvertiser.startAdvertisingPeer()
        isAdvertising = true
    }
    
    func stopAdvertisingPeer() {
        serviceAdvertiser.stopAdvertisingPeer()
        isAdvertising = false
    }
    
    func startBrowsingForPeers() {
        serviceBrowser.startBrowsingForPeers()
        isBrowsing = true
    }
    
    func stopBrowsingForPeers() {
        serviceBrowser.stopBrowsingForPeers()
        isBrowsing = false
    }
    
    override init() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: myServiceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: myServiceType)
        
        super.init()
        
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        
    }
    
    func sendMessage(message: String) {
        do {
            try self.sessionObject.sendData(message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: self.sessionObject.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    func sendHashesToPeers() {
        do {
            if let tableVC = self.tableViewController {
                try self.sessionObject.sendData("@@@hashbegin".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: self.sessionObject.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                for hash in tableVC.messageHashes {
                    try self.sessionObject.sendData(hash.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: self.sessionObject.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                }
                try self.sessionObject.sendData("@@@hashend".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: self.sessionObject.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    func sendMissingMessagesToPeers() {
        do {
            try self.sessionObject.sendData("@@@messagebegin".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: self.sessionObject.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            if let tableVC = self.tableViewController {
                for var index = 0; index < tableVC.messageHashes.count; ++index {
                    if peerHashes.indexOf(tableVC.messageHashes[index]) == nil {
                        let encodedMessage = NSKeyedArchiver.archivedDataWithRootObject(tableVC.cellDataArray[index].message)
                        try self.sessionObject.sendData(encodedMessage, toPeers: self.sessionObject.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                    }
                }
            }
            let encodedEndMessage = NSKeyedArchiver.archivedDataWithRootObject(RoarMessageCore(text: "@@@messageend", date: NSDate(), user: UIDevice.currentDevice().name))
            try self.sessionObject.sendData(encodedEndMessage, toPeers: self.sessionObject.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }

    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        var didInvitePeer = false
        
        if let peerHashes = info
        {
            if let tableVC = tableViewController {
                for hash in tableVC.messageHashes {
                    if peerHashes[hash] == nil {
                        NSLog("%@", "invitePeer: \(peerID)")
                        browser.invitePeer(peerID, toSession: sessionObject, withContext: nil, timeout: 5)
                        didInvitePeer = true
                        break
                    }
                }
                if !didInvitePeer {
                    for (hash, _) in peerHashes {
                        if tableVC.messageHashes.indexOf(hash) == nil {
                            NSLog("%@", "invitePeer: \(peerID)")
                            browser.invitePeer(peerID, toSession: sessionObject, withContext: nil, timeout: 5)
                            didInvitePeer = true
                            break
                        }
                    }
                }
            }
            else {
                print("TableView does not exist")
            }
        }
        else {
            print("Discovery info does not exist")
        }
        if !didInvitePeer {
            NSLog("%@", "didNotInvitePeer: \(peerID)")
        }
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.sessionObject)
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName \(resourceName)")
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        NSLog("%@", "didReceiveCertificate from peer \(peerID)")
        certificateHandler(true)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data.length) bytes from peer \(peerID)")
        if isReceivingMessages {
            if let tableVC = tableViewController {
                if let receivedMessage = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? RoarMessageCore {
                    print(receivedMessage.text)
                    if receivedMessage.text == "@@@messageend" {
                        isReceivingMessages = false
                    }
                    else {
                        print("addMessage called on \(tableVC.cellDataArray[tableVC.cellDataArray.count - 1].message.text)")
                        tableVC.addMessage(receivedMessage)
                    }
                }
                else {
                    NSLog("%@", "Error: received message was not of type RoarMessageCore")
                }
            }
        }
        else {
            let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
            if str == "@@@messagebegin" {
                isReceivingMessages = true
            }
            else if str == "@@@hashbegin" {
                peerHashes = [String]()
                isReceivingHashes = true
            }
            else if str == "@@@hashend" {
                sendMissingMessagesToPeers()
                isReceivingHashes = false
            }
            else if isReceivingHashes {
                peerHashes.append(str)
            }
        }
        
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream withName \(streamName)")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName \(resourceName)")
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        if state == MCSessionState.Connected {
            sendHashesToPeers()
        }
        else
        {
            
        }
    }
}