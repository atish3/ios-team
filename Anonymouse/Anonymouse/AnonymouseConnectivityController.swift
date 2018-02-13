//
//  AnonymouseConnectivityController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData
import NetService
import NetServiceBrowser

///A class that mnanages the connectivity protocols; sending messages and rating objects to nearby peers.
class AnonymouseConnectivityController : NSObject, NetServiceDelegate, NetServiceBrowserDelegate {

    //MARK: Links
    ///A weak reference to the `dataController`, which allows this class to store received messages.
    weak var dataController: AnonymouseDataController!

    ///A 15-character or less string that describes the function that the app is broadcasting.
    let myServiceType: String = "Anonymouse"

    //An object that handles netservice provided by current device
    var netService: NetService!

    ///An object that handles searching for and finding other phones on the network.
    var netServiceBrowser: NetServiceBrowser!

    ///`true` if this object is currently browsing.
    var isBrowsing: Bool = false
    ///`true` if this object is currently advertising.
    var isAdvertising: Bool = false

    //MARK: Convenience methods
    ///Begins advertising the current peer on the network.
    func startAdvertisingPeer() {
        netService.startMonitoring()
        netService.publish(options: [NetService.Options.listenForConnections])
        isAdvertising = true
    }

    ///Stops advertising the current peer.
    func stopAdvertisingPeer() {
        netServiceBrowser.stopMonitoring()
        netServiceBrowser.stop()
        isAdvertising = false
    }

    ///Begins browsing for other peers on the network.
    func startBrowsingForPeers() {
        serviceBrowser.startBrowsingForPeers()
        isBrowsing = true
    }

    ///Stops browsing for other peers.
    func stopBrowsingForPeers() {
        serviceBrowser.stopBrowsingForPeers()
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
        netService = NetService(domain: @"local.", type: "_http._tcp.", name: myServiceType)
        netServiceBrowser = NetServiceBrowser()
        netService.includesPeerToPeer = true
        netServiceBrowser.includesPeerToPeer = true
        super.init()
        netService.delegate = self
        netServiceBrowser.delegate = self

        startAdvertisingPeer()
        startBrowsingForPeers()
    }

    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
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
        let messageCoreArray: [AnonymouseMessageCore] = dataController.fetchObjects(withKey: "date", ascending: true)
        let messageSentArray: [AnonymouseMessageSentCore] = messageCoreArray.map { (messageCore) -> AnonymouseMessageSentCore in
            return AnonymouseMessageSentCore(message: messageCore)
        }
        let ratingSentArray: [AnonymouseRatingSentCore] = messageCoreArray.map { (messageCore) -> AnonymouseRatingSentCore in
            return AnonymouseRatingSentCore(message: messageCore)
        }

        do {
            //Encode the messages for sending
            let archivedMessageArray: NSData = NSData(data: NSKeyedArchiver.archivedData(withRootObject: messageSentArray))
            outStream.write(archivedMessageArray.bytes ,archiviedMessageArray.length)

            let archivedRatingArray: NSData = NSData(data: NSKeyedArchiver.archivedData(withRootObject: ratingSentArray))
            outStream.write(archivedRatingArray.bytes ,archiviedRatingArray.length)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }

