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
import CoreLocation
import CoreBluetooth
import Alamofire
import SwiftyJSON




///A class that manages the connectivity protocols; sending messages and rating objects to nearby peers.
class AnonymouseConnectivityController : NSObject {
    
    //class AnonymouseConnectivityController : NSObject {
    
    //MARK: Links
    ///A weak reference to the `dataController`, which allows this class to store received messages.
    weak var dataController: AnonymouseDataController!
    
    weak var delegate: AnonymousePeripheralManagerDelegate!
    
    var peripheralManager : CBPeripheralManager
    
    var service: CBMutableService
    
    var fxn = "getMessageViaHTTP()"
    
    var receiveTimer = Timer()
    
    
    
    ///`true` if this object is currently browsing.
    var isBrowsing: Bool = true
    ///`true` if this object is currently advertising.
    var isAdvertising: Bool = true
    
    
    override init() {
        unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        delegate = appDelegate.peripheralDelegate
        peripheralManager  = CBPeripheralManager.init(delegate: delegate, queue: nil, options: nil)
        var newUUID : CBUUID
        newUUID = CBUUID.init(string: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")
        service = CBMutableService.init(type: newUUID, primary: true)
        service.characteristics = nil
        //add http request object
    }
    
    deinit {
        //delete http request object
    }
    
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
            //try self.sessionObject.send(archivedMessageArray, toPeers: ids, with: MCSessionSendDataMode.reliable)
            
            let archivedRatingArray: Data = NSKeyedArchiver.archivedData(withRootObject: ratingSentArray)
            //try self.sessionObject.send(archivedRatingArray, toPeers: ids, with: MCSessionSendDataMode.reliable)
            //} catch let error as NSError {
            //  NSLog("%@", error)
            //}
        }
    }
    
    /**
     Sends all replies to the passed-in peers.
     
     - Parameters:
     - ids: An array of `MCPeerID` objects that represent peers to send replies to.
     */
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
            //try self.sessionObject.send(archivedReplyArray, toPeers: ids, with: MCSessionSendDataMode.reliable)
            
            let archivedRatingArray: Data = NSKeyedArchiver.archivedData(withRootObject: ratingSentArray)
            //try self.sessionObject.send(archivedRatingArray, toPeers: ids, with: MCSessionSendDataMode.reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    
    /**
     Sends an individual message to all connected peers.
     It is meant to be used when the user is connected to nearby peers
     and they compose a new message.
     
     - Parameters:
     - message: The message to send to the connected peers.
     */
    func send(individualMessage message: AnonymouseMessageSentCore) {
        //guard sessionObject.connectedPeers.count > 0 else {
        //return
        //}
        
        do {
            let archivedMessage: Data = NSKeyedArchiver.archivedData(withRootObject: message)
            //try self.sessionObject.send(archivedMessage, toPeers: sessionObject.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
    
    /**
     Sends an individual reply to all connected peers.
     
     - Parameters:
     - reply: The reply to send to the connected peers.
     */
    func send(individualReply reply: AnonymouseReplySentCore) {
        //guard sessionObject.connectedPeers.count > 0 else {
        //return
        //}
        
        do {
            let archivedMessage: Data = NSKeyedArchiver.archivedData(withRootObject: reply)
            //try self.sessionObject.send(archivedMessage, toPeers: sessionObject.connectedPeers, with: MCSessionSendDataMode.reliable)
            //} catch let error as NSError {
            //NSLog("%@", error)
            //}
        }
    }
        
        /**
         Sends an individual rating object to all connected peers.
         
         - Parameters:
         - rating: The rating to send to all connected peers.
         */
        func send(individualRating rating: AnonymouseRatingSentCore) {
            
            //guard sessionObject.connectedPeers.count > 0 else {
            //return
            //}
            
            do {
                let archivedRating: Data = NSKeyedArchiver.archivedData(withRootObject: rating)
                //try self.sessionObject.send(archivedRating, toPeers: sessionObject.connectedPeers, with: MCSessionSendDataMode.reliable)
                //} catch let error as NSError {
                //NSLog("%@", error)
                //}
            }
        }
        
        /*    //MARK: MCNearbyServiceBrowserDelegate Methods
         func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
         NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
         }
         
         func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
         NSLog("%@", "foundPeer: \(peerID)")
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
         func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
         NSLog("%@", "didFinishReceivingResourceWithName \(resourceName)")
         }
         
         func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
         NSLog("%@", "didReceiveCertificate from peer \(peerID)")
         //Check the certificate of a peer.
         //This needs to be changed to validate the certificate the peer sends.
         certificateHandler(true)
         } */
        
        
        func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
            NSLog("%@", "didReceiveData: \(data.count) bytes from peer \(peerID)")
            //There are only two types of data that this app sends: a single message, or a group of messages
            
            //Check if the data sent was a single message
            if let message = NSKeyedUnarchiver.unarchiveObject(with: data) as? AnonymouseMessageSentCore {
                let messageHash: String = message.text.sha1()
                let messageHashes: [String] = dataController.fetchMessageHashes()
                //Add the message if we don't have it already
                if !messageHashes.contains(messageHash) {
                    self.dataController.addMessage(message.text!, date: message.date!, user: message.user!, fromServer: true)
                }
            }
                //Check if the data sent was an array of messages
            else if let messageArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnonymouseMessageSentCore] {
                let messageHashes: [String] = dataController.fetchMessageHashes()
                for message in messageArray {
                    let messageHash: String = message.text.sha1()
                    if !messageHashes.contains(messageHash) {
                        self.dataController.addMessage(message.text!, date: message.date!, user: message.user!, fromServer: true)
                    }
                }
            }
                //Check if the data sent was a single reply
            else if let reply = NSKeyedUnarchiver.unarchiveObject(with: data) as? AnonymouseReplySentCore {
                let replyHashes: [String] = dataController.fetchReplyHashes()
                let replyHash: String = reply.text.sha1()
                if !replyHashes.contains(replyHash) {
                    let messageObjects: [AnonymouseMessageCore] = dataController.fetchObjects(withKey: "date", ascending: true)
                    for message in messageObjects {
                        if message.text!.sha1() == reply.parentHash {
                            dataController.addReply(withText: reply.text!, date: reply.date!, user: reply.user!, toMessage: message, fromServer: true)
                            break
                        }
                    }
                }
            }
                //Check if the data sent was an array of replies
            else if let replyArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnonymouseReplySentCore] {
                let replyHashes: [String] = dataController.fetchReplyHashes()
                let messageObjects: [AnonymouseMessageCore] = dataController.fetchObjects(withKey: "date", ascending: true)
                for reply in replyArray {
                    let replyHash: String = reply.text.sha1()
                    if !replyHashes.contains(replyHash) {
                        for message in messageObjects {
                            if message.text!.sha1() == reply.parentHash {
                                dataController.addReply(withText: reply.text!, date: reply.date!, user: reply.user!, toMessage: message, fromServer: true)
                                break
                            }
                        }
                    }
                }
            }
                //Check if the data sent was a single reply
            else if let rating = NSKeyedUnarchiver.unarchiveObject(with: data) as? AnonymouseRatingSentCore {
                let messageCoreArray: [AnonymouseMessageCore] = dataController.fetchObjects(withKey: "date", ascending: true)
                for message in messageCoreArray {
                    if message.text!.sha1() == rating.messageHash {
                        let previousRating: Int = Int(truncating: message.rating!)
                        message.rating = NSNumber(integerLiteral: rating.rating! + previousRating)
                        return
                    }
                }
                let replyCoreArray: [AnonymouseReplyCore] = dataController.fetchReplies(withKey: "date", ascending: true)
                for reply in replyCoreArray {
                    if reply.text!.sha1() == rating.messageHash {
                        let previousRating: Int = Int(truncating: reply.rating!)
                        reply.rating = NSNumber(integerLiteral: rating.rating! + previousRating)
                        return
                    }
                }
            }
                //Check if the data sent was an array of replies
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
                        let previousRating: Int = Int(truncating: message.rating!)
                        message.rating = NSNumber(integerLiteral: rating.rating! + previousRating)
                    }
                    if let reply = replyCoreDictionary[rating.messageHash] {
                        let previousRating: Int = Int(truncating: reply.rating!)
                        reply.rating = NSNumber(integerLiteral: rating.rating! + previousRating)
                    }
                }
            }
        }
        
        //The dictionaries below are used to convert the
        //string representation of private/public keys back into
        //key objects, which are used to sign/verify data.
        let attributes: [NSObject: NSObject] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits: NSNumber(value: 2048),
            kSecReturnPersistentRef: false as NSObject
        ]
        let keyDict:[NSObject:NSObject] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: 2048),
            kSecReturnPersistentRef: false as NSObject
        ]
        
        //infrastructure mode
        
        //This function is called when sending a message via infrastructure mode.
        func sendMessageViaHTTP(text: String, date: Date, rating: Int, user: String){
            var error: Unmanaged<CFError>?
            let userPreferences: UserDefaults = UserDefaults.standard
            
            //The two guard statements below convert the private key string into a private key object
            //This key is then used to sign a hash of the message's text, the sender, and date sent.
            guard let privKeyData = Data.init(base64Encoded: userPreferences.string(forKey: "PrivKey")!) else {
                print("Private key couldn't be converted to data")
                return
            }
            guard let privKey = SecKeyCreateWithData(privKeyData as CFData, attributes as CFDictionary, &error) else {
                print("Reversion priv unsuccessful")
                return
            }
            
            //The information in the hash is concatenated and converted to data below. The SecKeyCreateSignature function
            //hashes the data below before signing it.
            let hash = (text + date.description + user)
            let hashData = Data(hash.utf8)
            
            //signedString will contain a base 64 encoded string representation of the signed hash.
            //This will be sent to the server, as sending raw data causes problems.
            var signedString = " "
            
            //Signatures with hashes are only allowed after iOS 11. If the phone in question is running an older version,
            //then we have to do a raw signature instead.
            if #available(iOS 11.0, *) {
                //Sign the hash data with the recreated private key (signature data type: CFData)
                let signedHash = SecKeyCreateSignature(privKey, SecKeyAlgorithm.rsaSignatureMessagePSSSHA1, hashData as CFData, &error)
                //Convert the CFData signature to datatype Data
                guard let signedData = signedHash as Data? else {
                    print("CFData to Data")
                    return
                }
                //Convert the Data signature to string format. This will be sent to the server
                //and converted back to CFData by the receiver
                signedString = signedData.base64EncodedString()
                
                //The code in the else statement is the same as the code before it, other than the SecKeyAlgorithm used to sign the data
            } else {
                let signedHash = SecKeyCreateSignature(privKey, SecKeyAlgorithm.rsaSignatureRaw, hashData as CFData, &error)
                guard let signedData = signedHash as Data? else {
                    print("CFData to Data")
                    return
                }
                signedString = signedData.base64EncodedString()
                /*let reDataSigned = Data.init(base64Encoded: signedString)
                 let toBeVerified = reDataSigned! as NSData
                 let verifiedHash = SecKeyVerifySignature(pubKey, SecKeyAlgorithm.rsaSignatureRaw, hashData as CFData, toBeVerified, &error)
                 if !verifiedHash{
                 return
                 } */
            }
            
            //self.sendKeyViaHTTP(pubKey: pubKey!) //Sends public key to server
            
            //Define the object sent to the server below
            let parameters: Parameters = [
                "MessageType": "Message",
                "Message": text,
                "Date": date.description,
                "Rating": rating,
                "User": user,
                "Signature": signedString,
                "Key": userPreferences.string(forKey: "PubKey")!
            ]
            print("Parameters created");
            
            //Send the newly created object to the server.
            //If you are changing which server the phone sends to/receives from, change the url in the statement
            Alamofire.request("http://anonymouse-srv.eecs.umich.edu:3000/message", method: .post, parameters: parameters, encoding: JSONEncoding(options: []))
        }
        
        func sendReplyViaHTTP(text: String, date: Date, rating: Int, user: String, message: AnonymouseMessageCore){
            
            let parameters: Parameters = [
                "MessageType": "Reply",
                "Message": text,
                "Date": date.description,
                "Rating": rating,
                "User": user,
                "Parent": message.text!.sha1()
            ]
            
            Alamofire.request("http://anonymouse-srv.eecs.umich.edu:3000/message", method: .post, parameters: parameters, encoding: JSONEncoding(options: []))
        }
        
        func sendRatingViaHTTP(rating: Int, hash: String, date: Date, randNum: Double, message: AnonymouseMessageCore){
            let dateDesc = date.description
            let parameters: Parameters = [
                "MessageType": "Rating",
                "Message Date": message.date?.description,
                "Rating": rating,
                "Parent": hash,
                "Date": dateDesc,
                "RandNum": randNum
            ]
            let newRate = AnonymouseRatingCore(rating: rating, parent: hash, date: date, randNum: randNum)
            self.dataController.addRating(rating: rating, parent: hash, date: date, randNum: randNum)
            // Both calls are equivalent
            Alamofire.request("http://anonymouse-srv.eecs.umich.edu:3000/message", method: .post, parameters: parameters, encoding: JSONEncoding(options: []))
            
        }
        
        func sendRatingViaHTTP(rating: Int, hash: String, date: Date, randNum: Double, reply: AnonymouseReplyCore){
            let dateDesc = date.description
            let parameters: Parameters = [
                "MessageType": "Rating",
                "Message Date": reply.date?.description,
                "Rating": rating,
                "Parent": hash,
                "Date": dateDesc,
                "RandNum": randNum
            ]
            let newRate = AnonymouseRatingCore(rating: rating, parent: hash, date: date, randNum: randNum)
            self.dataController.addRating(rating: rating, parent: hash, date: date, randNum: randNum)
            // Both calls are equivalent
            Alamofire.request("http://anonymouse-srv.eecs.umich.edu:3000/message", method: .post, parameters: parameters, encoding: JSONEncoding(options: []))
            
        }
        
        func sendKeyViaHTTP(pubKey: Data){
            let parameters: Parameters = [
                "Key": pubKey.hexadecimalString()
            ]
            // Both calls are equivalent
            Alamofire.request("http://anonymouse-srv.eecs.umich.edu:3000/pubKeys", method: .post, parameters: parameters, encoding: JSONEncoding(options: []))
            
        }
        
        func getMessageViaHTTP(){
            let userPreferences: UserDefaults = UserDefaults.standard
            let myUrl = URL(string: "http://anonymouse-srv.eecs.umich.edu:3000/message");
            var request = URLRequest(url:myUrl!)
            request.httpMethod = "GET"// Compose a query string
            let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil{
                    print("error=\(String(describing: error))")
                    return
                }
                
                // You can print out response object
                //print("response = \(String(describing: response))")
                
                //Let's convert response sent from a server side script to a NSDictionary object:
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [NSDictionary]
                    if json != nil {
                        for object in json!{
                            // Now we can access value of First Name by its key
                            let messageType = object["MessageType"] as? String?
                            
                            if(messageType!! == "Message"){
                                var notFound: Bool = true
                                var error: Unmanaged<CFError>?
                                var verifiedHash = false
                                
                                let date = object["Date"] as? String?
                                print("Got date text")
                                print(date!!)
                                let pulledText = object["Message"] as? String?
                                print("Got message text")
                                let user = object["User"] as? String?
                                print("Got user text")
                                let signedString = object["Signature"] as? String?
                                
                                let key = object["Key"] as? String?
                                
                                guard let keyData = Data.init(base64Encoded: key!!) else {
                                    print("Public key couldn't be converted to data")
                                    return
                                }
                                guard let pubKey = SecKeyCreateWithData(keyData as CFData, self.keyDict as CFDictionary, &error) else {
                                    print("Reversion pub unsuccessful")
                                    return
                                }
                                
                                let hash = (pulledText!! + date!! + user!!)
                                let hashData = Data(hash.utf8)
                                let reDataSigned = Data.init(base64Encoded: signedString!!)
                                let toBeVerified = reDataSigned! as NSData
                                
                                if #available(iOS 11.0, *) {
                                    verifiedHash = SecKeyVerifySignature(pubKey, SecKeyAlgorithm.rsaSignatureMessagePSSSHA1, hashData as CFData, toBeVerified, &error)
                                } else {
                                    verifiedHash = SecKeyVerifySignature(pubKey, SecKeyAlgorithm.rsaSignatureRaw, hashData as CFData, toBeVerified, &error)
                                }
                                if !verifiedHash{
                                    print("Message could not be verified")
                                    return
                                }
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                                guard let properDate = dateFormatter.date(from: date!!) else{
                                    fatalError("ERROR: Date conversion failed due to mismatched format.")
                                }
                                if let lastReset = UserDefaults.standard.object(forKey: "timeReset") as! Date? {
                                    if lastReset > properDate {
                                        notFound = false
                                    }
                                }
                                let messageObjects: [AnonymouseMessageCore] = self.dataController.fetchObjects(withKey: "date", ascending: true)
                                if(notFound){
                                    for message in messageObjects{
                                        let messageHash = (message.text!+message.user! + (message.date?.description)!).sha1()
                                        let newHash = (pulledText!!+user!!+properDate.description).sha1()
                                        if(messageHash == newHash){
                                            print("Found a match")
                                            notFound = false
                                            break
                                        }
                                    }
                                }
                                if(notFound){
                                    self.dataController.addMessage(pulledText!!, date: properDate, user: user!! as String, fromServer: true)
                                    print("Added Message")
                                }
                            }
                            else if messageType!! == "Reply"{
                                var notFound: Bool = true
                                let date = object["Date"] as? String?
                                print("Got date text")
                                print(date!!)
                                let text = object["Message"] as? String?
                                print("Got message text")
                                let user = object["User"] as? String?
                                print("Got user text")
                                
                                
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                                guard let properDate = dateFormatter.date(from: date!!) else{
                                    fatalError("ERROR: Date conversion failed due to mismatched format.")
                                }
                                
                                if let lastReset = UserDefaults.standard.object(forKey: "timeReset") as! Date? {
                                    if lastReset > properDate {
                                        notFound = false
                                    }
                                }
                                
                                let replyCoreArray: [AnonymouseReplyCore] = self.dataController.fetchReplies(withKey: "date", ascending: true)
                                for reply in replyCoreArray {
                                    if reply.text?.sha1() == text!!.sha1() && properDate.description == reply.date!.description {
                                        notFound = false
                                        break
                                    }
                                }
                                if(notFound){
                                    let parent = (object["Parent"] as? String?)!!
                                    let messageObjects: [AnonymouseMessageCore] = self.dataController.fetchObjects(withKey: "date", ascending: true)
                                    for message in messageObjects{
                                        if(message.text?.sha1() == parent){
                                            print("Found a match")
                                            self.dataController.addReply(withText: text!!, date: properDate, user: user!!, toMessage: message, fromServer: true)
                                            break
                                        }
                                    }
                                    print("Added Reply")
                                }
                            }
                            else if messageType!! == "Rating"{
                                var notFound: Bool = true;
                                let ratingNum = object["Rating"] as? Int?
                                let parent = object["Parent"] as? String?
                                let dateDesc = object["Date"] as? String?
                                let randNum = object["RandNum"] as? Double?
                                let parentDate = object["Message Date"] as? String?
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                                guard let properDate = dateFormatter.date(from: dateDesc!!) else{
                                    fatalError("ERROR: Date conversion failed due to mismatched format.")
                                }
                                
                                if let lastReset = UserDefaults.standard.object(forKey: "timeReset") as! Date! {
                                    if lastReset > properDate {
                                        notFound = false
                                    }
                                }
                                
                                let ratingCoreArray: [AnonymouseRatingCore] = self.dataController.fetchRatings(withKey: "date", ascending: true)
                                for rating in ratingCoreArray{
                                    if(parent!! == rating.parent! && ratingNum!! == Int(truncating: rating.rating!) && randNum!! == Double(truncating: rating.randNum!)){
                                        notFound = false;
                                    }
                                }
                                if(notFound){
                                    let messageCoreArray: [AnonymouseMessageCore] = self.dataController.fetchObjects(withKey: "date", ascending: true)
                                    for message in messageCoreArray {
                                        print((properDate + 2).description)
                                        if (message.text!.sha1() == parent!! && parentDate!! == message.date?.description) { //Add date parameter
                                            let previousRating: Int = Int(truncating: message.rating!)
                                            message.rating = NSNumber(integerLiteral: ratingNum!! + previousRating)
                                            break
                                        }
                                    }
                                    let replyCoreArray: [AnonymouseReplyCore] = self.dataController.fetchReplies(withKey: "date", ascending: true)
                                    for reply in replyCoreArray {
                                        if (reply.text!.sha1() == parent!! && parentDate!! == reply.date?.description) {
                                            let previousRating: Int = Int(truncating: reply.rating!)
                                            reply.rating = NSNumber(integerLiteral: ratingNum!! + previousRating)
                                            break
                                        }
                                    }
                                    let rate = AnonymouseRatingCore(rating: ratingNum!!, parent: parent!!, date: properDate, randNum: randNum!!)
                                    self.dataController.addRating(rating: ratingNum!!, parent: parent!!, date: properDate as Date, randNum: randNum!!)
                                }
                            }
                            
                        }
                    }
                    else {
                        print("We couldn't do that")
                    }
                } catch {
                    print("ERROR: ")
                    print(error)
                }
            }
            task.resume()
        }
        
        func sendViaBeacon(){
            if(peripheralManager.state == .poweredOn){
                peripheralManager.add(service)
                let peripheralData : NSDictionary
                var region : CLBeaconRegion
                
                region = CLBeaconRegion.init(proximityUUID: UUID.init(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!, major: 0, minor: 0, identifier: "FellowAppUser")
                peripheralData = (region.peripheralData(withMeasuredPower: nil))
                
                // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
                print(peripheralData.allValues);
                peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service.uuid]])
            }
        }
        
}






