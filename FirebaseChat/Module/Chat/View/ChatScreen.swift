//
//  ChatScreen.swift
//  FirebaseChat
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import AVFoundation
import MobileCoreServices
import AVKit

class ChatScreen: UIViewController, UITextViewDelegate {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textView: PlaceholderTextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var namelbl: UILabel!
    @IBOutlet weak var replyPreviewContainer: UIView!
    @IBOutlet weak var replySenderLabel: UILabel!
    @IBOutlet weak var replyMessageLabel: UILabel!
    @IBOutlet weak var replyImagePreview: UIImageView!
    @IBOutlet weak var replyPreviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteBtn: UIButton!


    var replyMsg: Message?
    var slidingCell: UIView?
    var slidingOriginalX: CGFloat = 0
    var viewModel: ChatViewModel!
    var username = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        namelbl.text = username
        setupTable()
        setupTextView()
        setupKeyboardObservers()

        replyPreviewContainer.isHidden = true
        replyPreviewHeightConstraint.constant = 0

        viewModel.startListening()
        viewModel.onMessagesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.chatTableView.reloadData()
                self?.scrollToBottom()
            }
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false      // ⭐ IMPORTANT
        tap.delegate = self                   // ⭐ IMPORTANT
        chatTableView.addGestureRecognizer(tap)

    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @IBAction func backBtn(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func deleteChatActionBtn(_ sender: UIButton){
    }
    @IBAction func SendImage(_ sender: UIButton){
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        sheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        sheet.addAction(UIAlertAction(title: "File", style: .default, handler: { _ in
            self.openDocumentPicker()
        }))
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        sheet.popoverPresentationController?.sourceView = sender
        present(sheet, animated: true)
    }
    func openDocumentPicker() {
        let types = ["public.data", "public.content", "com.adobe.pdf"]
        let picker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

}
extension ChatScreen: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {

        guard let fileURL = urls.first else { return }

        // Upload file
        uploadDocument(fileURL)
        func uploadDocument(_ fileURL: URL) {

            let fileName = fileURL.lastPathComponent
            let path = "chatDocs/\(UUID().uuidString)_\(fileName)"

            let ref = Storage.storage().reference().child(path)

            ref.putFile(from: fileURL, metadata: nil) { meta, error in
                if let error = error {
                    print("Document upload error: \(error.localizedDescription)")
                    return
                }

                ref.downloadURL { url, _ in
                    if let url = url {
                        self.sendDocumentMessage(url.absoluteString, fileName: fileName)
                    }
                }
            }
        }

    }
    func sendDocumentMessage(_ documentUrl: String, fileName: String) {

        // create message
        let msg = Message(
            chatRoomId: viewModel.chatRoomId,
            senderId: viewModel.currentUserId,
            receiverId: viewModel.otherUserId,
            type: .document,
            documentUrl: documentUrl,
            fileName: fileName
        )

        // send using ViewModel
        viewModel.sendDocumentMessage(documentUrl, fileName: fileName)
    }


    func openGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image", "public.movie"]
        present(picker, animated: true)
    }
    func openCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image", "public.movie"]
        present(picker, animated: true)
    }

}
extension ChatScreen: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            uploadImage(image)
        }
        else if let videoUrl = info[.mediaURL] as? URL {
            uploadVideo(videoUrl)
        }
    }
    
    func uploadImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.6) else { return }

        let path = "chatImages/\(UUID().uuidString).jpg"
        let ref = Storage.storage().reference().child(path)

        ref.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("Image upload error:", error.localizedDescription)
                return
            }

            ref.downloadURL { url, _ in
                DispatchQueue.main.async {
                    self.sendImageMessage(url!.absoluteString)
                }
            }
        }
    }

    func sendImageMessage(_ url: String) {
        // Create message data
        let msg = Message(
            chatRoomId: viewModel.chatRoomId,
            senderId: viewModel.currentUserId,
            receiverId: viewModel.otherUserId,
            type: .image,
            imageUrl: url
        )

        // Use ViewModel
        viewModel.sendImageMessage(url)
    }

    
    
    func uploadVideo(_ videoUrl: URL) {

        let path = "chatVideos/\(UUID().uuidString).mp4"
        let ref = Storage.storage().reference().child(path)

        ref.putFile(from: videoUrl, metadata: nil) { meta, error in

            if let error = error {
                print("Video upload error:", error.localizedDescription)
                return
            }

            ref.downloadURL { url, _ in
                if let url = url {
                    self.sendVideoMessage(url.absoluteString)
                }
            }
        }
    }

    func sendVideoMessage(_ url: String) {
        let msg = Message(
            chatRoomId: viewModel.chatRoomId,
            senderId: viewModel.currentUserId,
            receiverId: viewModel.otherUserId,
            type: .video,
            videoUrl: url
        )

        // Correct call 👇
        viewModel.sendVideoMessage(url)
    }

}


