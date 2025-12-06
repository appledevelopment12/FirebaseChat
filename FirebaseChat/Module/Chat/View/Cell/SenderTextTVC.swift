//
//  SenderTextTVC.swift
//  FirebaseChat
//
//  Created by Rohit on 05/12/25.
//

import UIKit

class SenderTextTVC: UITableViewCell {

    
    @IBOutlet weak var rightBubbleView: UIView!
    @IBOutlet weak var rightMessageLabel: UILabel!
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
        rightMessageLabel.text = message.text
        if message.isRead {
                tickImageView.image = UIImage(named: "double_blue")     // ✅ read
            } else {
                tickImageView.image = UIImage(named: "double_grey")     // ✅ delivered
            }
       }
}
