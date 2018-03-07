//
//  AnonymouseConnectivityController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData
import Foundation
///A class that mnanages the connectivity protocols; sending messages and rating objects to nearby peers.
class AnonymouseConnectivityController : NSObject, NetServiceDelegate, NetServiceBrowserDelegate,StreamDelegate {

    //MARK: Links
    ///A weak reference to the `dataController`, which allows this class to store received messages.
    weak var dataController: AnonymouseDataController!

    ///A 15-character or less string that describes the function that the app is broadcasting.
    let myServiceType: String = "Anonymouse"

    //An object that handles netservice provided by current device
    var netService: NetService!

    //A list contains all opening outputsStream
    var outputs: [OutputStream] = []
    
    ///An object that handles searching for and finding other phones on the network.
    var netServiceBrowser: NetServiceBrowser!

    ///`true` if this object is currently browsing.
    var isBrowsing: Bool = false
    ///`true` if this object is currently advertising.
    var isAdvertising: Bool = false

    var timer: Timer!
    //MARK: Convenience methods
    ///Begins advertising the current peer on the network.
    func startAdvertisingPeer() {
        netService.publish(options: [.listenForConnections])
        netService.startMonitoring()
        isAdvertising = true
    }

    ///Stops advertising the current peer.
    func stopAdvertisingPeer() {
        netService.stop()
        netService.stopMonitoring()
        isAdvertising = false
    }

    ///Begins browsing for other peers on the network.
    func startBrowsingForPeers() {
        netServiceBrowser.searchForServices(ofType: "_Anonymouse._tcp", inDomain: "local.")
        isBrowsing = true
    }

    ///Stops browsing for other peers.
    func stopBrowsingForPeers() {
        netServiceBrowser.stop()
        isBrowsing = false
    }

    ///Kills the connection with currently connected peers and takes this object's presence off the network. =
    func killConnectionParameters() {
        stopBrowsingForPeers()
        stopAdvertisingPeer()
    }

    override init() {
        unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController

        //FIXME: Construct a netservice instance as domain local, type: unknown (temporary solution:http,tcp) and service name
        netService = NetService(domain: "local.", type: "_Anonymouse._tcp.", name: myServiceType)
        netServiceBrowser = NetServiceBrowser()
        netService.includesPeerToPeer = true
        netServiceBrowser.includesPeerToPeer = true
        super.init()
        netService.delegate = self
        netServiceBrowser.delegate = self
        // let date: Date = Date(timeIntervalSince1970 : Date().timeIntervalSinceReferenceDate+(5-Date().timeIntervalSinceReferenceDate%5) )
        // timer = Timer(fire:date, interval:5, repeats: true, block)
        startAdvertisingPeer()
        startBrowsingForPeers()
    }

    deinit {
        self.stopAdvertisingPeer()
        self.stopBrowsingForPeers()
    }


    //MARK: Data transfer methods

    /**
     Sends all owned messages to the passed-in peers.
     It maps the stored messages, which are saved as CoreArray objects,
     to SentArray objects, which conform to `NSCoding` protocol.
     It is meant to be used when a peer first connects with another peer.

     - Parameters:
        - ids: An array of `MCPeerID` objects that represent peers to send mesages to.
     */
    func sendAllMessages(toStream outStream: OutputStream) {
        NSLog("Sending Messages")
        let messageCoreArray: [AnonymouseMessageCore] = dataController.fetchObjects(withKey: "date", ascending: true)
        let messageSentArray: [AnonymouseMessageSentCore] = messageCoreArray.map { (messageCore) -> AnonymouseMessageSentCore in
            return AnonymouseMessageSentCore(message: messageCore)
        }
        let ratingSentArray: [AnonymouseRatingSentCore] = messageCoreArray.map { (messageCore) -> AnonymouseRatingSentCore in
            return AnonymouseRatingSentCore(message: messageCore)
        }


        //Encode the messages for sending
        let archivedMessageArray: NSData = NSData(data: NSKeyedArchiver.archivedData(withRootObject: messageSentArray))
        let archivedMessageArrayPtr = archivedMessageArray.bytes.bindMemory(to: UInt8.self , capacity: archivedMessageArray.length)
        let num1 = outStream.write(archivedMessageArrayPtr ,maxLength: archivedMessageArray.length)
        NSLog("write1: \(num1)")

        let archivedRatingArray: NSData = NSData(data: NSKeyedArchiver.archivedData(withRootObject: ratingSentArray))
        let archivedRatingArrayPtr = archivedRatingArray.bytes.bindMemory(to: UInt8.self, capacity: archivedRatingArray.length)
        let num2 = outStream.write(archivedRatingArrayPtr ,maxLength: archivedRatingArray.length)
        NSLog("write2: \(num2)")
    }