extension ChatScreen {

    func setupTable() {
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 150

        // Register all cells
        chatTableView.register(UINib(nibName: "SenderTextTVC", bundle: nil), forCellReuseIdentifier: "SenderTextTVC")
        chatTableView.register(UINib(nibName: "ReceiverTextTVC", bundle: nil), forCellReuseIdentifier: "ReceiverTextTVC")
        chatTableView.register(UINib(nibName: "SenderImageTVC", bundle: nil), forCellReuseIdentifier: "SenderImageTVC")
        chatTableView.register(UINib(nibName: "ReceiverImageTVC", bundle: nil), forCellReuseIdentifier: "ReceiverImageTVC")
        chatTableView.register(UINib(nibName: "SenderVideoTVC", bundle: nil), forCellReuseIdentifier: "SenderVideoTVC")
        chatTableView.register(UINib(nibName: "ReceiveVideoTVC", bundle: nil), forCellReuseIdentifier: "ReceiveVideoTVC")
        chatTableView.register(UINib(nibName: "SenderAudioTVC", bundle: nil), forCellReuseIdentifier: "SenderAudioTVC")
        chatTableView.register(UINib(nibName: "ReceiverAudioTVC", bundle: nil), forCellReuseIdentifier: "ReceiverAudioTVC")
        chatTableView.register(UINib(nibName: "SenderDocTVC", bundle: nil), forCellReuseIdentifier: "SenderDocTVC")
        chatTableView.register(UINib(nibName: "ReceiverDocTVC", bundle: nil), forCellReuseIdentifier: "ReceiverDocTVC")
        chatTableView.register(UINib(nibName: "MixedReplyMessageCell", bundle: nil), forCellReuseIdentifier: "MixedReplyMessageCell")
    }

    func setupTextView() {
        textView.placeholder = "Message"
        textView.delegate = self
        textViewHeightConstraint.constant = 55
    }
}


