//
//  RoarConnectivityController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class RoarConnectivityController : NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
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
    
    //A randomized string that identifies one's phone within this app.
    //Normally, we'd use peerID, but we use that for other purposes... (see below)
    let personalKey: String = String(arc4random_uniform(999999))
    
        //A property that is the current message to be broadcast on the network. 
    //Whenever this property is set, the message is send to the network.
    var message: String? {
        didSet {
            if let messageString = message {
                //Create a dictionary containing the message. The only way to advertise information
                //across the network is through [String:String] dictionaries.
                let myDictionary: [String:String]? = ["message":messageString, "senderKey":String(personalKey)]
                
                //Generate a random peerID. The reason we do this is to be able to rapidly 
                //broadcast new messages without actually establishing connections.
                //(although I want to change this. We should try to avoid this in the future)
                myPeerId = MCPeerID(displayName: "Device" + String(arc4random_uniform(999999)))
                
                //Create a new advertiser object to broadcast the current message.
                serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: myDictionary, serviceType: myServiceType)
                
                //Set the delegate to by myself.
                serviceAdvertiser.delegate = self
                
                //Start advertising the service and the message.
                serviceAdvertiser.startAdvertisingPeer()
            }
        }
    }

    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {

    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {

    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {

    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {

    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
    }
    
}
