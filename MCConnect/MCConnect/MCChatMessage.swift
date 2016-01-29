//
//  ChatMessage.swift
//  MCConnect
//
//  Created by Pascal Sturmfels on 1/25/16.
//  Copyright © 2016 Pascal Sturmfels. All rights reserved.
//

import UIKit

//An enum for the two different type of messages
enum MCChatMessageType
{
    case sentMessage
    case receivedMessage
}

//The message contained within MCChatMessageData
class MCChatMessage {
    let date: NSDate
    let text: String
    let type: MCChatMessageType
    
    init(text: String, date: NSDate, type: MCChatMessageType)
    {
        self.text = text
        self.date = date
        self.type = type
        
    }
}
