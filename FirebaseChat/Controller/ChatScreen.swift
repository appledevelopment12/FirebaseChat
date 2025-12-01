//
//  ChatScreen.swift
//  FirebaseChat
//
//  Created by Rohit on 29/11/25.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ChatScreen: UIViewController, UIGestureRecognizerDelegate, UITextViewDelegate {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textview: PlaceholderTextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var BottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var replyPreviewView: UIView!
    @IBOutlet weak var replyPreviewViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var replyPreviewSenderLabel: UILabel!
    @IBOutlet weak var replyPreviewMessageLabel: UILabel!
    @IBOutlet weak var replyPreviewCloseBtn: UIButton!
    @IBOutlet weak var replyPreviewimage: UIImageView!

    var slidingCell: UIView? = nil
    var slidingOriginalX: CGFloat = 0

    var username = ""
    
    var messages: [Message] = []

    var currentUserId: String = UserDefaults.standard.string(forKey: "userId") ?? ""
    var receiverUserId: String = ""   // Pass from previous screen

    let db = Firestore.firestore()
    var chatRoomId = ""

    var replyMessage: Message? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        userName.text = username
        // MARK: Chat Room ID
        chatRoomId = currentUserId < receiverUserId ?
            "\(currentUserId)_\(receiverUserId)" :
            "\(receiverUserId)_\(currentUserId)"
        print("chatroom id \(chatRoomId)")
        setupUI()
        listenMessages()
        self.navigationController?.navigationBar.isHidden = true
        replyPreviewView.isHidden = true
        replyPreviewViewConstraint.constant = 0
        textViewHeightConstraint.constant = 60

    }
    @IBAction func closeReply(_ sender: UIButton) {
        replyMessage = nil
        replyPreviewView.isHidden = true
        replyPreviewViewConstraint.constant = 0
        textViewHeightConstraint.constant = 60
    }

    
    @IBAction func backBtn(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    func setupUI() {
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
        chatTableView.register(UINib(nibName: "ChatCell", bundle: nil),
                               forCellReuseIdentifier: "ChatCell")
        chatTableView.register(UINib(nibName: "ImageMessageCell", bundle: nil),
                               forCellReuseIdentifier: "ImageMessageCell")
//        chatTableView.register(MixedMessageCell.self, forCellReuseIdentifier: "MixedMessageCell")
        chatTableView.register(UINib(nibName: "MixedReplyMessageCell", bundle: nil), forCellReuseIdentifier: "MixedReplyMessageCell")

       // setupUI()
       // setupConstraints()
        textview.delegate = self
        textview.placeholder = "Message"
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 100
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShows(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHides(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardIfTappedOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        listenMessages()

    }
    @IBAction func galleryActionBtn(_ sender: UIButton){
        let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true        // optional
            self.present(picker, animated: true)
    }
    @objc func keyboardWillShows(_ notification: Notification) {
          if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
              let keyboardHeight = keyboardFrame.height
              let safeAreaBottomHeight = view.safeAreaInsets.bottom
              UIView.animate(withDuration: 0.3) {
                  self.BottomViewBottomConstraint.constant = keyboardHeight - safeAreaBottomHeight
                  self.view.layoutIfNeeded()
              }
              scrollToBottom()
          }
      }
      @objc func keyboardWillHides(_ notification: Notification) {
          UIView.animate(withDuration: 0.3) {
              self.BottomViewBottomConstraint.constant = 0
              self.view.layoutIfNeeded()
          }
      }
      deinit {
          NotificationCenter.default.removeObserver(self)
      }
    
    @objc func dismissKeyboardIfTappedOutside(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)

        let tappedView = self.view.hitTest(location, with: nil)

        // Only dismiss keyboard if tap is NOT on textBox or sendButton
        if tappedView != textview && tappedView != sendButton {
            self.view.endEditing(true)
        }
    }
//    func textViewDidChange(_ textView: UITextView) {
//        let size = CGSize(width: textView.frame.width, height: .infinity)
//        let estimatedSize = textView.sizeThatFits(size)
//        
//        let maxHeight: CGFloat = 100        // Maximum allowed height
//        let minHeight: CGFloat = 55         // Minimum height (bar doesn't shrink too small)
//
//        if estimatedSize.height > maxHeight {
//            textViewHeightConstraint.constant = maxHeight
//            textView.isScrollEnabled = true   // Enable scroll when limit reached
//        } else {
//            textViewHeightConstraint.constant = max(minHeight, estimatedSize.height)
//            textView.isScrollEnabled = false  // Disable scroll for natural expansion
//        }
//        
//        self.view.layoutIfNeeded()
//    }

    
    @IBAction func sendBtnTapped(_ sender: UIButton) {
       
        
        let text = textview.text.trimmingCharacters(in: .whitespacesAndNewlines)
           if text.isEmpty { return }
           
        sendText(text)
        
           textview.text = ""
           textViewHeightConstraint.constant = 60
    }
    func sendText(_ txt: String) {
            
            var data: [String: Any] = [
                "senderId": currentUserId,
                "receiverId": receiverUserId,
                "message": txt,
                "imageUrl": "",
                "timestamp": Timestamp()
            ]
            
            if let r = replyMessage {
                data["replySenderName"] = r.senderId == currentUserId ? "You" : username
                data["replyText"] = r.message
                data["replyImageUrl"] = r.imageUrl
            }
            
            replyPreviewView.isHidden = true
            replyMessage = nil

            db.collection("chats")
                .document(chatRoomId)
                .collection("messages")
                .addDocument(data: data)
        }


    // MARK: SLIDE TO REPLY
       func addReplyGesture(to cell: UITableViewCell, index: Int) {
           cell.tag = index
           
           let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSlideReply(_:)))
           pan.delegate = self
           cell.addGestureRecognizer(pan)
       }

    @objc func handleSlideReply(_ gesture: UIPanGestureRecognizer) {

        guard let cell = gesture.view else { return }
        let translation = gesture.translation(in: cell.superview)

        switch gesture.state {

        case .began:
            slidingCell = cell
            slidingOriginalX = cell.frame.origin.x

        case .changed:
            // Allow sliding only to right direction
            if translation.x > 0 {
                let offset = min(translation.x, 80)   // max slide width
                cell.transform = CGAffineTransform(translationX: offset, y: 0)
            }

        case .ended, .cancelled:
            let shouldReply = translation.x > 60  // threshold for reply
            
            UIView.animate(withDuration: 0.20,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.4,
                           options: .curveEaseOut,
                           animations: {
                cell.transform = .identity   // return back smoothly
            })

            if shouldReply {
                let msg = messages[cell.tag]
                replyMessage = msg
                showReplyPreviewUI()
            }

        default:
            break
        }
    }

    func showReplyPreviewUI() {
        replyPreviewViewConstraint.constant = 60
        textViewHeightConstraint.constant = 130


        guard let r = replyMessage else { return }

        replyPreviewView.isHidden = false

        // Sender Name
        replyPreviewSenderLabel.text = (r.senderId == currentUserId) ? "You" : username

        // -------------------------
        // TEXT for preview
        // -------------------------
        replyPreviewMessageLabel.text =
            r.message.isEmpty ? "Photo" : r.message


        // -------------------------
        // IMAGE for preview (priority)
        //
        // 1) replyImageUrl (if replying to image)
        // 2) imageUrl (main image message)
        // 3) no image → hide
        // -------------------------

        if !r.replyImageUrl.isEmpty {
            replyPreviewimage.isHidden = false
            replyPreviewimage.sd_setImage(
                with: URL(string: r.replyImageUrl),
                placeholderImage: UIImage(named: "placeholder")
            )
        }
        else if !r.imageUrl.isEmpty {
            replyPreviewimage.isHidden = false
            replyPreviewimage.sd_setImage(
                with: URL(string: r.imageUrl),
                placeholderImage: UIImage(named: "placeholder")
            )
        }
        else {
            replyPreviewimage.isHidden = true
        }
    }



    // MARK: LISTEN MESSAGES
       func listenMessages() {
           db.collection("chats")
               .document(chatRoomId)
               .collection("messages")
               .order(by: "timestamp")
               .addSnapshotListener { snap, err in
                   
                   guard let docs = snap?.documents else { return }
                   
                   self.messages = docs.map { d in
                       let data = d.data()
                       
                       return Message(
                           senderId: data["senderId"] as? String ?? "",
                           receiverId: data["receiverId"] as? String ?? "",
                           message: data["message"] as? String ?? "",
                           imageUrl: data["imageUrl"] as? String ?? "",
                           timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(), replySenderName: data["replySenderName"] as? String ?? "",
                           replyText: data["replyText"] as? String ?? "",
                           replyImageUrl: data["replyImageUrl"] as? String ?? ""
                       )
                   }
                   
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

        let msg = messages[indexPath.row]
                let isSender = msg.senderId == currentUserId


                // CASE 1 — reply mixed messages
                if msg.replyText != "" || msg.replyImageUrl != "" || (msg.imageUrl != "" && msg.message != "") {
                    
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "MixedReplyMessageCell",
                        for: indexPath
                    ) as! MixedReplyMessageCell
                    
                    cell.configure(message: msg, isSender: isSender)

                    addReplyGesture(to: cell, index: indexPath.row)
                    return cell
                }

                // CASE 2 — only image
                if msg.imageUrl != "" && msg.message == "" {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "ImageMessageCell",
                        for: indexPath
                    ) as! ImageMessageCell
                    
                    cell.configure(message: msg, currentUserId: currentUserId)
                    cell.selectionStyle = .none

                    addReplyGesture(to: cell, index: indexPath.row)
                    return cell
                }

                // CASE 3 — only text
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "ChatCell",
                    for: indexPath
                ) as! ChatCell
                
                cell.configure(message: msg, currentUserId: currentUserId)
                cell.selectionStyle = .none
                addReplyGesture(to: cell, index: indexPath.row)
                return cell
    }

    }
extension ChatScreen {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
        return true
    }
}
extension ChatScreen: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage ??
                info[.originalImage] as? UIImage else { return }
        
        uploadChatImage(image)
    }
    func uploadChatImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let storageRef = Storage.storage().reference()
            .child("chatImages")
            .child("\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Image upload error:", error.localizedDescription)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let url = url {
                    // Save message with image URL
                    self.sendImageMessage(url.absoluteString)
                }
            }
        }
    }
    func sendImageMessage(_ imageUrl: String) {
        var data: [String: Any] = [
            "senderId": currentUserId,
            "receiverId": receiverUserId,
            "imageUrl": imageUrl,
            "message": "",
            "timestamp": Timestamp()
        ]
        
        // reply case
                if let reply = replyMessage {
                    data["replySenderName"] = reply.senderId == currentUserId ? "You" : username
                    data["replyText"] = reply.message
                    data["replyImageUrl"] = reply.imageUrl
                }
        
        db.collection("chats")
            .document(chatRoomId)
            .collection("messages")
            .addDocument(data: data)
        
        replyMessage = nil

    }
}