extension ChatScreen {
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let height = frame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: 0.3) {
            self.bottomViewBottomConstraint.constant = height
            self.view.layoutIfNeeded()
        }
        scrollToBottom()
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    @IBAction func sendBtnTapped(_ sender: UIButton) {
        
        let txt = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if txt.isEmpty { return }
        
        viewModel.sendText(txt, replyTo: replyMsg)
        
        // reset
        replyMsg = nil
        replyPreviewContainer.isHidden = true
        replyPreviewHeightConstraint.constant = 0
        
        textView.text = ""
        textViewHeightConstraint.constant = 55
    }
    func scrollToBottom() {
        DispatchQueue.main.async {
            let last = self.viewModel.messages.count - 1
            if last >= 0 {
                let index = IndexPath(row: last, section: 0)
                self.chatTableView.scrollToRow(at: index, at: .bottom, animated: true)
            }
        }
    }
    func showReplyPreview(_ msg: Message) {

        replyMsg = msg

        replyPreviewContainer.isHidden = false
        replyPreviewHeightConstraint.constant = 60
        textViewHeightConstraint.constant = 130

        replySenderLabel.text = (msg.senderId == viewModel.currentUserId) ? "You" : "Sender"
        replyMessageLabel.text = msg.text.isEmpty ? "Media" : msg.text

        // 1️⃣ VIDEO REPLY
        if let video = msg.replyVideoUrl, !video.isEmpty {
            replyImagePreview.isHidden = false
            replyImagePreview.image = generateVideoThumbnail(url: URL(string: video)!)
            return
        }

        // 2️⃣ IMAGE REPLY
        if !msg.imageUrl.isEmpty {
            replyImagePreview.isHidden = false
            replyImagePreview.sd_setImage(with: URL(string: msg.imageUrl))
            return
        }

        // 3️⃣ NO MEDIA
        replyImagePreview.isHidden = true
    }

    func generateVideoThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        let time = CMTimeMake(value: 1, timescale: 2)
        if let cg = try? generator.copyCGImage(at: time, actualTime: nil) {
            return UIImage(cgImage: cg)
        }
        return nil
    }

    @IBAction func closeReply(_ sender: UIButton) {
        replyMsg = nil
        replyPreviewContainer.isHidden = true
        replyPreviewHeightConstraint.constant = 0
        textViewHeightConstraint.constant = 60
    }
    func addReplyGesture(to cell: UITableViewCell, index: Int) {
        cell.tag = index
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSlideReply(_:)))
        pan.cancelsTouchesInView = false   // ⭐ LET TABLE SCROLL
        pan.delegate = self                // ⭐ USE SIMULTANEOUS
        cell.addGestureRecognizer(pan)
    }

    @objc func handleSlideReply(_ gesture: UIPanGestureRecognizer) {

        let cell = gesture.view!
        let translation = gesture.translation(in: cell)

        // ⭐ Only horizontal swipe → NOT vertical scroll
        if abs(translation.x) < abs(translation.y) {
            return // allow scroll
        }

        switch gesture.state {
        case .changed:
            if translation.x > 0 {
                cell.transform = CGAffineTransform(translationX: min(translation.x, 80), y: 0)
            }

        case .ended:
            if translation.x > 60 {
                let msg = viewModel.messages[cell.tag]
                showReplyPreview(msg)
            }

            UIView.animate(withDuration: 0.2) {
                cell.transform = .identity
            }

        default:
            break
        }
    }

    
    func downloadPDF(message: Message, completion: @escaping (Message) -> Void) {

        guard let url = URL(string: message.documentUrl) else { return }

        URLSession.shared.downloadTask(with: url) { tempUrl, response, error in

            guard let tempUrl = tempUrl else { return }

            // Create preview image from PDF first page
            if let preview = self.generatePDFThumbnail(url: tempUrl) {

                var updated = message
                updated.localPreviewImage = preview
                updated.isDownloaded = true

                completion(updated)
            }

        }.resume()
    }
    func generatePDFThumbnail(url: URL) -> UIImage? {

        guard let doc = CGPDFDocument(url as CFURL),
              let page = doc.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)

        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            ctx.cgContext.drawPDFPage(page)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 50 {   // near top
            viewModel.loadMoreIfNeeded()
        }
    }


}
extension ChatScreen: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func playVideo(url: String) {
        guard let videoURL = URL(string: url) else { return }

        let player = AVPlayer(url: videoURL)
        let vc = AVPlayerViewController()
        vc.player = player

