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
    static var imagesRef: StorageReference {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        return storageRef.child("images/posts")
    }
    
    static func getPosts() async throws -> [Post] {
        let postsSnapshots = try await postsReference.getDocuments()
        let posts = postsSnapshots.documents.map { Post(from: $0.data()) }
        return posts
    }
    
    static func upload(_ post: Post) async throws {
        try await postsReference.document(post.id.uuidString).setData(post.jsonDict)
    }
    
    static func delete(_ post: Post) async throws {
        try await postsReference.document(post.id.uuidString).delete()
    }
    static func uploadPhoto(_ postID: UUID, image: UIImage) async -> String {
        let postImageRef = imagesRef.child("\(postID.uuidString)/post.jpg")
        var imageURL = ""
        
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            // withCheckedContinuation creates an async function out of the putData completion handler
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                postImageRef.putData(imageData, metadata: nil) { metadata, error in
                    continuation.resume()
                }
            }
        }
        do {
            imageURL = try await postImageRef.downloadURL().absoluteString
        } catch {
            print("There was an error obtaining the download URL: \(error)")
        }
        return imageURL
    }
}
