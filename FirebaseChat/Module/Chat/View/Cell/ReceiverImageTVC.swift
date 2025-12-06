//
//  ReceiverImageTVC.swift
//  FirebaseChat
//
//  Created by Rohit on 05/12/25.
//

import UIKit

class ReceiverImageTVC: UITableViewCell {

    
    @IBOutlet weak var leftBubbleView: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var leftImageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(message: Message) {
        leftImageView.sd_setImage(
                with: URL(string: message.imageUrl),
                placeholderImage: UIImage(named: "placeholder")
            )
        }
//    func configure(message: Message, currentUserId: String) {
//        
//       
//            leftImageHeight.constant = 200  // Set bubble height
//            
//            leftImageView.sd_setImage(
//                with: URL(string: message.imageUrl),
//                placeholderImage: UIImage(named: "placeholder")
//            )
//       
//        
//        self.layoutIfNeeded()
//    }
}