        present(vc, animated: true) {
            player.play()
        }
    }
    func scrollToAndHighlight(at indexPath: IndexPath) {
        chatTableView.scrollToRow(at: indexPath, at: .middle, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            guard let cell = self.chatTableView.cellForRow(at: indexPath) else { return }

            let original = cell.contentView.backgroundColor
            let highlight = UIColor.systemYellow.withAlphaComponent(0.35)

            cell.contentView.backgroundColor = highlight
            UIView.animate(withDuration: 0.6, delay: 0.3, options: []) {
                cell.contentView.backgroundColor = original ?? .clear
            }
        }
    }
    func showMessageOptions(for msg: Message) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // Only allow delete if you sent the message OR delete for yourself
        alert.addAction(UIAlertAction(title: "Delete for me", style: .destructive, handler: { _ in
            self.viewModel.deleteMessageForMe(msg)
        }))

        if msg.senderId == viewModel.currentUserId {
            alert.addAction(UIAlertAction(title: "Delete for everyone", style: .destructive, handler: { _ in
                self.viewModel.deleteMessageForEveryone(msg)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }


}

    extension ChatScreen: UITableViewDelegate, UITableViewDataSource {

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return viewModel.messages.count
        }

        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let msg = viewModel.messages[indexPath.row]
            let isSender = msg.senderId == viewModel.currentUserId

            // ⭐ Mixed reply case
            if msg.replyText != nil ||
               msg.replyImageUrl != nil ||
               msg.replyVideoUrl != nil {

                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "MixedReplyMessageCell",
                    for: indexPath
                ) as! MixedReplyMessageCell

                cell.configure(message: msg, isSender: isSender)
                

                // 🔍 TAP REPLY → SCROLL TO ORIGINAL
                cell.onReplyTap = { [weak self] in
                    guard let self = self else { return }
                    guard let replyId = msg.replyToMessageId else { return }

                    if let idx = self.viewModel.messages.firstIndex(where: { $0.id == replyId }) {
                        let ip = IndexPath(row: idx, section: 0)
                        self.scrollToAndHighlight(at: ip)
                    }
                }

                addReplyGesture(to: cell, index: indexPath.row)
                let longPress = UILongPressGestureRecognizer(
                            target: self,
                            action: #selector(handleLongPress(_:))
                        )
                cell.addGestureRecognizer(longPress)

                return cell
            }

            switch msg.type {

            case .text:
                if isSender {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "SenderTextTVC",
                        for: indexPath
                    ) as! SenderTextTVC

                    cell.configure(message: msg)
                    addReplyGesture(to: cell, index: indexPath.row)
                    let longPress = UILongPressGestureRecognizer(
                                target: self,
                                action: #selector(handleLongPress(_:))
                            )
                    cell.addGestureRecognizer(longPress)

                    return cell

                } else {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "ReceiverTextTVC",
                        for: indexPath
                    ) as! ReceiverTextTVC

                    cell.configure(message: msg)
                    addReplyGesture(to: cell, index: indexPath.row)
                    let longPress = UILongPressGestureRecognizer(
                                target: self,
                                action: #selector(handleLongPress(_:))
                            )
                    cell.addGestureRecognizer(longPress)

                    return cell
                }

            case .image:
                if isSender {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "SenderImageTVC",
                        for: indexPath
                    ) as! SenderImageTVC

                    cell.configure(message: msg)
                    addReplyGesture(to: cell, index: indexPath.row)
                    let longPress = UILongPressGestureRecognizer(
                                target: self,
                                action: #selector(handleLongPress(_:))
                            )
                    cell.addGestureRecognizer(longPress)

                    return cell

                } else {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "ReceiverImageTVC",
                        for: indexPath
                    ) as! ReceiverImageTVC

                    cell.configure(message: msg)
                    addReplyGesture(to: cell, index: indexPath.row)
                    let longPress = UILongPressGestureRecognizer(
                                target: self,
                                action: #selector(handleLongPress(_:))
                            )
                    cell.addGestureRecognizer(longPress)

                    return cell
                }

            case .video:

                if isSender {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "SenderVideoTVC",
                        for: indexPath
                    ) as! SenderVideoTVC

                    cell.configure(message: msg)

                    cell.onPlayTapped = {
                        self.playVideo(url: msg.videoUrl)
                    }
                    addReplyGesture(to: cell, index: indexPath.row)
                    let longPress = UILongPressGestureRecognizer(
                                target: self,
                                action: #selector(handleLongPress(_:))
                            )
                    cell.addGestureRecognizer(longPress)

                    return cell

                } else {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "ReceiveVideoTVC",
                        for: indexPath
                    ) as! ReceiveVideoTVC

                    cell.configure(message: msg)

                    cell.onPlayTapped = {
                        self.playVideo(url: msg.videoUrl)
                    }
                    addReplyGesture(to: cell, index: indexPath.row)
                    let longPress = UILongPressGestureRecognizer(
                                target: self,
                                action: #selector(handleLongPress(_:))
                            )
                    cell.addGestureRecognizer(longPress)

                    return cell
                }


            case .audio:
                if isSender {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "SenderAudioTVC",
                        for: indexPath
                    ) as! SenderAudioTVC

