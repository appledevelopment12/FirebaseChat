//
//  ReceiverTextTVC.swift
//  FirebaseChat
//
//  Created by Rohit on 05/12/25.
//

import UIKit

class ReceiverTextTVC: UITableViewCell {

    @IBOutlet weak var leftBubbleView: UIView!
    @IBOutlet weak var leftMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(message: Message) {
        leftMessageLabel.text = message.text
       }
    

  }
