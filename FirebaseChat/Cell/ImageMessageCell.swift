import UIKit
import SDWebImage

class ImageMessageCell: UITableViewCell {

    @IBOutlet weak var leftBubbleView: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    
    @IBOutlet weak var rightBubbleView: UIView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    @IBOutlet weak var leftImageHeight: NSLayoutConstraint!
    @IBOutlet weak var rightImageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Bubble corners
        leftBubbleView.layer.cornerRadius = 16
        rightBubbleView.layer.cornerRadius = 16
        
        // Image corners
        leftImageView.layer.cornerRadius = 16
        rightImageView.layer.cornerRadius = 16
        
        leftImageView.clipsToBounds = true
        rightImageView.clipsToBounds = true
    }
    
    func configure(message: Message, currentUserId: String) {
        
        let isSender = message.senderId == currentUserId
        
        // Reset all views
        leftBubbleView.isHidden = true
        rightBubbleView.isHidden = true
        
        leftImageView.isHidden = true
        rightImageView.isHidden = true
        
        leftImageHeight.constant = 0
        rightImageHeight.constant = 0
        
        // Sender -> Right Bubble
        if isSender {
            rightBubbleView.isHidden = false
            rightImageView.isHidden = false
            
            rightImageHeight.constant = 200  // Set bubble height
            
            rightImageView.sd_setImage(
                with: URL(string: message.imageUrl),
                placeholderImage: UIImage(named: "placeholder")
            )
        }
        // Receiver -> Left Bubble
        else {
            leftBubbleView.isHidden = false
            leftImageView.isHidden = false
            
            leftImageHeight.constant = 200  // Set bubble height
            
            leftImageView.sd_setImage(
                with: URL(string: message.imageUrl),
                placeholderImage: UIImage(named: "placeholder")
            )
        }
        
        self.layoutIfNeeded()
    }
}
