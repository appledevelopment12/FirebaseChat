
import UIKit
import AVFoundation
import AVKit
import Foundation
import FirebaseFirestoreInternal


final class ChatViewModel {

    private let chatService: FirestoreChatServiceProtocol
    private let storageService: FirebaseStorageService

    var messages: [Message] = []
    var onMessagesUpdated: (() -> Void)?

    let chatRoomId: String
    let currentUserId: String
    let otherUserId: String

    private var lastSnapshot: Any?
    private let pageSize = 30
    private var isLoadingMore = false


    init(chatRoomId: String,
         currentUserId: String,
         otherUserId: String,
         chatService: FirestoreChatServiceProtocol = FirestoreChatService(),
         storageService: FirebaseStorageService = FirebaseStorageService()) {

        self.chatRoomId = chatRoomId
        self.currentUserId = currentUserId
        self.otherUserId = otherUserId
        self.chatService = chatService
        self.storageService = storageService
    }

    // -------------------------------------------------------
    // MARK: LISTEN (FIRST PAGE REALTIME)
    // -------------------------------------------------------
    func startListening() {

        chatService.listenMessages(in: chatRoomId, pageSize: pageSize) { [weak self] msgs, lastSnap in
            guard let self = self else { return }

            self.messages = msgs
            self.lastSnapshot = lastSnap

            self.markIncomingAsRead()

            DispatchQueue.main.async {
                self.onMessagesUpdated?()
            }
        }
    }


    // -------------------------------------------------------
    // MARK: READ RECEIVED MESSAGES
    // -------------------------------------------------------
    private func markIncomingAsRead() {
        let unreadIds = messages
            .filter { $0.receiverId == currentUserId && !$0.isRead }
            .map { $0.id }

        guard !unreadIds.isEmpty else { return }

        chatService.markMessagesAsRead(
            in: chatRoomId,
            messageIds: unreadIds,
            completion: nil
        )
    }

    // -------------------------------------------------------
    // MARK: SEND MESSAGES (text + reply + media)
    // -------------------------------------------------------
    func sendText(_ text: String, replyTo: Message? = nil) {

        var msg = Message(
            chatRoomId: chatRoomId,
            senderId: currentUserId,
            receiverId: otherUserId,
            type: .text,
            text: text
        )

        if let r = replyTo {
            msg.replyToMessageId = r.id
            msg.replySenderName = (r.senderId == currentUserId) ? "You" : "Other"
            msg.replyText = r.text
            msg.replyImageUrl = r.imageUrl
            msg.replyVideoUrl = r.videoUrl
        }

        chatService.send(message: msg, completion: nil)
    }

    func sendImageMessage(_ url: String) {
        let msg = Message(
            chatRoomId: chatRoomId,
            senderId: currentUserId,
            receiverId: otherUserId,
            type: .image,
            imageUrl: url
        )
        chatService.send(message: msg, completion: nil)
    }

    func sendVideoMessage(_ url: String) {
        let msg = Message(
            chatRoomId: chatRoomId,
            senderId: currentUserId,
            receiverId: otherUserId,
            type: .video,
            videoUrl: url
        )
        chatService.send(message: msg, completion: nil)
    }

    func sendDocumentMessage(_ url: String, fileName: String) {
        let msg = Message(
            chatRoomId: chatRoomId,
            senderId: currentUserId,
            receiverId: otherUserId,
            type: .document,
            documentUrl: url,
            fileName: fileName
        )
        chatService.send(message: msg, completion: nil)
    }

    func deleteMessageForMe(_ msg: Message) {

        let ref = Firestore.firestore()
            .collection("chats")
            .document(chatRoomId)
            .collection("messages")
            .document(msg.id)

        ref.updateData([
            "deletedFor": FieldValue.arrayUnion([currentUserId])
        ])
    }
    func deleteMessageForEveryone(_ msg: Message) {

        let ref = Firestore.firestore()
            .collection("chats")
            .document(chatRoomId)
            .collection("messages")
            .document(msg.id)

        ref.updateData([
            "text": "This message was deleted",
            "imageUrl": "",
            "videoUrl": "",
            "documentUrl": "",
            "replyToMessageId": NSNull()
        ])
    }

  
    // -------------------------------------------------------
    // MARK: PAGINATION (LOAD OLDER)
    // -------------------------------------------------------
    func loadMoreIfNeeded() {

        guard !isLoadingMore,
              let last = lastSnapshot else { return }

        isLoadingMore = true

        chatService.loadMoreMessages(in: chatRoomId, before: last, limit: pageSize) { [weak self] older, newLast in
            guard let self = self else { return }

            self.isLoadingMore = false
            guard !older.isEmpty else { return }

            self.messages.insert(contentsOf: older, at: 0)
            self.lastSnapshot = newLast

            DispatchQueue.main.async {
                self.onMessagesUpdated?()
            }
        }
    }
}
