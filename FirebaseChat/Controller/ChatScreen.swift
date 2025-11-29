//
//  ChatScreen.swift
//  FirebaseChat
//
//  Created by Rohit on 29/11/25.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatScreen: UIViewController, UIGestureRecognizerDelegate, UITextViewDelegate {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textview: PlaceholderTextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var BottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var userName: UILabel!
    var username = ""
    
    var messages: [Message] = []

    var currentUserId: String = UserDefaults.standard.string(forKey: "userId") ?? ""
    var receiverUserId: String = ""   // Pass from previous screen

    let db = Firestore.firestore()
    var chatRoomId = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        userName.text = username
        // MARK: Chat Room ID
        chatRoomId = currentUserId < receiverUserId ?
            "\(currentUserId)_\(receiverUserId)" :
            "\(receiverUserId)_\(currentUserId)"
        
        setupUI()
        listenMessages()
        self.navigationController?.navigationBar.isHidden = true

    }
    @IBAction func backBtn(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    func setupUI() {
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.register(UINib(nibName: "ChatCell", bundle: nil),
                               forCellReuseIdentifier: "ChatCell")

        textview.delegate = self
        textview.placeholder = "Message"
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillShows(_:)),
//            name: UIResponder.keyboardWillShowNotification, object: nil)
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillHides(_:)),
//            name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardIfTappedOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        listenMessages()

    }
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame =
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        let safeAreaBottom = view.safeAreaInsets.bottom

        UIView.animate(withDuration: 0.3) {
            self.BottomViewBottomConstraint.constant = keyboardHeight - safeAreaBottom
            self.view.layoutIfNeeded()
        }
        
        scrollToBottom()
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.BottomViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    @objc func dismissKeyboardIfTappedOutside(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)

        let tappedView = self.view.hitTest(location, with: nil)

        // Only dismiss keyboard if tap is NOT on textBox or sendButton
        if tappedView != textview && tappedView != sendButton {
            self.view.endEditing(true)
        }
    }

    
    @IBAction func sendBtnTapped(_ sender: UIButton) {
        let text = textview.text.trimmingCharacters(in: .whitespacesAndNewlines)
           if text.isEmpty { return }
           
           sendMessage(text)
           textview.text = ""
           textViewHeightConstraint.constant = 60
    }
    func sendMessage(_ message: String) {
        let data: [String: Any] = [
            "senderId": currentUserId,
            "receiverId": receiverUserId,
            "message": message,
            "timestamp": Timestamp()
        ]
        
        db.collection("chats")
            .document(chatRoomId)
            .collection("messages")
            .addDocument(data: data)
    }

    func listenMessages() {
        db.collection("chats")
            .document(chatRoomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                
                if let error = error {
                    print("Error:", error.localizedDescription)
                    return
                }
                
                self.messages = snapshot?.documents.compactMap { doc in
                    let d = doc.data()
                    return Message(
                        senderId: d["senderId"] as? String ?? "",
                        receiverId: d["receiverId"] as? String ?? "",
                        message: d["message"] as? String ?? "",
                        timestamp: (d["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []
                
                self.chatTableView.reloadData()
                self.scrollToBottom()
            }
    }

        func scrollToBottom() {
            DispatchQueue.main.async {
                let lastRow = self.messages.count - 1
                if lastRow >= 0 {
                    let indexPath = IndexPath(row: lastRow, section: 0)
                    self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }

    }
extension ChatScreen: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell",
                                                 for: indexPath) as! ChatCell
        
        let message = messages[indexPath.row]
        cell.configure(message: message, currentUserId: currentUserId)
        
        return cell
    }
}
