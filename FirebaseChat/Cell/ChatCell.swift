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
        
                leftBubbleView.layer.cornerRadius = 12
                rightBubbleView.layer.cornerRadius = 12

                // WhatsApp style background colors
                leftBubbleView.backgroundColor = UIColor(white: 0.92, alpha: 1)      // Light gray
                //rightBubbleView.backgroundColor = UIColor(red: 0.20, green: 0.74, blue: 0.32, alpha: 1) // WhatsApp green
                
                leftBubbleView.clipsToBounds = true
                rightBubbleView.clipsToBounds = true
                
                leftMessageLabel.numberOfLines = 0
                rightMessageLabel.numberOfLines = 0
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
