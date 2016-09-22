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
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
}

class RoarConnectivityController : NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    //An MCPeerID is a unique identifier used to identify one's phone on the multipeer network.
    var myPeerId: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    //serviceType is a 15-character or less string that describes
    //the function that the app is broadcasting.
    let myServiceType: String = "MDP-broadcast"
    
    //A property that allows this class to push messages to the tableView
    weak var tableViewController: RoarTableViewController!
    
    //A property that allows this class to reference the owning controller
    weak var navigationController: RoarNavigationController!
    
    //An object of type MCNearbyServiceBrowser that handles searching for and finding
    //other phones on the network.
    var serviceBrowser: MCNearbyServiceBrowser!
    
    //An object of type MCNearbyServiceAdvertiser that handles broadcasting one's
    //presence on the network.
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    
    var newMessagesReceived:Int = 0
    var isBrowsing: Bool = false
    var isAdvertising: Bool = false
    
    lazy var sessionObject: MCSession = {
        let session: MCSession = MCSession(peer: self.myPeerId)
        session.delegate = self
        return session
    }()
    
    func createNewAdvertiser(withHashes messageHashes: [String]) {
        var dictionary: [String: String] = [String: String]()
        for hash in messageHashes {
            dictionary[hash] = ""
        }
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: dictionary, serviceType: myServiceType)
        serviceAdvertiser.delegate = self
    }
    
    func startAdvertisingPeer() {
        serviceAdvertiser.startAdvertisingPeer()
        isAdvertising = true
        newMessagesReceived = 0
    }
    
    func stopAdvertisingPeer() {
        serviceAdvertiser.stopAdvertisingPeer()
        isAdvertising = false
    }
    
    func startBrowsingForPeers() {
        serviceBrowser.startBrowsingForPeers()
        isBrowsing = true
        newMessagesReceived = 0
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
    
    
    func broadcastHashMessageDictionary(toRequester id: MCPeerID, excludingHashes hashArray: [String]) {
        do {
                let messageDictionary: [RoarMessageSentCore] = tableViewController.returnMessageArray(excludingHashes: hashArray)
                let messageDictionaryData: Data = NSKeyedArchiver.archivedData(withRootObject: messageDictionary)
                try self.sessionObject.send(messageDictionaryData, toPeers: [id], with: MCSessionSendDataMode.reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    func sendIndividualMessage(_ message: RoarMessageSentCore) {
        do {
            let messageData: Data = NSKeyedArchiver.archivedData(withRootObject: message)
            try self.sessionObject.send(messageData, toPeers: self.sessionObject.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    func requestMessagesFromPeer() {
        do {
                let concatenatedHashes: String = tableViewController.messageHashes.joined(separator: " ")
                try self.sessionObject.send(("@@@messagereq " + concatenatedHashes).data(using: String.Encoding.utf8, allowLossyConversion: false)!, toPeers: self.sessionObject.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        var didInvitePeer: Bool = false
        
        if let peerHashes = info
        {
                let messageHashes: [String] = tableViewController.messageHashes
                for hash in messageHashes {
                    if peerHashes[hash] == nil {
                        NSLog("%@", "invitePeer: \(peerID)")
                        browser.invitePeer(peerID, to: sessionObject, withContext: nil, timeout: 5)
                        didInvitePeer = true
                        break
                    }
                }
                if !didInvitePeer {
                    for (hash, _) in peerHashes {
                        if messageHashes.index(of: hash) == nil {
                            NSLog("%@", "invitePeer: \(peerID)")
                            browser.invitePeer(peerID, to: sessionObject, withContext: nil, timeout: 5)
                            didInvitePeer = true
                            break
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
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.sessionObject)
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName \(resourceName)")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        NSLog("%@", "didReceiveCertificate from peer \(peerID)")
        certificateHandler(true)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data.count) bytes from peer \(peerID)")
        var didReceiveRequest = false
        if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
            let hashArray: [String] = str.components(separatedBy: " ")
            if hashArray[0] == "@@@messagereq" {
                print("Received request for messages from \(peerID)")
                broadcastHashMessageDictionary(toRequester: peerID, excludingHashes: Array(hashArray[1..<hashArray.count]))
                didReceiveRequest = true
            }
        }
        if !didReceiveRequest {
                if let message = NSKeyedUnarchiver.unarchiveObject(with: data) as? RoarMessageSentCore {
                    print("Did receive single message")
                    if !tableViewController.messageHashes.contains(message.text!.sha1()) {
                        tableViewController.addMessage(message.text!, date: message.date!, user: message.user!)
                        newMessagesReceived += 1
                }
                if let messageArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [RoarMessageSentCore] {
                    print("Did receive dictionary of messages")
                    for message in messageArray {
                        tableViewController.addMessage(message.text!, date: message.date!, user: message.user!)
                        newMessagesReceived += 1
                    }
                    if self.newMessagesReceived > 20 {
                        self.sessionObject.disconnect()
                    
                    }
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream withName \(streamName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName \(resourceName)")
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        if state == MCSessionState.connected {
            requestMessagesFromPeer()
        }
        else
        {
            
        }
    }
}
