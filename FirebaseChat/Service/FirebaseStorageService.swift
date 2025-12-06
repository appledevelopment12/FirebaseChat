//
//  FirebaseStorageService.swift
//  FirebaseChat
//
//  Created by Rohit on 05/12/25.
//

import Foundation
import FirebaseStorage

final class FirebaseStorageService {

    private let storage = Storage.storage()

    func uploadFile(data: Data,
                    path: String,
                    contentType: String,
                    completion: @escaping (Result<String, Error>) -> Void) {

        let ref = storage.reference().child(path)
        let meta = StorageMetadata()
        meta.contentType = contentType

        ref.putData(data, metadata: meta) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(url!.absoluteString))
            }
        }
    }

    func uploadFile(from localUrl: URL,
                    path: String,
                    contentType: String,
                    completion: @escaping (Result<String, Error>) -> Void) {

        let ref = storage.reference().child(path)
        let meta = StorageMetadata()
        meta.contentType = contentType

        ref.putFile(from: localUrl, metadata: meta) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(url!.absoluteString))
            }
        }
    }
}
