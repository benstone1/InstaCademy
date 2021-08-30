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
    let user: User
    var postsReference = Firestore.firestore().collection("posts_v1")
    var favoritesReference = Firestore.firestore().collection("favorites")
    var imagesReference = Storage.storage().reference().child("images/posts")
    
    private var postsQuery: Query {
        postsReference.order(by: "timestamp", descending: false)
    }
    private var favoritesQuery: Query {
        favoritesReference.whereField("userid", isEqualTo: user.id.uuidString)
    }
    
    func posts() async throws -> [Post] {
        var posts = try await postsQuery.getDocuments(as: Post.self)
        let favorites = try await favoritesQuery.getDocuments(as: Favorite.self).map(\.postid)
        for i in posts.indices where favorites.contains(posts[i].id) {
            posts[i].isFavorite = true
        }
        return posts
    }
    
    func favoritePosts() async throws -> [Post] {
        let favorites = try await favoritesQuery.getDocuments(as: Favorite.self).map(\.postid.uuidString)
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
            post.imageURL = try await postImageReference.downloadURL().absoluteString
        }
        try await postsReference.document(post.id.uuidString).setData(post.jsonDict)
    }

    func delete(_ post: Post) async throws {
        guard user.id == post.author.id else {
            preconditionFailure("Cannot delete post because the user is not the author")
        }
        try await postsReference.document(post.id.uuidString).delete()
    }

    func favorite(_ post: Post) async throws {
        let favorite = Favorite(postid: post.id, userid: user.id)
        try await favoritesReference.document(favorite.id.uuidString).setData(favorite.jsonDict)
    }

    func unfavorite(_ post: Post) async throws {
        let query = favoritesReference
            .whereField("postid", isEqualTo: post.id.uuidString)
            .whereField("userid", isEqualTo: user.id.uuidString)
        let snapshot = try await query.getDocuments()

        guard !snapshot.isEmpty else { return }

        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
}

private struct Favorite: Identifiable, FirebaseConvertable {
    let id: UUID
    let postid: UUID
    let userid: UUID
    
    init(id: UUID = .init(), postid: UUID, userid: UUID) {
        self.id = id
        self.postid = postid
        self.userid = userid
    }
}

private extension Query {
    func getDocuments<Model: FirebaseConvertable>(as modelType: Model.Type) async throws -> [Model] {
        let snapshot = try await getDocuments()
        return snapshot.documents.map { Model(from: $0.data()) }
    }
}
