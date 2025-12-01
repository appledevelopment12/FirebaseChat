

//
//  MixedMessageCell.swift
//  FirebaseChat
//
//  Created by Rohit on 30/11/25.
//
//
//  MixedMessageCell.swift
//  FirebaseChat
//

import UIKit
import SDWebImage

class MixedMessageCell: UITableViewCell {

    // MARK: - Left UI (Receiver)
    let leftContainer = UIView()
    let leftBubble = UIView()
    
    let leftReplyContainer = UIView()
    let leftReplySenderLabel = UILabel()
    let leftReplyTextLabel = UILabel()//
    let leftReplyImageView = UIImageView()//
    
    let leftMainImageView = UIImageView()
    let leftMainTextLabel = UILabel()
    let leftTimeLabel = UILabel()

    // MARK: - Right UI (Sender)
    let rightContainer = UIView()
    let rightBubble = UIView()
    
    let rightReplyContainer = UIView()
    let rightReplySenderLabel = UILabel()
    let rightReplyTextLabel = UILabel()
    let rightReplyImageView = UIImageView()
    
    let rightMainImageView = UIImageView()
    let rightMainTextLabel = UILabel()
    let rightTimeLabel = UILabel()

    // MARK: INIT
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError() }
    
    
    // MARK: - UI Setup (NO XIB)
    func setupUI() {
        
        // ---------- Common Styles ----------
        [leftReplyImageView, rightReplyImageView,
         leftMainImageView, rightMainImageView].forEach {
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
        }
        
        leftBubble.backgroundColor = UIColor(white: 0.9, alpha: 1)
        rightBubble.backgroundColor = UIColor.red//UIColor(red: 0.20, green: 0.74, blue: 0.32, alpha: 1)
        
        leftBubble.layer.cornerRadius = 14
        rightBubble.layer.cornerRadius = 14
        
        leftMainTextLabel.numberOfLines = 0
        rightMainTextLabel.numberOfLines = 0
        
        leftReplyTextLabel.numberOfLines = 2
        rightReplyTextLabel.numberOfLines = 2
        
        leftReplyContainer.backgroundColor = UIColor(white: 0.85, alpha: 1)
        rightReplyContainer.backgroundColor = UIColor.black//UIColor(white: 1, alpha: 0.3)

        leftReplyContainer.layer.cornerRadius = 8
        rightReplyContainer.layer.cornerRadius = 8
        
        
        // ---------- Add subviews for LEFT ----------
        contentView.addSubview(leftContainer)
        leftContainer.addSubview(leftBubble)
        
        leftBubble.addSubview(leftReplyContainer)
        leftBubble.addSubview(leftMainImageView)
        leftBubble.addSubview(leftMainTextLabel)
        leftBubble.addSubview(leftTimeLabel)
        
        leftReplyContainer.addSubview(leftReplySenderLabel)
        leftReplyContainer.addSubview(leftReplyTextLabel)
        leftReplyContainer.addSubview(leftReplyImageView)
        
        
        // ---------- Add subviews for RIGHT ----------
        contentView.addSubview(rightContainer)
        rightContainer.addSubview(rightBubble)
        
        rightBubble.addSubview(rightReplyContainer)
        rightBubble.addSubview(rightMainImageView)
        rightBubble.addSubview(rightMainTextLabel)
        rightBubble.addSubview(rightTimeLabel)
        
        rightReplyContainer.addSubview(rightReplySenderLabel)
        rightReplyContainer.addSubview(rightReplyTextLabel)
        rightReplyContainer.addSubview(rightReplyImageView)
    }

    
    // MARK: - Constraints
    func setupConstraints() {
        
        // Disable Autoresizing Masks
        [
            leftContainer, rightContainer, leftBubble, rightBubble,
            leftReplyContainer, rightReplyContainer,
            leftReplySenderLabel, rightReplySenderLabel,
            leftReplyTextLabel, rightReplyTextLabel,
            leftReplyImageView, rightReplyImageView,
            leftMainImageView, rightMainImageView,
            leftMainTextLabel, rightMainTextLabel,
            leftTimeLabel, rightTimeLabel
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        
        NSLayoutConstraint.activate([
            
            // ---------- LEFT Side Container ----------
            leftContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            leftContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            leftContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 260),
            leftContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            leftBubble.leadingAnchor.constraint(equalTo: leftContainer.leadingAnchor),
            leftBubble.trailingAnchor.constraint(equalTo: leftContainer.trailingAnchor),
            leftBubble.topAnchor.constraint(equalTo: leftContainer.topAnchor),
            leftBubble.bottomAnchor.constraint(equalTo: leftContainer.bottomAnchor),
            
            
            // ---------- RIGHT Side Container ----------
            rightContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            rightContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            rightContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 260),
            rightContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            rightBubble.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor),
            rightBubble.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor),
            rightBubble.topAnchor.constraint(equalTo: rightContainer.topAnchor),
            rightBubble.bottomAnchor.constraint(equalTo: rightContainer.bottomAnchor),
            
            
            // ---------- LEFT Reply Container ----------
            leftReplyContainer.topAnchor.constraint(equalTo: leftBubble.topAnchor, constant: 6),
            leftReplyContainer.leadingAnchor.constraint(equalTo: leftBubble.leadingAnchor, constant: 6),
            leftReplyContainer.trailingAnchor.constraint(equalTo: leftBubble.trailingAnchor, constant: -6),
            
            leftReplySenderLabel.topAnchor.constraint(equalTo: leftReplyContainer.topAnchor, constant: 4),
            leftReplySenderLabel.leadingAnchor.constraint(equalTo: leftReplyContainer.leadingAnchor, constant: 6),

            leftReplyTextLabel.topAnchor.constraint(equalTo: leftReplySenderLabel.bottomAnchor, constant: 2),
            leftReplyTextLabel.leadingAnchor.constraint(equalTo: leftReplyContainer.leadingAnchor, constant: 6),
            
            leftReplyImageView.trailingAnchor.constraint(equalTo: leftReplyContainer.trailingAnchor, constant: -6),
            leftReplyImageView.topAnchor.constraint(equalTo: leftReplyContainer.topAnchor, constant: 4),
            leftReplyImageView.widthAnchor.constraint(equalToConstant: 40),
            leftReplyImageView.heightAnchor.constraint(equalToConstant: 40),
            
            leftReplyContainer.bottomAnchor.constraint(equalTo: leftReplyTextLabel.bottomAnchor, constant: 6),
            
            
            // ---------- RIGHT Reply Container ----------
            rightReplyContainer.topAnchor.constraint(equalTo: rightBubble.topAnchor, constant: 6),
            rightReplyContainer.leadingAnchor.constraint(equalTo: rightBubble.leadingAnchor, constant: 6),
            rightReplyContainer.trailingAnchor.constraint(equalTo: rightBubble.trailingAnchor, constant: -6),
            
            rightReplySenderLabel.topAnchor.constraint(equalTo: rightReplyContainer.topAnchor, constant: 4),
            rightReplySenderLabel.leadingAnchor.constraint(equalTo: rightReplyContainer.leadingAnchor, constant: 6),

            rightReplyTextLabel.topAnchor.constraint(equalTo: rightReplySenderLabel.bottomAnchor, constant: 2),
            rightReplyTextLabel.leadingAnchor.constraint(equalTo: rightReplyContainer.leadingAnchor, constant: 6),

            rightReplyImageView.trailingAnchor.constraint(equalTo: rightReplyContainer.trailingAnchor, constant: -6),
            rightReplyImageView.topAnchor.constraint(equalTo: rightReplyContainer.topAnchor, constant: 4),
            rightReplyImageView.widthAnchor.constraint(equalToConstant: 40),
            rightReplyImageView.heightAnchor.constraint(equalToConstant: 40),

            rightReplyContainer.bottomAnchor.constraint(equalTo: rightReplyTextLabel.bottomAnchor, constant: 6),
            
            
            // ---------- LEFT Main Content ----------
            leftMainImageView.topAnchor.constraint(equalTo: leftReplyContainer.bottomAnchor, constant: 6),
            leftMainImageView.leadingAnchor.constraint(equalTo: leftBubble.leadingAnchor, constant: 6),
            leftMainImageView.trailingAnchor.constraint(equalTo: leftBubble.trailingAnchor, constant: -6),
            
            leftMainTextLabel.topAnchor.constraint(equalTo: leftMainImageView.bottomAnchor, constant: 6),
            leftMainTextLabel.leadingAnchor.constraint(equalTo: leftBubble.leadingAnchor, constant: 6),
            leftMainTextLabel.trailingAnchor.constraint(equalTo: leftBubble.trailingAnchor, constant: -6),
            
            leftTimeLabel.topAnchor.constraint(equalTo: leftMainTextLabel.bottomAnchor, constant: 4),
            leftTimeLabel.trailingAnchor.constraint(equalTo: leftBubble.trailingAnchor, constant: -6),
            leftTimeLabel.bottomAnchor.constraint(equalTo: leftBubble.bottomAnchor, constant: -6),
            
            
            // ---------- RIGHT Main Content ----------
            rightMainImageView.topAnchor.constraint(equalTo: rightReplyContainer.bottomAnchor, constant: 6),
            rightMainImageView.leadingAnchor.constraint(equalTo: rightBubble.leadingAnchor, constant: 6),
            rightMainImageView.trailingAnchor.constraint(equalTo: rightBubble.trailingAnchor, constant: -6),

            rightMainTextLabel.topAnchor.constraint(equalTo: rightMainImageView.bottomAnchor, constant: 6),
            rightMainTextLabel.leadingAnchor.constraint(equalTo: rightBubble.leadingAnchor, constant: 6),
            rightMainTextLabel.trailingAnchor.constraint(equalTo: rightBubble.trailingAnchor, constant: -6),

            rightTimeLabel.topAnchor.constraint(equalTo: rightMainTextLabel.bottomAnchor, constant: 4),
            rightTimeLabel.trailingAnchor.constraint(equalTo: rightBubble.trailingAnchor, constant: -6),
            rightTimeLabel.bottomAnchor.constraint(equalTo: rightBubble.bottomAnchor, constant: -6),
        ])
    }
    
    
    // MARK: - CONFIGURE CELL CONTENT
    func configure(message: Message, isSender: Bool) {
        
        leftContainer.isHidden = isSender
        rightContainer.isHidden = !isSender
        
        let bubble = isSender ? rightBubble : leftBubble
        let mainImage = isSender ? rightMainImageView : leftMainImageView
        let mainText = isSender ? rightMainTextLabel : leftMainTextLabel
        let replyContainer = isSender ? rightReplyContainer : leftReplyContainer
        let replySender = isSender ? rightReplySenderLabel : leftReplySenderLabel
        let replyText = isSender ? rightReplyTextLabel : leftReplyTextLabel
        let replyImage = isSender ? rightReplyImageView : leftReplyImageView
        let timeLabel = isSender ? rightTimeLabel : leftTimeLabel
        
        // Time format
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        timeLabel.text = df.string(from: message.timestamp)
        
        
        // ---------------- REPLY HANDLING ----------------
        if message.replyText == "" && message.replyImageUrl == "" {
            replyContainer.isHidden = true
        } else {
            replyContainer.isHidden = false
            replySender.text = message.replySenderName
            
            replyText.text = message.replyText
            replyText.isHidden = message.replyText == ""
            
            if message.replyImageUrl != "" {
                replyImage.isHidden = false
                replyImage.sd_setImage(with: URL(string: message.replyImageUrl))
            } else {
                replyImage.isHidden = true
            }
        }
        
        
        // ---------------- MAIN IMAGE ----------------
        if message.imageUrl != "" {
            mainImage.isHidden = false
            mainImage.sd_setImage(with: URL(string: message.imageUrl))
        } else {
            mainImage.isHidden = true
        }
        
        
        // ---------------- MAIN TEXT ----------------
        mainText.text = message.message
        mainText.isHidden = message.message == ""
    }
}
