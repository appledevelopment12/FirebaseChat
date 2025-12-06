//
//  SenderImageTVC.swift
//  FirebaseChat
//
//  Created by Rohit on 05/12/25.
//

import UIKit

class SenderImageTVC: UITableViewCell {

    @IBOutlet weak var rightBubbleView: UIView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var rightImageHeight: NSLayoutConstraint!
    @IBOutlet weak var tickImageView: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(message: Message) {
        if message.isRead {
                tickImageView.image = UIImage(named: "double_blue")     // ✅ read
            } else {
                tickImageView.image = UIImage(named: "double_grey")     // ✅ delivered
            }
        
        rightImageView.sd_setImage(
                with: URL(string: message.imageUrl),
                placeholderImage: UIImage(named: "placeholder")
            )
        }
    
//    func configure(message: Message, currentUserId: String) {
//        
//       
//        rightImageHeight.constant = 200  // Set bubble height
//            
//        rightImageView.sd_setImage(
//                with: URL(string: message.imageUrl),
//                placeholderImage: UIImage(named: "placeholder")
//            )
//       
//        
//        self.layoutIfNeeded()
//    }
}
