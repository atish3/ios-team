//
//  MCConnectivityController.swift
//  MCConnect
//
//  Created by Pascal Sturmfels on 2/1/16.
//  Copyright © 2016 Pascal Sturmfels. All rights reserved.
//

import Foundation

//This framework, MultipeerConnectivity, is what we use to do ad-hoc communications.
import MultipeerConnectivity


//A class that manages the sending and receiving of messages using the MultipeerConectivity library.
//It also implements the MCNearbyServiceAdvertiserDelegate and MCNearbyServiceBrowserDelegate
//protocols.
class MCConnectivityController: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    //An MCPeerID is a unique identifier used to identify one's phone on the multipeer network.
    var myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    
    //serviceType is a 15-character or less string that describes 
    //the function that the app is broadcasting.
    let myServiceType = "MDP-broadcast"
    
    //A property that allows this class to push messages to the tableView
    weak var tableViewController: MCChatTableViewController?
    
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
    
    //Standard constructor that constructs a new browser object.
    override init() {
        super.init()
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: myServiceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    //MARK: – MCNearbyServiceAdvertiserDelegate
    //This function is called if the advertiser failed for whatever reason.
    //We are not currently using this function.
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
    
    //This function is called when the advertiser receives an invitation from another phone to 
    //start communicating. Since this app currently does not actually establish a connection
    //with other phones to send messages, we always reject the invitation. 
    //In the future, this needs to change.
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        invitationHandler(false, MCSession())
    }
    
    //MARK: – MCNearbyServiceBrowserDelegate
    //Called if the browser failed to start browsing. We are not currently using this function.
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("didNotStartBrowsingForPeers: \(error)")
    }

    
    //Called if the browser object discovers a new nearby phone. When this happens
    //this function is used to receive that new phone's currently broadcasted message.
    //browser: the browser object that found the new phone
    //peerID: the peerID of the new phone
    //info: the discovery info dictionary. This is a [String:String] dictionary with limited byte
    //      size that the other phone is allowed to share on the network without establishing a conection.
    //      We use this dictionary to broadcast the message.
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        //if let syntax is a common swift paradigm. The if statements only execute if 
        //the object on the right hand side is not null.
        //If the right hand side is not null, the left hand side takes the non-null value
        //of the right hand side.
        if let tvController = tableViewController {
            if let dictionary = info {
                //If the message's key is not the same as my personalKey,
                //e.g. if I wasn't the one who sent this message (avoid receiving the same
                //messages that I sent)
                if let key = dictionary["senderKey"] where key != personalKey {
                    if let messageToSend = dictionary["message"] {
                        //Add the message to the tableViewController using the addMessage function.
                        tvController.addMessage(messageToSend, date: NSDate(), type: MCChatMessageType.receivedMessage)
                    }
                }
            }
        }
    }
    
    //Called if two phones that were previously in range are no longer in range.
    //We are not currently using this function.
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
            print("Lost peer with peer id: \(peerID)")
    }
    
    
}

