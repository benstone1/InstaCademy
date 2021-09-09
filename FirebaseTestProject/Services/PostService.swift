//
//  PostService.swift
//  PostService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

struct PostService {
    let user: User
    var postsReference = Firestore.firestore().collection("posts_v2")
    var favoritesReference = Firestore.firestore().collection("favorites")
    var imagesReference = Storage.storage().reference().child("images/posts")
    
    private var postsQuery: Query {
        postsReference.order(by: "timestamp", descending: false)
    }
    private var favoritesQuery: Query {
        favoritesReference.whereField("userID", isEqualTo: user.id)
    }
    
    func posts() async throws -> [Post] {
        var posts = try await postsQuery.getDocuments(as: Post.self)
        let favorites = try await favoritesQuery.getDocuments(as: Favorite.self).map(\.postID)
        for i in posts.indices where favorites.contains(posts[i].id) {
            posts[i].isFavorite = true
        }
        return posts
    }
    
    func favoritePosts() async throws -> [Post] {
        let favorites = try await favoritesQuery.getDocuments(as: Favorite.self).map(\.postID.uuidString)
        guard !favorites.isEmpty else { return [] }
        var posts = try await postsQuery.whereField("id", in: favorites).getDocuments(as: Post.self)
        for i in posts.indices {
            posts[i].isFavorite = true
        }
        return posts
    }
    
    func create(_ post: Post, with image: UIImage?) async throws {
        var post = post
        if let image = image {
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
            post.imageURL = try await postImageReference.downloadURL()
        }
        let postReference = postsReference.document(post.id.uuidString)
        try await postReference.setData(post.jsonDict)
    }
    
    func canDelete(_ post: Post) -> Bool {
        user.id == post.author.id
    }
    
    func delete(_ post: Post) async throws {
        precondition(canDelete(post), "User not authorized to delete post")
        let postReference = postsReference.document(post.id.uuidString)
        try await postReference.delete()
    }
    
    func favorite(_ post: Post) async throws {
        let favorite = Favorite(postID: post.id, userID: user.id)
        try await favoritesReference.document().setData(favorite.jsonDict)
    }
    
    func unfavorite(_ post: Post) async throws {
        let query = favoritesReference
            .whereField("postID", isEqualTo: post.id.uuidString)
            .whereField("userID", isEqualTo: user.id)
        let snapshot = try await query.getDocuments()
        
        guard !snapshot.isEmpty else { return }
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
}

private struct Favorite: FirebaseConvertable {
    let postID: UUID
    let userID: String
}
