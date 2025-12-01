//
//  MixedReplyMessageCell.swift
//  FirebaseChat
//
//  Created by Rohit on 01/12/25.
//

import UIKit

class MixedReplyMessageCell: UITableViewCell {
    // MARK: - Left UI (Receiver)
    
    @IBOutlet weak var leftContainer: UIView!
    @IBOutlet weak var leftBubble: UIView!

    @IBOutlet weak var leftReplyContainer: UIView!
    @IBOutlet weak var leftReplySenderLabel: UILabel!
    @IBOutlet weak var leftReplyTextLabel: UILabel!
    @IBOutlet weak var leftMainTextLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var leftReplyImageView: UIImageView!
    @IBOutlet weak var leftMainImageView: UIImageView!


    @IBOutlet weak var rightContainer: UIView!
    @IBOutlet weak var rightBubble: UIView!

    @IBOutlet weak var rightReplyContainer: UIView!
    @IBOutlet weak var rightReplySenderLabel: UILabel!
    @IBOutlet weak var rightReplyTextLabel: UILabel!
    @IBOutlet weak var rightMainTextLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var rightReplyImageView: UIImageView!
    @IBOutlet weak var rightmainImageView: UIImageView!

   
  
    override func awakeFromNib() {
        super.awakeFromNib()
      //  setupUI()
      //  setupConstraints()
    }
        
    
    // MARK: - CONFIGURE CELL CONTENT
    func configure(message: Message, isSender: Bool) {
        
        leftContainer.isHidden = isSender
        rightContainer.isHidden = !isSender
        
        let bubble = isSender ? rightBubble : leftBubble
        let mainImage = isSender ? rightmainImageView : leftMainImageView
        let mainText = isSender ? rightMainTextLabel : leftMainTextLabel
        let replyContainer = isSender ? rightReplyContainer : leftReplyContainer
        let replySender = isSender ? rightReplySenderLabel : leftReplySenderLabel
        let replyText = isSender ? rightReplyTextLabel : leftReplyTextLabel
        let replyImage = isSender ? rightReplyImageView : leftReplyImageView
        let timeLabel = isSender ? rightTimeLabel : leftTimeLabel
        
        // Time format
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        timeLabel?.text = df.string(from: message.timestamp)
        
        
        // ---------------- REPLY HANDLING ----------------
        if message.replyText == "" && message.replyImageUrl == "" {
            replyContainer?.isHidden = true
        } else {
            replyContainer?.isHidden = false
            replySender?.text = message.replySenderName
            
            replyText?.text = message.replyText
            replyText?.isHidden = message.replyText == ""
            
            if message.replyImageUrl != "" {
                replyImage?.isHidden = false
                replyImage?.sd_setImage(with: URL(string: message.replyImageUrl))
            } else {
                replyImage?.isHidden = true
            }
        }
        
        
        // ---------------- MAIN IMAGE ----------------
        if message.imageUrl != "" {
            mainImage?.isHidden = false
            mainImage?.sd_setImage(with: URL(string: message.imageUrl))
        } else {
            mainImage?.isHidden = true
        }
        
        
        // ---------------- MAIN TEXT ----------------
        mainText?.text = message.message
        mainText?.isHidden = message.message == ""
    }
}
