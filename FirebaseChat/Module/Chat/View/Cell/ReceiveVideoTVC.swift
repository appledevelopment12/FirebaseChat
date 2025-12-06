//
//  ReceiveVideoTVC.swift
//  FirebaseChat
//
//  Created by Rohit on 05/12/25.
//

import UIKit
import AVKit
import AVFoundation


class ReceiveVideoTVC: UITableViewCell {

   
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!

    var videoUrl: String = ""
    var onPlayTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        thumbnailImageView.layer.cornerRadius = 12
        thumbnailImageView.clipsToBounds = true

        playButton.addTarget(self,
                             action: #selector(playTapped),
                             for: .touchUpInside)
    }

    func configure(message: Message) {

        videoUrl = message.videoUrl

        // TIME
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        timeLabel.text = df.string(from: message.timestamp)

        // THUMBNAIL
        if let url = URL(string: videoUrl) {

            DispatchQueue.global().async { [self] in
                let thumbnail = generateVideoThumbnail(url: url)
                DispatchQueue.main.async {
                    self.thumbnailImageView.image = thumbnail
                }
            }
        }
    }


    func generateVideoThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true

        let time = CMTimeMake(value: 1, timescale: 2)

        if let cgImage = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    @objc func playTapped() {
        onPlayTapped?()
    }
}
