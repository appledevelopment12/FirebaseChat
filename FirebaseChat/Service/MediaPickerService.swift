//
//  MediaPickerService.swift
//  FirebaseChat
//
//  Created by Rohit on 05/12/25.
//

import Foundation

//func downloadPDF(message: Message, completion: @escaping (Message) -> Void) {
//
//    guard let url = URL(string: message.documentUrl) else { return }
//
//    URLSession.shared.downloadTask(with: url) { tempUrl, response, error in
//
//        guard let tempUrl = tempUrl else { return }
//
//        // Create preview image from PDF first page
//        if let preview = self.generatePDFThumbnail(url: tempUrl) {
//
//            var updated = message
//            updated.localPreviewImage = preview
//            updated.isDownloaded = true
//
//            completion(updated)
//        }
//
//    }.resume()
//}