//                    cell.configure(message: msg)
//                    addReplyGesture(to: cell, index: indexPath.row)
                    return cell

                } else {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "ReceiverAudioTVC",
                        for: indexPath
                    ) as! ReceiverAudioTVC

//                    cell.configure(message: msg)
//                    addReplyGesture(to: cell, index: indexPath.row)
                    return cell
                }

            case .document:

                if isSender {

                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "SenderDocTVC", for: indexPath
                    ) as! SenderDocTVC

                    cell.configure(message: msg)

                    cell.onDownloadTapped = {
                        self.downloadPDF(message: msg) { updatedMessage in
                           // self.viewModel.updateMessage(updatedMessage)
                        }
                    }
                    let longPress = UILongPressGestureRecognizer(
                                target: self,
                                action: #selector(handleLongPress(_:))
                            )
                    cell.addGestureRecognizer(longPress)

                    return cell

                } else {

                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "ReceiverDocTVC", for: indexPath
                    ) as! ReceiverDocTVC

                    cell.configure(message: msg)

                    cell.onDownloadTapped = {
                        self.downloadPDF(message: msg) { updatedMessage in
                          //  self.viewModel.updateMessage(updatedMessage)
                        }
                    }
                    let longPress = UILongPressGestureRecognizer(
                                target: self,
                                action: #selector(handleLongPress(_:))
                            )
                    cell.addGestureRecognizer(longPress)

                    return cell
                }


            case .voiceNote, .system:
                return UITableViewCell()
            }
        }
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state != .began { return }

            guard let cell = gesture.view as? UITableViewCell,
                  let indexPath = chatTableView.indexPath(for: cell) else { return }

            let msg = viewModel.messages[indexPath.row]

            showMessageOptions(for: msg)
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

