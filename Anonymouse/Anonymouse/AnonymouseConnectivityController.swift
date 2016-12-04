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
    let myServiceType: String = "Anonymouse"
    
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
        let ratingSentArray: [AnonymouseRatingSentCore] = messageCoreArray.map { (messageCore) -> AnonymouseRatingSentCore in
            return AnonymouseRatingSentCore(message: messageCore)
        }
        
        do {
            //Encode the messages for sending
            let archivedMessageArray: Data = NSKeyedArchiver.archivedData(withRootObject: messageSentArray)
            try self.sessionObject.send(archivedMessageArray, toPeers: ids, with: MCSessionSendDataMode.reliable)
            
            let archivedRatingArray: Data = NSKeyedArchiver.archivedData(withRootObject: ratingSentArray)
            try self.sessionObject.send(archivedRatingArray, toPeers: ids, with: MCSessionSendDataMode.reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    func sendAllReplies(toRequesters ids: [MCPeerID]) {
        let replyCoreArray: [AnonymouseReplyCore] = dataController.fetchReplies(withKey: "date", ascending: true)
        let replySentArray: [AnonymouseReplySentCore] = replyCoreArray.map { (replyCore) -> AnonymouseReplySentCore in
            return AnonymouseReplySentCore(reply: replyCore)
        }
        let ratingSentArray: [AnonymouseRatingSentCore] = replyCoreArray.map { (replyCore) -> AnonymouseRatingSentCore in
            return AnonymouseRatingSentCore(reply: replyCore)
        }
        
        do {
            let archivedReplyArray: Data = NSKeyedArchiver.archivedData(withRootObject: replySentArray)
            try self.sessionObject.send(archivedReplyArray, toPeers: ids, with: MCSessionSendDataMode.reliable)
            
            let archivedRatingArray: Data = NSKeyedArchiver.archivedData(withRootObject: ratingSentArray)
            try self.sessionObject.send(archivedRatingArray, toPeers: ids, with: MCSessionSendDataMode.reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    
    //This functions sends an individual message to all connected peers.
    //It is meant to be used when the user is connected to nearby peers
    //and they compose a new message.
    func send(individualMessage message: AnonymouseMessageSentCore) {
        guard sessionObject.connectedPeers.count > 0 else {
            return
        }
        
        do {
            let archivedMessage: Data = NSKeyedArchiver.archivedData(withRootObject: message)
            try self.sessionObject.send(archivedMessage, toPeers: sessionObject.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    func send(individualReply reply: AnonymouseReplySentCore) {
        guard sessionObject.connectedPeers.count > 0 else {
            return
        }
        
        do {
            let archivedMessage: Data = NSKeyedArchiver.archivedData(withRootObject: reply)
            try self.sessionObject.send(archivedMessage, toPeers: sessionObject.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    func send(individualRating rating: AnonymouseRatingSentCore) {
        guard sessionObject.connectedPeers.count > 0 else {
            return
        }
        
        do {
            let archivedRating: Data = NSKeyedArchiver.archivedData(withRootObject: rating)
            try self.sessionObject.send(archivedRating, toPeers: sessionObject.connectedPeers, with: MCSessionSendDataMode.reliable)
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
        
        //When this app receives an invitation to connect, it accepts it immediately.
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
            let messageHash: String = message.text.sha1()
            let messageHashes: [String] = dataController.fetchMessageHashes()
            //Add the message if we don't have it already
            if !messageHashes.contains(messageHash) {
                self.dataController.addMessage(message.text!, date: message.date!, user: message.user!)
            }
        }
            //Check if the message sent was an array of messages
        else if let messageArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnonymouseMessageSentCore] {
            let messageHashes: [String] = dataController.fetchMessageHashes()
            for message in messageArray {
                //Add each message if we don't have it
                let messageHash: String = message.text.sha1()
                if !messageHashes.contains(messageHash) {
                    self.dataController.addMessage(message.text!, date: message.date!, user: message.user!)
                }
            }
        }
        else if let reply = NSKeyedUnarchiver.unarchiveObject(with: data) as? AnonymouseReplySentCore {
            let replyHashes: [String] = dataController.fetchReplyHashes()
            let replyHash: String = reply.text.sha1()
            if !replyHashes.contains(replyHash) {
                let messageObjects: [AnonymouseMessageCore] = dataController.fetchObjects(withKey: "date", ascending: true)
                for message in messageObjects {
                    if message.text!.sha1() == reply.parentHash {
                        dataController.addReply(withText: reply.text!, date: reply.date!, user: reply.user!, toMessage: message)
                        break
                    }
                }
            }
        }
        else if let replyArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnonymouseReplySentCore] {
            let replyHashes: [String] = dataController.fetchReplyHashes()
            let messageObjects: [AnonymouseMessageCore] = dataController.fetchObjects(withKey: "date", ascending: true)
            for reply in replyArray {
                let replyHash: String = reply.text.sha1()
                if !replyHashes.contains(replyHash) {
                    for message in messageObjects {
                        if message.text!.sha1() == reply.parentHash {
                            dataController.addReply(withText: reply.text!, date: reply.date!, user: reply.user!, toMessage: message)
                            break
                        }
                    }
                }
            }
        }
        else if let rating = NSKeyedUnarchiver.unarchiveObject(with: data) as? AnonymouseRatingSentCore {
            let messageCoreArray: [AnonymouseMessageCore] = dataController.fetchObjects(withKey: "date", ascending: true)
            for message in messageCoreArray {
                if message.text!.sha1() == rating.messageHash {
                    let previousRating: Int = Int(message.rating!)
                    message.rating = NSNumber(integerLiteral: rating.rating! + previousRating)
                    return
                }
            }
            let replyCoreArray: [AnonymouseReplyCore] = dataController.fetchReplies(withKey: "date", ascending: true)
            for reply in replyCoreArray {
                if reply.text!.sha1() == rating.messageHash {
                    let previousRating: Int = Int(reply.rating!)
                    reply.rating = NSNumber(integerLiteral: rating.rating! + previousRating)
                    return
                }
            }
        }
        else if let ratingArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnonymouseRatingSentCore] {
            let messageCoreArray: [AnonymouseMessageCore] = dataController.fetchObjects(withKey: "date", ascending: true)
            var messageCoreDictionary: [String: AnonymouseMessageCore] = [String: AnonymouseMessageCore]()
            for message in messageCoreArray {
                messageCoreDictionary[message.text!.sha1()] = message
            }
            
            let replyCoreArray: [AnonymouseReplyCore] = dataController.fetchReplies(withKey: "date", ascending: true)
            var replyCoreDictionary: [String: AnonymouseReplyCore] = [String:AnonymouseReplyCore]()
            for reply in replyCoreArray {
                replyCoreDictionary[reply.text!.sha1()] = reply
            }
            
            for rating in ratingArray {
                if let message = messageCoreDictionary[rating.messageHash] {
                    let previousRating: Int = Int(message.rating!)
                    message.rating = NSNumber(integerLiteral: rating.rating! + previousRating)
                }
                if let reply = replyCoreDictionary[rating.messageHash] {
                    let previousRating: Int = Int(reply.rating!)
                    reply.rating = NSNumber(integerLiteral: rating.rating! + previousRating)
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
            self.sendAllReplies(toRequesters: [peerID])
        }
        else if state == MCSessionState.connecting
        {
            
        }
        else if state == MCSessionState.notConnected {
            
        }
    }
}
