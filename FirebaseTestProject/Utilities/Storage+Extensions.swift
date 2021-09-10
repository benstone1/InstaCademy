//
//  Storage+Extensions.swift
//  Storage+Extensions
//
//  Created by John Royal on 9/10/21.
//

import FirebaseStorage
import UIKit

extension StorageReference {
    func uploadImage(_ image: UIImage) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            preconditionFailure("Cannot obtain JPEG data from image")
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        return try await downloadURL()
    }
}
