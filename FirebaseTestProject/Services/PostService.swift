//
//  PostService.swift
//  PostService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseFirestore
import UIKit
import FirebaseStorage

struct PostService {
    static var postsReference: CollectionReference {
        let db = Firestore.firestore()
        return db.collection("posts_v1")
    }
    static var imagesReference: StorageReference {
        let storage = Storage.storage()
        return storage.reference().child("images/posts")
    }
    
    static func getPosts() async throws -> [Post] {
        let postsSnapshots = try await postsReference.getDocuments()
        let posts = postsSnapshots.documents.map { Post(from: $0.data()) }
        return posts
    }
    
    static func upload(_ post: Post, with image: UIImage?) async throws {
        var post = post
        if let image = image {
            post.imageURL = try await uploadImage(image, for: post)
        }
        try await postsReference.document(post.id.uuidString).setData(post.jsonDict)
    }
    
    static func delete(_ post: Post) async throws {
        try await postsReference.document(post.id.uuidString).delete()
    }
    
    private static func uploadImage(_ image: UIImage, for post: Post) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            preconditionFailure("Cannot obtain JPEG data from image")
        }
        let postImageReference = imagesReference.child("\(post.id.uuidString)/post.jpg")
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            postImageReference.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        return try await postImageReference.downloadURL().absoluteString
    }
}
