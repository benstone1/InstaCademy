//
//  PostService.swift
//  PostService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseFirestore

struct PostService {
    let user: User
    
    private var postsCollection: CollectionReference {
        Firestore.firestore().collection("posts_v1")
    }
    private var postsQuery: Query {
        postsCollection.order(by: "timestamp", descending: false)
    }
    private var favoritesCollection: CollectionReference {
        Firestore.firestore().collection("favorites")
    }
    private var favoritesQuery: Query {
        favoritesCollection.whereField("userid", isEqualTo: user.id.uuidString)
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

    func create(_ post: Post) async throws {
        try await postsCollection.document(post.id.uuidString).setData(post.jsonDict)
    }

    func delete(_ post: Post) async throws {
        guard user.id == post.author.id else {
            preconditionFailure("Cannot delete post because the user is not the author")
        }
        try await postsCollection.document(post.id.uuidString).delete()
    }

    func favorite(_ post: Post) async throws {
        let favorite = Favorite(postid: post.id, userid: user.id)
        try await favoritesCollection.document(favorite.id.uuidString).setData(favorite.jsonDict)
    }

    func unfavorite(_ post: Post) async throws {
        let query = favoritesCollection
            .whereField("postid", isEqualTo: post.id.uuidString)
            .whereField("userid", isEqualTo: user.id.uuidString)
        let snapshot = try await query.getDocuments()

        guard !snapshot.isEmpty else { return }

        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
}

extension PostService {
    private static let COMMENT_CHARACTER_LIMIT = 1000
    
    func fetchComments(for post: Post) async throws -> [Comment] {
        let post = postsCollection.document(post.id.uuidString)
        return try await post.collection("comments").getDocuments(as: Comment.self)
    }
    
    func addComment(_ comment: Comment, to post: Post) async throws {
        if comment.content.count > PostService.COMMENT_CHARACTER_LIMIT {
            throw CommentError.exceedsCharacterLimit
        }
        let post = postsCollection.document(post.id.uuidString)
        let comments = post.collection("comments")
        try await comments.document(comment.id.uuidString).setData(comment.jsonDict)
    }
    
    func removeComment(_ comment: Comment, from post: Post) async throws {
        let post = postsCollection.document(post.id.uuidString)
        let comment = post.collection("comments").document(comment.id.uuidString)
        try await comment.delete()
    }
    
    enum CommentError: LocalizedError {
        case exceedsCharacterLimit, unknown
        
        var errorDescription: String? {
            switch self {
            case .exceedsCharacterLimit:
                return "Cannot Post Comment"
            case .unknown:
                return "Error"
            }
        }
        
        var failureReason: String? {
            switch self {
            case .exceedsCharacterLimit:
                return "Your comment has more than \(COMMENT_CHARACTER_LIMIT) characters."
            case .unknown:
                return "Sorry, something went wrong."
            }
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
