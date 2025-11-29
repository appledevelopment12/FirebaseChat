//
//  ChatCell.swift
//  FirebaseChat
//
//  Created by Rohit on 29/11/25.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var leftBubbleView: UIView!
    @IBOutlet weak var rightBubbleView: UIView!
    
    @IBOutlet weak var leftMessageLabel: UILabel!
    @IBOutlet weak var rightMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        leftBubbleView.layer.cornerRadius = 15
        rightBubbleView.layer.cornerRadius = 15
    }
    func configure(message: Message, currentUserId: String) {
            
            if message.senderId == currentUserId {
                // SHOW RIGHT BUBBLE (My message)
                rightBubbleView.isHidden = false
                rightMessageLabel.isHidden = false
                
                leftBubbleView.isHidden = true
                leftMessageLabel.isHidden = true
                
                rightMessageLabel.text = message.message

            } else {
                // SHOW LEFT BUBBLE (Other user's message)
                rightBubbleView.isHidden = true
                rightMessageLabel.isHidden = true
                
                leftBubbleView.isHidden = false
                leftMessageLabel.isHidden = false
                
                leftMessageLabel.text = message.message
            }
        }
    }
