import Foundation
import FirebaseFirestore

protocol FirestoreChatServiceProtocol {
    func listenMessages(in roomId: String,
                        pageSize: Int,
                        completion: @escaping ([Message], Any?) -> Void)

    func loadMoreMessages(in roomId: String,
                          before snapshot: Any,
                          limit: Int,
                          completion: @escaping ([Message], Any?) -> Void)

    func send(message: Message,
              completion: ((Error?) -> Void)?)
    func markMessagesAsRead(in roomId: String,
                            messageIds: [String],
                            completion: ((Error?) -> Void)?)

}

final class FirestoreChatService: FirestoreChatServiceProtocol {

    private let db = Firestore.firestore()

    // ------------------------------------------------
    // MARK: FIRST PAGE (Real-time listener)
    // ------------------------------------------------
    func listenMessages(in roomId: String,
                        pageSize: Int,
                        completion: @escaping ([Message], Any?) -> Void) {

        db.collection("chats")
            .document(roomId)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
            .addSnapshotListener { snapshot, error in

                guard let docs = snapshot?.documents else {
                    completion([], nil)
                    return
                }

                // Convert to models (descending)
                var messages: [Message] = docs.compactMap { doc in
                    Message(id: doc.documentID, data: doc.data())
                }

                // Reverse → newest at bottom like UI
                messages.reverse()

                // Keep last document for pagination
                let lastSnapshot = docs.last

                completion(messages, lastSnapshot)
            }
    }

    func markMessagesAsRead(in roomId: String,
                            messageIds: [String],
                            completion: ((Error?) -> Void)? = nil) {

        let batch = db.batch()

        for msgId in messageIds {
            let ref = db.collection("chats")
                .document(roomId)
                .collection("messages")
                .document(msgId)

            batch.updateData(["isRead": true], forDocument: ref)
        }

        batch.commit { error in
            completion?(error)
        }
    }

    // ------------------------------------------------
    // MARK: LOAD OLDER MESSAGES
    // ------------------------------------------------
    func loadMoreMessages(in roomId: String,
                          before snapshot: Any,
                          limit: Int,
                          completion: @escaping ([Message], Any?) -> Void) {

        guard let snap = snapshot as? DocumentSnapshot else {
            completion([], nil)
            return
        }

        db.collection("chats")
            .document(roomId)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .start(afterDocument: snap)
            .limit(to: limit)
            .getDocuments { result, error in

                guard let docs = result?.documents, docs.count > 0 else {
                    completion([], nil)
                    return
                }

                // Convert to models
                var older: [Message] = docs.compactMap { doc in
                    Message(id: doc.documentID, data: doc.data())
                }

                older.reverse()

                // New last snapshot for next page
                let newLast = docs.last

                completion(older, newLast)
            }
    }

    // ------------------------------------------------
    // MARK: SEND MESSAGE
    // ------------------------------------------------
    func send(message: Message,
              completion: ((Error?) -> Void)? = nil) {

        db.collection("chats")
            .document(message.chatRoomId)
            .collection("messages")
            .document(message.id)
            .setData(message.toDictionary()) { error in
                completion?(error)
            }
    }
}
