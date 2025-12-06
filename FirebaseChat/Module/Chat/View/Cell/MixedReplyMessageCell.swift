//
//  MixedReplyMessageCell.swift
//  FirebaseChat
//
//  Created by Rohit on 01/12/25.
//
import UIKit
import SDWebImage
import AVFoundation

class MixedReplyMessageCell: UITableViewCell {

    // MARK: - Left (Receiver)

    @IBOutlet weak var leftContainer: UIView!
    @IBOutlet weak var leftBubble: UIView!

    @IBOutlet weak var leftReplyContainer: UIView!
    @IBOutlet weak var leftReplySenderLabel: UILabel!
    @IBOutlet weak var leftReplyTextLabel: UILabel!
    @IBOutlet weak var leftReplyImageView: UIImageView!
    @IBOutlet weak var leftMainTextLabel: UILabel!
    @IBOutlet weak var leftMainImageView: UIImageView!
    @IBOutlet weak var leftTimeLabel: UILabel!

    // MARK: - Right (Sender)

    @IBOutlet weak var rightContainer: UIView!
    @IBOutlet weak var rightBubble: UIView!

    @IBOutlet weak var rightReplyContainer: UIView!
    @IBOutlet weak var rightReplySenderLabel: UILabel!
    @IBOutlet weak var rightReplyTextLabel: UILabel!
    @IBOutlet weak var rightReplyImageView: UIImageView!
    @IBOutlet weak var rightMainTextLabel: UILabel!
    @IBOutlet weak var rightMainImageView: UIImageView!
    @IBOutlet weak var rightTimeLabel: UILabel!
    
    var onReplyVideoTap: (() -> Void)?
    var onReplyTap: (() -> Void)?      // 👈 NEW


    override func awakeFromNib() {
        super.awakeFromNib()
        let tapL = UITapGestureRecognizer(target: self, action: #selector(didTapReplyMedia))
            leftReplyContainer.isUserInteractionEnabled = true
            leftReplyContainer.addGestureRecognizer(tapL)

        let tapR = UITapGestureRecognizer(target: self, action: #selector(didTapReplyMedia))
            rightReplyContainer.isUserInteractionEnabled = true
            rightReplyContainer.addGestureRecognizer(tapR)

//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapReplyMedia))
//            leftReplyImageView.isUserInteractionEnabled = true
//            leftReplyImageView.addGestureRecognizer(tap)
//
//            rightReplyImageView.isUserInteractionEnabled = true
//            rightReplyImageView.addGestureRecognizer(tap)
        
        leftBubble.layer.cornerRadius = 12
        rightBubble.layer.cornerRadius = 12

        leftReplyContainer.layer.cornerRadius = 8
        rightReplyContainer.layer.cornerRadius = 8
    }
    @objc private func didTapReplyMedia() {
            onReplyTap?()
        }
    
    // MARK: - CONFIGURE

    func configure(message: Message, isSender: Bool) {

        leftContainer.isHidden = isSender
        rightContainer.isHidden = !isSender

        let replyContainer = isSender ? rightReplyContainer : leftReplyContainer
        let replySender = isSender ? rightReplySenderLabel : leftReplySenderLabel
        let replyText = isSender ? rightReplyTextLabel : leftReplyTextLabel
        let replyImage = isSender ? rightReplyImageView : leftReplyImageView

        // MARK: - TIME
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        (isSender ? rightTimeLabel : leftTimeLabel)?.text = df.string(from: message.timestamp)

        // MARK: - REPLY FLAGS
        let hasReplyText = !(message.replyText ?? "").isEmpty
        let hasReplyImage = !(message.replyImageUrl ?? "").isEmpty
        let hasReplyVideo = !(message.replyVideoUrl ?? "").isEmpty

        // MARK: SHOW/HIDE
        if !hasReplyText && !hasReplyImage && !hasReplyVideo {
            replyContainer?.isHidden = true
        } else {
            replyContainer?.isHidden = false
            replySender?.text = message.replySenderName
        }

        // MARK: - PRIORITY: VIDEO → IMAGE → NONE
        if hasReplyVideo {
            replyImage?.isHidden = false
            if let v = message.replyVideoUrl,
               let url = URL(string: v),
               let thumb = generateVideoThumbnail(url: url) {
                replyImage?.image = thumb
            }
        }
        else if hasReplyImage {
            replyImage?.isHidden = false
            replyImage?.sd_setImage(with: URL(string: message.replyImageUrl ?? ""))
        }
        else {
            replyImage?.isHidden = true
        }

        // MARK: - MAIN IMAGE
        let mainImage = isSender ? rightMainImageView : leftMainImageView
        if message.imageUrl.isEmpty == false {
            mainImage?.isHidden = false
            mainImage?.sd_setImage(with: URL(string: message.imageUrl))
        } else {
            mainImage?.isHidden = true
        }

        // MARK: - MAIN TEXT
        let mainText = isSender ? rightMainTextLabel : leftMainTextLabel
        mainText?.text = message.text
        mainText?.isHidden = message.text.isEmpty
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

}
