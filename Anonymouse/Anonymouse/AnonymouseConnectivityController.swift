//
//  AnonymouseConnectivityController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData

extension MCSessionState {
    func stringValue() -> String {
        switch(self) {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
}

class AnonymouseConnectivityController : NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    
    //MARK: Links
    weak var dataController: AnonymouseDataController!
    
    //MARK: Connection Parameters
    //An MCPeerID is a unique identifier used to identify one's phone on the multipeer network.
    var myPeerId: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    //serviceType is a 15-character or less string that describes
    //the function that the app is broadcasting.
    let myServiceType: String = "MDP-broadcast"
    
    //An object of type MCNearbyServiceBrowser that handles searching for and finding
    //other phones on the network.
    var serviceBrowser: MCNearbyServiceBrowser!
    
    //An object of type MCNearbyServiceAdvertiser that handles broadcasting one's
    //presence on the network.
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    
    var isBrowsing: Bool = true
    var isAdvertising: Bool = true
    
    //An MCSession object is an object that manages communication among peers.
    //When a peer wants to send data to another connected peer, they send it through the 
    //sessionObject.
    lazy var sessionObject: MCSession = {
        let session: MCSession = MCSession(peer: self.myPeerId)
        session.delegate = self
        return session
    }()
    
    //MARK: Convenience methods
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
    
    func disconnectFromSession() {
        self.sessionObject.disconnect()
    }
    
    func killConnectionParameters() {
        disconnectFromSession()
        stopBrowsingForPeers()
        stopAdvertisingPeer()
    }
    
    //Class constructor: it sets the link to the dataController,
    //and creates the advertiser and browser objects
    override init() {
        unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: myServiceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: myServiceType)
        super.init()
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        
        startAdvertisingPeer()
        startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    
    //MARK: Data transfer methods
    
    //This function sends all owned messages to the passed-in peers.
    //It maps the stored messages, which are saved as CoreArray objects, 
    //to SentArray objects, which conform to NSCoding protocol.
    //It is meant to be used when a peer first connects with another peer.
    func sendAllMessages(toRequesters ids: [MCPeerID]) {
        let messageCoreArray: [AnonymouseMessageCore] = dataController.fetchObjects(withKey: "date", ascending: true)
        let messageSentArray: [AnonymouseMessageSentCore] = messageCoreArray.map { (messageCore) -> AnonymouseMessageSentCore in
            return AnonymouseMessageSentCore(message: messageCore)
        }
        
        do {
            //Encode the messages for sending
            let archivedSentArray: Data = NSKeyedArchiver.archivedData(withRootObject: messageSentArray)
            try self.sessionObject.send(archivedSentArray, toPeers: ids, with: MCSessionSendDataMode.reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    //This functions sends an individual message to all connected peers. 
    //It is meant to be used when the user is connected to nearby peers 
    //and they compose a new message.
    func send(individualMessage message: AnonymouseMessageSentCore) {
        do {
            let archivedMessage: Data = NSKeyedArchiver.archivedData(withRootObject: message)
            try self.sessionObject.send(archivedMessage, toPeers: sessionObject.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    //MARK: MCNearbyServiceBrowserDelegate Methods
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        //When a new peer is found, invite it immediately
        //This needs to be changed to only invite peers that are using this app
        browser.invitePeer(peerID, to: sessionObject, withContext: nil, timeout: 30.0)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
    
    //MARK: MCNearbyServiceAdvertiserDelegate Methods
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        
        //When this app receives an invitation to connect, it accepts it immediatey.
        //This needs to be changed to only accept peers that are using this app.
        invitationHandler(true, self.sessionObject)
    }
    
    //MARK: MCSessionDelegate Methods
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName \(resourceName)")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        NSLog("%@", "didReceiveCertificate from peer \(peerID)")
        //Check the certificate of a peer. 
        //This needs to be changed to validate the certificate the peer sends.
        certificateHandler(true)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data.count) bytes from peer \(peerID)")
        //There are only two types of data that this app sends: a single message, or a group of messages
        
        //Check if the message sent was a single message
        if let message = NSKeyedUnarchiver.unarchiveObject(with: data) as? AnonymouseMessageSentCore {
            print("Did receive single message")
            let messageHashes: [String] = dataController.fetchMessageHashes()
            //Add the message if we don't have it already
            if !messageHashes.contains(message.messageHash) {
                while self.dataController.getSize() > 1000 {
                    self.dataController.deleteLastMessage()
                }
                self.dataController.addMessage(message.text!, date: message.date!, user: message.user!)
            }
        }
        //Check if the message sent was an array of messages
        else if let messageArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnonymouseMessageSentCore] {
            print("Did receive dictionary of messages")
            let messageHashes: [String] = dataController.fetchMessageHashes()
            for message in messageArray {
                //Add each message if we don't have it
                if !messageHashes.contains(message.messageHash) {
                    while self.dataController.getSize() > 1000 {
                       self.dataController.deleteLastMessage()
                    }
                    self.dataController.addMessage(message.text!, date: message.date!, user: message.user!)
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
        //The moment we connect to a peer, send them all of our messages.
        if state == MCSessionState.connected {
            self.sendAllMessages(toRequesters: [peerID])
        }
        else if state == MCSessionState.connecting
        {
            
        }
        else if state == MCSessionState.notConnected {
            
        }
    }
}