    /**
     Sends all replies to the passed-in peers.

     - Parameters:
        - ids: An array of `MCPeerID` objects that represent peers to send replies to.
     */
    func sendAllReplies(toStream outStream: OutputStream) {
        let replyCoreArray: [AnonymouseReplyCore] = dataController.fetchReplies(withKey: "date", ascending: true)
        let replySentArray: [AnonymouseReplySentCore] = replyCoreArray.map { (replyCore) -> AnonymouseReplySentCore in
            return AnonymouseReplySentCore(reply: replyCore)
        }
        let ratingSentArray: [AnonymouseRatingSentCore] = replyCoreArray.map { (replyCore) -> AnonymouseRatingSentCore in
            return AnonymouseRatingSentCore(reply: replyCore)
        }

        do {
            let archivedReplyArray: NSData = NSData(data: NSKeyedArchiver.archivedData(withRootObject: replySentArray))
            outStream.write(archivedReplyArray.bytes ,archiviedReplyArray.length)

            let archivedRatingArray: NSData = NSData(data: NSKeyedArchiver.archivedData(withRootObject: ratingSentArray))
            outStream.write(archivedRatingArray.bytes ,archivedRatingArray.length)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }

    //NetSericeDelegate Functions

    /**Notifies the delegate that the network is ready to publish the service.*/
    func netServiceWillPublish(NetService) {
      NSLog("netServiceWillPublish")
    }

    /**Notifies the delegate that a service could not be published.*/
    func netService(NetService, didNotPublish: [String : NSNumber]){
      NSLog("the delegate that a service could not be published")
    }

    /**Notifies the delegate that a service was successfully published.*/
    func netServiceDidPublish(NetService){
      NSLog("a service was successfully published")
    }

    /**Notifies the delegate that the network is ready to resolve the service.*/
    func netServiceWillResolve(NetService){
        NSLog("the network is ready to resolve the service")
    }

    /**Informs the delegate that an error occurred during resolution of a given service.*/
    func netService(NetService, didNotResolve: [String : NSNumber]){
        NSLog("an error occurred during resolution of a given service")
    }

    /**Informs the delegate that the address for a given service was resolved.*/
    func netServiceDidResolveAddress(NetService){
        NSLog("the address for a given service was resolved.")
    }

    /** Notifies the delegate that the TXT record for a given service has been updated.*/
    func netService(NetService, didUpdateTXTRecord: Data){
        NSLog(" the TXT record for a given service has been updated.")
    }

  /**Informs the delegate that a publish() or resolve(withTimeout:) request was stopped.*/
  func netServiceDidStop(NetService){
      NSLog("a publish() or resolve(withTimeout:) request was stopped")
  }
  func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream,   outputStream: OutputStream){
    handleDataTransfer(from: inputStream, to: outputStream)
 }
  // netService Browser delegate
  /**Tells the delegate the sender found a domain.*/
  func netServiceBrowser(NetServiceBrowser, didFindDomain: String, moreComing: Bool){
    NSLog(" the sender found a domain")
  }


  /**Tells the delegate the a domain has disappeared or has become unavailable.*/
  func netServiceBrowser(NetServiceBrowser, didRemoveDomain: String, moreComing: Bool){
    NSLog("a domain has disappeared or has become unavailable")
  }


  /**Tells the delegate the sender found a service.*/
  func netServiceBrowser(NetServiceBrowser, didFind: NetService, moreComing: Bool){
     var input: InputStream = InputStream()
     var output: OutputStream = OutputStream()
     didFind.getInputStream(input, outputStream:output)
     handleDataTransfer(from:input, to:output)
  }


  /**Tells the delegate a service has disappeared or has become unavailable.*/
  func netServiceBrowser(NetServiceBrowser, didRemove: NetService, moreComing: Bool){
    NSLog(" a service has disappeared or has become unavailable")
  }

  /**Tells the delegate that a search is commencing.*/
  func netServiceBrowserWillSearch(NetServiceBrowser){
    NSLog("a search is commencing")
  }

  /**Tells the delegate that a search was not successful.*/
  func netServiceBrowser(NetServiceBrowser, didNotSearch: [String : NSNumber]){
    NSLog("a search was not successful")
  }


  /**Tells the delegate that a search was stopped.*/
  func netServiceBrowserDidStopSearch(NetServiceBrowser){
    NSLog(" a search was stopped")
  }

  func handleDataTransfer(from inputStream: InputStream, to outputStream: OutputStream){
    sendAllMessages(toStream: outputStream)
    sendAllReplies(toStream: outputStream)
    let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024*400)
    inputStream.read(uint8Pointer, 1024*400)

    let data: Data = Data(uint8Pointer, 1024*400)

    if let messageArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnonymouseMessageSentCore] {
         let messageHashes: [String] = dataController.fetchMessageHashes()
         for message in messageArray {
             let messageHash: String = message.text.sha1()
             if !messageHashes.contains(messageHash) {
                 self.dataController.addMessage(message.text!, date: message.date!, user: message.user!)
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

}
