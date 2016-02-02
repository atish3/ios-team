//
//  MCConnectivityController.swift
//  MCConnect
//
//  Created by Pascal Sturmfels on 2/1/16.
//  Copyright © 2016 Pascal Sturmfels. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MCConnectivityController: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    var myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    let myServiceType = "MDP-broadcast"
    weak var tableViewController: MCChatTableViewController?
    
    var serviceBrowser: MCNearbyServiceBrowser!
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    let personalKey: String = String(arc4random_uniform(999999))
    
    var message: String? {
        didSet {
            if let messageString = message {
                let myDictionary: [String:String]? = ["message":messageString, "senderKey":String(personalKey)]
                myPeerId = MCPeerID(displayName: "Device" + String(arc4random_uniform(999999)))
                serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: myDictionary, serviceType: myServiceType)
                serviceAdvertiser.delegate = self
                serviceAdvertiser.startAdvertisingPeer()
                print("\(myPeerId.displayName) started advertising '\(messageString)'")
            }
        }
    }
    
    override init() {
        super.init()
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: myServiceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    //MARK: – MCNearbyServiceAdvertiserDelegate
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        invitationHandler(false, MCSession())
    }
    
    //MARK: – MCNearbyServiceBrowserDelegate
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let tvController = tableViewController {
            if let dictionary = info {
                if let key = dictionary["senderKey"] where key != personalKey {
                    if let messageToSend = dictionary["message"] {
                        tvController.addMessage(messageToSend, date: NSDate(), type: MCChatMessageType.receivedMessage)
                    }
                }
            }
        }
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
            print("Lost peer with peer id: \(peerID)")
    }
    
    
}

