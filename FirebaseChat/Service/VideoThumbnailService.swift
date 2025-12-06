//
//  VideoThumbnailService.swift
//  FirebaseChat
//
//  Created by Rohit on 05/12/25.
//

import Foundation

//func generatePDFThumbnail(url: URL) -> UIImage? {
//
//    guard let doc = CGPDFDocument(url as CFURL),
//          let page = doc.page(at: 1) else { return nil }
//
//    let pageRect = page.getBoxRect(.mediaBox)
//    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
//
//    return renderer.image { ctx in
//        UIColor.white.set()
//        ctx.fill(pageRect)
//        ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
//        ctx.cgContext.scaleBy(x: 1, y: -1)
//        ctx.cgContext.drawPDFPage(page)
//    }
//}
