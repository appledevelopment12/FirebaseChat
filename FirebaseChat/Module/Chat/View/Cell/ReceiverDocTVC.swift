//
//  ReceiverDocTVC.swift
//  FirebaseChat
//
//  Created by Rohit on 05/12/25.
//

import UIKit

class ReceiverDocTVC: UITableViewCell {
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    
        var documentUrl = ""
        var onDownloadTapped: (() -> Void)?

        func configure(message: Message) {

            documentUrl = message.documentUrl
            fileNameLabel.text = message.fileName

            // BEFORE DOWNLOAD
            if message.isDownloaded == false {
                previewImageView.isHidden = true
                previewImageHeightConstraint.constant = 0

                // Tap to download
                let tap = UITapGestureRecognizer(target: self, action: #selector(downloadNow))
                self.addGestureRecognizer(tap)
            }
            // AFTER DOWNLOAD
            else {
                if let preview = message.localPreviewImage {
                    previewImageView.isHidden = false
                    previewImageView.image = preview
                    previewImageHeightConstraint.constant = 150   // DOUBLE HEIGHT 👈
                }
            }
          //  layoutIfNeeded()
        }

        @objc func downloadNow() {
            onDownloadTapped?()
        }
    }