    /**
     Sends all replies to the passed-in peers.

     - Parameters:
        - ids: An array of `MCPeerID` objects that represent peers to send replies to.
     */
    func sendAllReplies(toStream outStream: OutputStream) {
        NSLog("Sending Replies")
        let replyCoreArray: [AnonymouseReplyCore] = dataController.fetchReplies(withKey: "date", ascending: true)
        let replySentArray: [AnonymouseReplySentCore] = replyCoreArray.map { (replyCore) -> AnonymouseReplySentCore in
            return AnonymouseReplySentCore(reply: replyCore)
        }
        let ratingSentArray: [AnonymouseRatingSentCore] = replyCoreArray.map { (replyCore) -> AnonymouseRatingSentCore in
            return AnonymouseRatingSentCore(reply: replyCore)
        }


        let archivedReplyArray: NSData = NSData(data: NSKeyedArchiver.archivedData(withRootObject: replySentArray))
         let archivedReplyArrayPtr = archivedReplyArray.bytes.bindMemory(to: UInt8.self , capacity: archivedReplyArray.length)
        outStream.write(archivedReplyArrayPtr ,maxLength: archivedReplyArray.length)

        let archivedRatingArray: NSData = NSData(data: NSKeyedArchiver.archivedData(withRootObject: ratingSentArray))
        let archivedRatingArrayPtr = archivedRatingArray.bytes.bindMemory(to: UInt8.self, capacity: archivedRatingArray.length)
        outStream.write(archivedRatingArrayPtr ,maxLength: archivedRatingArray.length)

    }

    //NetSericeDelegate Functions

    /**Notifies the delegate that the network is ready to publish the service.*/
    func netServiceWillPublish(_: NetService) {
      NSLog("netServiceWillPublish")
    }

    /**Notifies the delegate that a service could not be published.*/
    func netService(_: NetService, didNotPublish: [String : NSNumber]){
      NSLog("the delegate that a service could not be published")
    }

    /**Notifies the delegate that a service was successfully published.*/
    func netServiceDidPublish(_: NetService){
      NSLog("a service was successfully published")
    }

    /**Notifies the delegate that the network is ready to resolve the service.*/
    func netServiceWillResolve(_: NetService){
        NSLog("the network is ready to resolve the service")
    }

    /**Informs the delegate that an error occurred during resolution of a given service.*/
    func netService(_: NetService, didNotResolve: [String : NSNumber]){
        NSLog("an error occurred during resolution of a given service")
    }

    /**Informs the delegate that the address for a given service was resolved.*/
    func netServiceDidResolveAddress(_: NetService){
        NSLog("the address for a given service was resolved.")
    }

    /** Notifies the delegate that the TXT record for a given service has been updated.*/
    func netService(_: NetService, didUpdateTXTRecord: Data){
        NSLog(" the TXT record for a given service has been updated.")
    }

