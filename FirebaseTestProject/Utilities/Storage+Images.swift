//
//  Storage+Images.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/10/21.
//

import FirebaseStorage
import UIKit

struct ImageStorageAdapter {
    let namespace: String
    private let storage = Storage.storage().reference()
    
    func createImage(_ image: UIImage, named name: String) async throws -> URL {
        guard let imageData = image.pngData() else {
            fatalError("Cannot obtain PNG data from image")
        }
        let imageReference = imageReference(for: name)
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        try await imageReference.putData(imageData, metadata: metadata)
        return try await imageReference.downloadURL()
    }
    
    func deleteImage(named name: String) async throws {
        try await imageReference(for: name).delete()
    }
    
    private func imageReference(for name: String) -> StorageReference {
        storage.child("images/\(namespace)").child("\(name).png")
    }
}

private extension StorageReference {
    /// Asynchronously uploads data to the currently specified `StorageReference`. This is not recommended for large files, and one should instead upload a file from disk.
    ///
    /// This is an async wrapper for `putData(_:metadata:completion:)`.
    /// The compiler doesn’t synthesize this wrapper automatically because the completion handler is an optional type.
    ///
    /// - Parameter data: The data to upload.
    func putData(_ data: Data, metadata: StorageMetadata?) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            putData(data, metadata: metadata) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}
