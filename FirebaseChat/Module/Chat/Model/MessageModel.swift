//
//  MessageModel.swift
//  FirebaseChat
//
//  Created by Rohit on 29/11/25.
//
//
//  MessageModel.swift
//  FirebaseChat
//

import FirebaseFirestore

struct Message {

    // MARK: - MAIN FIELDS
    let id: String
    let chatRoomId: String
    let senderId: String
    let receiverId: String
    let type: MessageType

    // MARK: - MESSAGE CONTENT
    let text: String
    let imageUrl: String
    let videoUrl: String
    let audioUrl: String
    let documentUrl: String
    let fileName: String
    let fileSize: Int64

    // MARK: - REPLY SUPPORT
    var replyToMessageId: String?
    var replySenderName: String?
    var replyText: String?
    var replyImageUrl: String?
    var replyVideoUrl: String?


    // MARK: - STATUS
    let timestamp: Date
    var isRead: Bool       // aapke paas already hai
    var isDelivered: Bool

    var localPreviewImage: UIImage? = nil
    var isDownloaded: Bool = false


    // MARK: - DESIGNATED INITIALIZER
    init(id: String = UUID().uuidString,
         chatRoomId: String,
         senderId: String,
         receiverId: String,
         type: MessageType,
         text: String = "",
         imageUrl: String = "",
         videoUrl: String = "",
         audioUrl: String = "",
         documentUrl: String = "",
         fileName: String = "",
         fileSize: Int64 = 0,
         replyToMessageId: String? = nil,
         replySenderName: String? = nil,
         replyText: String? = nil,
         replyImageUrl: String? = nil,
         timestamp: Date = Date(),
         isRead: Bool = false,
         isDelivered: Bool = false) {

        self.id = id
        self.chatRoomId = chatRoomId
        self.senderId = senderId
        self.receiverId = receiverId
        self.type = type

        self.text = text
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.audioUrl = audioUrl
        self.documentUrl = documentUrl
        self.fileName = fileName
        self.fileSize = fileSize

        self.replyToMessageId = replyToMessageId
        self.replySenderName = replySenderName
        self.replyText = replyText
        self.replyImageUrl = replyImageUrl

        self.timestamp = timestamp
        self.isRead = isRead
        self.isDelivered  = false
        
    }


    // MARK: - INITIALIZE FROM FIRESTORE SNAPSHOT
    init?(id: String, data: [String: Any]) {

        guard
            let chatRoomId = data["chatRoomId"] as? String,
            let senderId = data["senderId"] as? String,
            let receiverId = data["receiverId"] as? String,
            let rawType = data["type"] as? String,
            let type = MessageType(rawValue: rawType),
            let ts = data["timestamp"] as? Timestamp
        else { return nil }

        self.id = id
        self.chatRoomId = chatRoomId
        self.senderId = senderId
        self.receiverId = receiverId
        self.type = type

        self.text = data["text"] as? String ?? ""
        self.imageUrl = data["imageUrl"] as? String ?? ""
        self.videoUrl = data["videoUrl"] as? String ?? ""
        self.audioUrl = data["audioUrl"] as? String ?? ""
        self.documentUrl = data["documentUrl"] as? String ?? ""

        self.fileName = data["fileName"] as? String ?? ""
        self.fileSize = data["fileSize"] as? Int64 ?? 0

        self.replyToMessageId = data["replyToMessageId"] as? String
        self.replySenderName = data["replySenderName"] as? String
        self.replyText = data["replyText"] as? String
        self.replyImageUrl = data["replyImageUrl"] as? String
        self.replyVideoUrl = data["replyVideoUrl"] as? String


        self.timestamp = ts.dateValue()
        self.isRead = data["isRead"] as? Bool ?? false
        self.isDelivered = data["isDelivered"] as? Bool ?? true

    }


    // MARK: - CONVERT TO FIRESTORE DICTIONARY
    func toDictionary() -> [String: Any] {

        var dict: [String: Any] = [
            "chatRoomId": chatRoomId,
            "senderId": senderId,
            "receiverId": receiverId,
            "type": type.rawValue,

            "text": text,
            "imageUrl": imageUrl,
            "videoUrl": videoUrl,
            "audioUrl": audioUrl,
            "documentUrl": documentUrl,
            "fileName": fileName,
            "fileSize": fileSize,

            "timestamp": Timestamp(date: timestamp),
            "isRead": isRead
        ]

        // REPLY FIELDS ONLY WHEN EXIST
        if let replyToMessageId = replyToMessageId {
            dict["replyToMessageId"] = replyToMessageId
        }
        if let replySenderName = replySenderName {
            dict["replySenderName"] = replySenderName
        }
        if let replyText = replyText {
            dict["replyText"] = replyText
        }
        if let replyImageUrl = replyImageUrl {
            dict["replyImageUrl"] = replyImageUrl
        }

        if let replyVideoUrl = replyVideoUrl {
            dict["replyVideoUrl"] = replyVideoUrl
        }

        return dict
    }
}
