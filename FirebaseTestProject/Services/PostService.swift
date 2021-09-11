//
//  PostService.swift
//  PostService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

// MARK: - PostServiceProtocol

protocol PostServiceProtocol {
    var user: User { get }
    
    func fetchPosts() async throws -> [Post]
    func fetchPosts(by author: User) async throws -> [Post]
    func fetchFavoritePosts() async throws -> [Post]
    
    func create(_ post: Post.Partial) async throws -> Post
    func delete(_ post: Post) async throws
    
    func favorite(_ post: Post) async throws
    func unfavorite(_ post: Post) async throws
    
    func canDelete(_ post: Post) -> Bool
}

extension PostServiceProtocol {
    func canDelete(_ post: Post) -> Bool {
        user.id == post.author.id
    }
}

// MARK: - PostFilter

enum PostFilter {
    case author(User)
    case favorites
}

extension PostServiceProtocol {
    func fetchPosts(matching filter: PostFilter?) async throws -> [Post] {
        switch filter {
        case .none:
            return try await fetchPosts()
        case let .author(author):
            return try await fetchPosts(by: author)
        case .favorites:
            return try await fetchFavoritePosts()
        }
    }
}

// MARK: - PostService

struct PostService: PostServiceProtocol {
    let user: User
    var postsReference = Firestore.firestore().collection("posts_v2")
    var favoritesReference = Firestore.firestore().collection("favorites")
    var imagesReference = Storage.storage().reference().child("images/posts")
    
    func fetchPosts() async throws -> [Post] {
        async let postsTask = postsReference
            .order(by: "timestamp", descending: true)
            .getDocuments(as: Post.self)
        
        let (posts, favorites) = try await (postsTask, favoritesTask)
        
        return posts.map {
            var post = $0
            post.isFavorite = favorites.contains($0.id)
            return post
        }
    }
    
    func fetchPosts(by author: User) async throws -> [Post] {
        async let postsTask = postsReference
            .order(by: "timestamp", descending: true)
            .whereField("author.id", isEqualTo: author.id)
            .getDocuments(as: Post.self)
        
        let (posts, favorites) = try await (postsTask, favoritesTask)
        
        return posts.map {
            var post = $0
            post.isFavorite = favorites.contains($0.id)
            return post
        }
    }
    
    func fetchFavoritePosts() async throws -> [Post] {
        let favorites = try await favoritesTask
        guard !favorites.isEmpty else { return [] }
        
        let posts = try await postsReference
            .order(by: "timestamp", descending: true)
            .whereField("id", in: favorites.map(\.uuidString))
            .getDocuments(as: Post.self)
        
        return posts.map {
            var post = $0
            post.isFavorite = true
            return post
        }
    }
    
    func create(_ post: Post.Partial) async throws -> Post {
        let id = UUID()
        let imageURL: URL? = try await {
            guard let image = post.image else { return nil }
            let imageReference = imagesReference.child("\(id.uuidString)/post.jpg")
            return try await imageReference.uploadImage(image)
        }()
        let post = Post(title: post.title, text: post.content, author: user, id: id, imageURL: imageURL)
        
        let postReference = postsReference.document(id.uuidString)
        try await postReference.setData(post.jsonDict)
        
        return post
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
        let snapshot = try await favoritesReference
            .whereField("postID", isEqualTo: post.id.uuidString)
            .whereField("userID", isEqualTo: user.id)
            .getDocuments()
        assert(snapshot.count == 1, "Expected 1 favorite reference but found \(snapshot.count)")
        guard let favoriteReference = snapshot.documents.first?.reference else { return }
        try await favoriteReference.delete()
    }
    
    private var favoritesTask: [Post.ID] {
        get async throws {
            try await favoritesReference
                .whereField("userID", isEqualTo: user.id)
                .getDocuments(as: Favorite.self)
                .map(\.postID)
        }
    }
    
    private struct Favorite: FirestoreConvertable {
        let postID: UUID
        let userID: String
    }
}