  /**Informs the delegate that a publish() or resolve(withTimeout:) request was stopped.*/
    func netServiceDidStop(_: NetService){
      NSLog("a publish() or resolve(withTimeout:) request was stopped")
  }
  func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream,   outputStream: OutputStream){
    NSLog("Service accept connection")
    inputStream.delegate = self
    outputStream.delegate = self
    inputStream.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    outputStream.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    inputStream.open()
    outputStream.open()
    handleDataTransfer(from: inputStream, to: outputStream)
 }
  // netService Browser delegate
  /**Tells the delegate the sender found a domain.*/
    func netServiceBrowser(_: NetServiceBrowser, didFindDomain: String, moreComing: Bool){
    NSLog(" the sender found a domain")
  }


  /**Tells the delegate the a domain has disappeared or has become unavailable.*/
    func netServiceBrowser(_: NetServiceBrowser, didRemoveDomain: String, moreComing: Bool){
    NSLog("a domain has disappeared or has become unavailable")
  }


  /**Tells the delegate the sender found a service.*/
    func netServiceBrowser(_: NetServiceBrowser, didFind: NetService, moreComing: Bool){
        NSLog("Found and Connected to service")
        var input : InputStream?
        var output : OutputStream?
    didFind.getInputStream(&input, outputStream:&output)
        input!.delegate = self
        output!.delegate = self
        input!.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        output!.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        input!.open()
        output!.open()
     handleDataTransfer(from: (input)!, to:(output)!)
  }


  /**Tells the delegate a service has disappeared or has become unavailable.*/
    func netServiceBrowser(_: NetServiceBrowser, didRemove: NetService, moreComing: Bool){
    NSLog(" a service has disappeared or has become unavailable")
  }

  /**Tells the delegate that a search is commencing.*/
    func netServiceBrowserWillSearch(_: NetServiceBrowser){
    NSLog("a search is commencing")
  }

  /**Tells the delegate that a search was not successful.*/
    func netServiceBrowser(_: NetServiceBrowser, didNotSearch: [String : NSNumber]){
    NSLog("a search was not successful")
  }


  /**Tells the delegate that a search was stopped.*/
    func netServiceBrowserDidStopSearch(_: NetServiceBrowser){
    NSLog(" a search was stopped")
  }

  func handleDataTransfer(from inputStream: InputStream, to outputStream:  OutputStream){
    NSLog("Transfer Data")
    sendAllMessages(toStream: outputStream)
    sendAllReplies(toStream: outputStream)
    let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024*400)
    let num1 = inputStream.read(uint8Pointer, maxLength: 1024*400)
    NSLog("read: \(num1)")
    let uint8RawPointer = UnsafeRawPointer(uint8Pointer)
    let data: Data = Data(bytes: uint8RawPointer, count: 1024*400)

    var string: String = String()
    for i in 0..<1024 {
        string.append(Character(UnicodeScalar(uint8Pointer[i])))
    }
    NSLog(string)
    NSLog("Logging Data")
    if let messageArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnonymouseMessageSentCore] {
        NSLog("Message Received")
         let messageHashes: [String] = dataController.fetchMessageHashes()
         for message in messageArray {
             let messageHash: String = message.text.sha1()
             if !messageHashes.contains(messageHash) {
                self.dataController.addMessage(message.text!, date: message.date!, user: message.user!)
             }
         }
     }
     else if let replyArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnonymouseReplySentCore] {
        NSLog("Reply Received")
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
     else if let ratingArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnonymouseRatingSentCore] {
        NSLog("Rating Received")
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
    /**
     Sends an individual message to all connected peers.
     It is meant to be used when the user is connected to nearby peers
     and they compose a new message.
     
     - Parameters:
     - message: The message to send to the connected peers.
     */
    func send(individualMessage message: AnonymouseMessageSentCore) {
        NSLog("Sending Messages")
        for output in self.outputs{
            self.sendAllMessages(toStream: output)
        }
    }
    
    func stream(_ aStream: Stream,
                handle eventCode: Stream.Event){
        
      //  case Stream.Event.hasBytesAvailable:
        
        NSLog("HasBytesAvailable")
        
        var buffer = [UInt8](repeating:0, count:4096)
        
        let inputStream = aStream as? InputStream
        if inputStream == nil {
            return
        }
        while ((inputStream?.hasBytesAvailable) != false){
            let len = inputStream?.read(&buffer, maxLength: buffer.count)
            if(len! > 0){
                let output = NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.utf8.rawValue)
                if (output != ""){
                    NSLog("Server Received : %@", output!)
                }
            }else{
                break
            }
        }
     //   break
      //  default:
     //   NSLog("unknown.")
    }

    /**
     Sends an individual reply to all connected peers.
     
     - Parameters:
     - reply: The reply to send to the connected peers.
     */
    func send(individualReply reply: AnonymouseReplySentCore) {
        NSLog("Sending Replies")
        for output in self.outputs{
            self.sendAllReplies(toStream: output)
        }
    }
    
    /**
     Sends an individual rating object to all connected peers.
     
     - Parameters:
     - rating: The rating to send to all connected peers.
     */
    func send(individualRating rating: AnonymouseRatingSentCore) {
        NSLog("Sending Ratings")
        for output in self.outputs{
            self.sendAllMessages(toStream: output)
            self.sendAllReplies(toStream: output)
        }
    }
    
}