//    
//    @IBAction func sendBtnTapped(_ sender: UIButton) {
//       
//        
//        let text = textview.text.trimmingCharacters(in: .whitespacesAndNewlines)
//           if text.isEmpty { return }
//           
//        sendText(text)
//        
//           textview.text = ""
//           textViewHeightConstraint.constant = 60
//    }
//    func sendText(_ txt: String) {
//            
//            var data: [String: Any] = [
//                "senderId": currentUserId,
//                "receiverId": receiverUserId,
//                "message": txt,
//                "imageUrl": "",
//                "timestamp": Timestamp()
//            ]
//            
//            if let r = replyMessage {
//                data["replySenderName"] = r.senderId == currentUserId ? "You" : username
//                data["replyText"] = r.message
//                data["replyImageUrl"] = r.imageUrl
//            }
//            
//            replyPreviewView.isHidden = true
//            replyMessage = nil
//
//            db.collection("chats")
//                .document(chatRoomId)
//                .collection("messages")
//                .addDocument(data: data)
//        }
//
//
//    // MARK: SLIDE TO REPLY
//       func addReplyGesture(to cell: UITableViewCell, index: Int) {
//           cell.tag = index
//           
//           let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSlideReply(_:)))
//           pan.delegate = self
//           cell.addGestureRecognizer(pan)
//       }
//
//    @objc func handleSlideReply(_ gesture: UIPanGestureRecognizer) {
//
//        guard let cell = gesture.view else { return }
//        let translation = gesture.translation(in: cell.superview)
//
//        switch gesture.state {
//
//        case .began:
//            slidingCell = cell
//            slidingOriginalX = cell.frame.origin.x
//
//        case .changed:
//            // Allow sliding only to right direction
//            if translation.x > 0 {
//                let offset = min(translation.x, 80)   // max slide width
//                cell.transform = CGAffineTransform(translationX: offset, y: 0)
//            }
//
//        case .ended, .cancelled:
//            let shouldReply = translation.x > 60  // threshold for reply
//            
//            UIView.animate(withDuration: 0.20,
//                           delay: 0,
//                           usingSpringWithDamping: 0.8,
//                           initialSpringVelocity: 0.4,
//                           options: .curveEaseOut,
//                           animations: {
//                cell.transform = .identity   // return back smoothly
//            })
//
//            if shouldReply {
//                let msg = messages[cell.tag]
//                replyMessage = msg
//                showReplyPreviewUI()
//            }
//
//        default:
//            break
//        }
//    }
//
//    func showReplyPreviewUI() {
//        replyPreviewViewConstraint.constant = 60
//        textViewHeightConstraint.constant = 130
//
//
//        guard let r = replyMessage else { return }
//
//        replyPreviewView.isHidden = false
//
//        // Sender Name
//        replyPreviewSenderLabel.text = (r.senderId == currentUserId) ? "You" : username
//
//        // -------------------------
//        // TEXT for preview
//        // -------------------------
//        replyPreviewMessageLabel.text =
//            r.message.isEmpty ? "Photo" : r.message
//
//
//        // -------------------------
//        // IMAGE for preview (priority)
//        //
//        // 1) replyImageUrl (if replying to image)
//        // 2) imageUrl (main image message)
//        // 3) no image → hide
//        // -------------------------
//
//        if !r.replyImageUrl.isEmpty {
//            replyPreviewimage.isHidden = false
//            replyPreviewimage.sd_setImage(
//                with: URL(string: r.replyImageUrl),
//                placeholderImage: UIImage(named: "placeholder")
//            )
//        }
//        else if !r.imageUrl.isEmpty {
//            replyPreviewimage.isHidden = false
//            replyPreviewimage.sd_setImage(
//                with: URL(string: r.imageUrl),
//                placeholderImage: UIImage(named: "placeholder")
//            )
//        }
//        else {
//            replyPreviewimage.isHidden = true
//        }
//    }
//
//
//
//    // MARK: LISTEN MESSAGES
//       func listenMessages() {
//           db.collection("chats")
//               .document(chatRoomId)
//               .collection("messages")
//               .order(by: "timestamp")
//               .addSnapshotListener { snap, err in
//                   
//                   guard let docs = snap?.documents else { return }
//                   
//                   self.messages = docs.map { d in
//                       let data = d.data()
//                       
//                       return Message(
//                           senderId: data["senderId"] as? String ?? "",
//                           receiverId: data["receiverId"] as? String ?? "",
//                           message: data["message"] as? String ?? "",
//                           imageUrl: data["imageUrl"] as? String ?? "",
//                           timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(), replySenderName: data["replySenderName"] as? String ?? "",
//                           replyText: data["replyText"] as? String ?? "",
//                           replyImageUrl: data["replyImageUrl"] as? String ?? ""
//                       )
//                   }
//                   
//                   self.chatTableView.reloadData()
//                   self.scrollToBottom()
//               }
//       }
//
//        func scrollToBottom() {
//            DispatchQueue.main.async {
//                let lastRow = self.messages.count - 1
//                if lastRow >= 0 {
//                    let indexPath = IndexPath(row: lastRow, section: 0)
//                    self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//                }
//            }
//        }
//    func cellType(for msg: Message) -> ChatCellType {
//
//        // CASE 1: Mixed Reply
//        if msg.replyText != "" || msg.replyImageUrl != "" ||
//            (msg.message != "" && msg.imageUrl != "") {
//            return .mixedReply
//        }
//
//        // CASE 2: Only Image
//        if msg.imageUrl != "" && msg.message == "" {
//            if msg.senderId == currentUserId { return .senderImage }
//            return .receiverImage
//        }
//
//        // CASE 3: Only Text
//        if msg.senderId == currentUserId { return .senderText }
//        return .receiverText
//    }
//
//    }
//extension ChatScreen: UITableViewDelegate, UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
//    
//    func tableView(_ tableView: UITableView,
//                   cellForRowAt indexPath: IndexPath)
//    -> UITableViewCell {
//        
//        let msg = messages[indexPath.row]
//        let isSender = msg.senderId == currentUserId
//        let type = cellType(for: msg)
//        
//        switch type {
//            
//        case .senderText:
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: "SenderTextTVC",
//                for: indexPath
//            ) as! SenderTextTVC
//            
//            cell.configure(message: msg)
//            addReplyGesture(to: cell, index: indexPath.row)
//            return cell
//            
//        case .receiverText:
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: "ReceiverTextTVC",
//                for: indexPath
//            ) as! ReceiverTextTVC
//            
//            cell.configure(message: msg)
//            addReplyGesture(to: cell, index: indexPath.row)
//            return cell
//            
//        case .senderImage:
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: "SenderImageTVC",
//                for: indexPath
//            ) as! SenderImageTVC
//            
//            cell.configure(message: msg)
//            addReplyGesture(to: cell, index: indexPath.row)
//            return cell
//            
//        case .receiverImage:
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: "ReceiverImageTVC",
//                for: indexPath
//            ) as! ReceiverImageTVC
//            
//            cell.configure(message: msg)
//            addReplyGesture(to: cell, index: indexPath.row)
//            return cell
//            
//        case .mixedReply:
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: "MixedReplyMessageCell",
//                for: indexPath
//            ) as! MixedReplyMessageCell
//            
//            cell.configure(message: msg, isSender: isSender)
//            addReplyGesture(to: cell, index: indexPath.row)
//            return cell
//        }
//        
//        
//        
//        
//    }
//}
//
//
////let msg = messages[indexPath.row]
////let isSender = msg.senderId == currentUserId
//// CASE 1 — reply mixed messages
////if msg.replyText != "" || msg.replyImageUrl != "" || (msg.imageUrl != "" && msg.message != "") {
////    let cell = tableView.dequeueReusableCell( withIdentifier: "MixedReplyMessageCell", for: indexPath ) as! MixedReplyMessageCell cell.configure(message: msg, isSender: isSender)
////    addReplyGesture(to: cell, index: indexPath.row) return cell }
////
//
//
//
//extension ChatScreen {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
//                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
//    -> Bool {
//        return true
//    }
//}
//extension ChatScreen: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController,
//                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        
//        picker.dismiss(animated: true)
//        
//        guard let image = info[.editedImage] as? UIImage ??
//                info[.originalImage] as? UIImage else { return }
//        
//        uploadChatImage(image)
//    }
//    func uploadChatImage(_ image: UIImage) {
//        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
//        
//        let storageRef = Storage.storage().reference()
//            .child("chatImages")
//            .child("\(UUID().uuidString).jpg")
//        
//        storageRef.putData(imageData, metadata: nil) { metadata, error in
//            if let error = error {
//                print("Image upload error:", error.localizedDescription)
//                return
//            }
//            
//            storageRef.downloadURL { url, error in
//                if let url = url {
//                    // Save message with image URL
//                    self.sendImageMessage(url.absoluteString)
//                }
//            }
//        }
//    }
//    func sendImageMessage(_ imageUrl: String) {
//        var data: [String: Any] = [
//            "senderId": currentUserId,
//            "receiverId": receiverUserId,
//            "imageUrl": imageUrl,
//            "message": "",
//            "timestamp": Timestamp()
//        ]
//        
//        // reply case
//                if let reply = replyMessage {
//                    data["replySenderName"] = reply.senderId == currentUserId ? "You" : username
//                    data["replyText"] = reply.message
//                    data["replyImageUrl"] = reply.imageUrl
//                }
//        
//        db.collection("chats")
//            .document(chatRoomId)
//            .collection("messages")
//            .addDocument(data: data)
//        
//        replyMessage = nil
//
//    }
//}
//enum ChatCellType {
//    case senderText
//    case receiverText
//    case senderImage
//    case receiverImage
//    case mixedReply
//}
