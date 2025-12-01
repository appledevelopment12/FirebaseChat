//
//  MessageModel.swift
//  FirebaseChat
//
//  Created by Rohit on 29/11/25.
//

import Foundation
import FirebaseCore

import Foundation

struct Message {
    let senderId: String
    let receiverId: String
    let message: String
    let imageUrl: String
    let timestamp: Date
    
    let replySenderName: String   // name in reply preview
    let replyText: String         // reply attachment
    let replyImageUrl: String
    
}
