//
//  RoarConnectivityController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class RoarConnectivityController : NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    //An MCPeerID is a unique identifier used to identify one's phone on the multipeer network.
    var myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    
    //serviceType is a 15-character or less string that describes
    //the function that the app is broadcasting.
    let myServiceType = "MDP-broadcast"
    
    //A property that allows this class to push messages to the tableView
    weak var tableViewController: RoarTableViewController?
    
    //An object of type MCNearbyServiceBrowser that handles searching for and finding 
    //other phones on the network.
    var serviceBrowser: MCNearbyServiceBrowser!
    
    //An object of type MCNearbyServiceAdvertiser that handles broadcasting one's
    //presence on the network.
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    
    lazy var sessionObject: MCSession = {
        let session = MCSession(peer: self.myPeerId)
        session.delegate = self
        return session
    }()
    
    func createNewAdvertiser(withHashes messageHashes: [String])
    {
        serviceAdvertiser.stopAdvertisingPeer()
        var dictionary = [String: String]()
        for hash in messageHashes {
            dictionary[hash] = ""
        }
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: MCPeerID(displayName: "Device" + String(arc4random_uniform(999999))), discoveryInfo: dictionary, serviceType: myServiceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        print(dictionary)
    }
    
    override init() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: myServiceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: myServiceType)
        
        super.init()
        
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
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
            print("discovery info does not exist")
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
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream withName \(streamName)")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName \(resourceName)")
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        if state == MCSessionState.Connected {
            print("Connected!")
        }
    }
}
