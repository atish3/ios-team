//
//  ViewController.swift
//  MCtests
//
//  Created by Pascal Sturmfels and Yufan Sun on 1/15/16.
//  Copyright © 2016 Pascal Sturmfels and Yufan Sun. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, UITextViewDelegate {

    //MARK: – Properties
    
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var broadcastField: UITextView!
    
    
    var myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    let myServiceType = "MDP-broadcast"
    var isReceiving : Bool = false
    var isBroadcasting : Bool = false
    
    var serviceBrowser : MCNearbyServiceBrowser!
    var serviceAdvertiser : MCNearbyServiceAdvertiser!

    @IBOutlet weak var broadcastButton: UIButton!
    
    @IBOutlet weak var receiveButton: UIButton!
    
    //MARK: – IBActions
    @IBAction func broadcastTapped(sender: AnyObject) {
        if isBroadcasting {
            print("Stopped broadcasting.")
            isBroadcasting = false
            serviceAdvertiser.stopAdvertisingPeer() //NOTE: Deallocate this object later
            broadcastButton.setTitle("Broadcast", forState: .Normal)
        }
        else {
            let myDictionary: [String:String]? = ["message":broadcastField.text]
            print("Broadcasting: '\(broadcastField.text)'")
            myPeerId = MCPeerID(displayName: "Device" + String(arc4random_uniform(999999)))
            serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: myDictionary, serviceType: myServiceType)
            serviceAdvertiser.delegate = self
            serviceAdvertiser.startAdvertisingPeer()
            isBroadcasting = true
            broadcastButton.setTitle("Stop Broadcasting", forState: .Normal)
        }
    
    }

    @IBAction func receiveTapped(sender: AnyObject) {
        if isReceiving {
            print("Stopped receiving.")
            isReceiving = false
            serviceBrowser.stopBrowsingForPeers()
            receiveButton.setTitle("Receive", forState: .Normal)
        }
        else {
            print("Receiving...")
            serviceBrowser.startBrowsingForPeers()
            isReceiving = true
            receiveButton.setTitle("Stop Receiving", forState: .Normal)
        }
    }
    
    //MARK: - MCNearbyServiceAdvertiserDelegate
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(false, MCSession())
    }
    
    //MARK: - MCNearbyServiceBrowserDelegate
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if isReceiving
        {
            NSLog("%@", "foundPeer: \(peerID)")
            if let discovery_info = info
            {
                receiveLabel.text = peerID.displayName + ": " + (discovery_info["message"] ?? "No message sent.")
                print(receiveLabel.text!)
            }
            else
            {
                receiveLabel.text = "\(peerID.displayName): No dictionary sent."
                print("\(peerID.displayName): No dictionary sent.")
            }
        }
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
    //MARK: - UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
        let maxChars = 240
        if textView.text.characters.count > maxChars
        {
            let charAC = UIAlertController(title: "Error: too many characters", message: "You can broadcast at most \(maxChars) characters", preferredStyle: .Alert)
            charAC.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(charAC, animated: true, completion: {() -> Void in
                textView.text = textView.text.substringToIndex(textView.text.startIndex.advancedBy(maxChars))
            })
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        broadcastField.resignFirstResponder()
    }
    
    //MARK: - UIKeyboardMethods
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            self.view.frame.origin.y -= keyboardSize.height / 3
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            self.view.frame.origin.y += keyboardSize.height / 3
        }
    }
    
    
    //MARK: - Default Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        broadcastField.delegate = self
        broadcastField.layer.borderColor = UIColor.blackColor().CGColor
        broadcastField.layer.borderWidth = 1.0
        broadcastField.layer.cornerRadius = 5.0
        
        receiveLabel.layer.borderColor = UIColor.blackColor().CGColor
        receiveLabel.layer.borderWidth = 1.0
        receiveLabel.layer.cornerRadius = 5.0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    required init?(coder aDecoder: NSCoder) {
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: myServiceType)
        super.init(coder: aDecoder)
        
        serviceBrowser.delegate = self
    }
    
    deinit {
        if isBroadcasting
        {
            serviceAdvertiser.stopAdvertisingPeer()
        }
        if isReceiving
        {
            serviceBrowser.stopBrowsingForPeers()
        }
    }
}

