//
//  PostService.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

// MARK: - PostServiceProtocol

protocol PostServiceProtocol {
    var user: User { get }
    
    func fetchPosts() -> AnyPublisher<[Post], Error>
    func fetchPosts(by author: User) -> AnyPublisher<[Post], Error>
    func fetchFavoritePosts() -> AnyPublisher<[Post], Error>
    
    func create(_ editablePost: Post.EditableFields) async throws
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
    func fetchPosts(matching filter: PostFilter?) -> AnyPublisher<[Post], Error> {
        switch filter {
        case .none:
            return fetchPosts()
        case let .author(author):
            return fetchPosts(by: author)
        case .favorites:
            return fetchFavoritePosts()
        }
    }
}

// MARK: - PostService

struct PostService: PostServiceProtocol {
    let user: User
    var postsReference = Firestore.firestore().collection("posts")
    var favoritesReference = Firestore.firestore().collection("favorites")
    var imagesReference = Storage.storage().reference().child("images/posts")

    func fetchPosts() -> AnyPublisher<[Post], Error> {
        let postsQuery = postsReference.order(by: "timestamp", descending: true)
        return fetchPostsFromQuery(postsQuery)
    }

    func fetchPosts(by author: User) -> AnyPublisher<[Post], Error> {
        let postsQuery = postsReference
            .order(by: "timestamp", descending: true)
            .whereField("author.id", isEqualTo: author.id)
        return fetchPostsFromQuery(postsQuery)
    }
    
    func fetchFavoritePosts() -> AnyPublisher<[Post], Error> {
        return fetchFavorites()
            .flatMap { favorites -> AnyPublisher<[Post], Error> in
                if favorites.isEmpty {
                    return Just([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return postsReference
                    .order(by: "timestamp", descending: true)
                    .whereField("id", in: favorites)
                    .publishDocuments(as: Post.self)
            }
            .map { posts in
                posts.map { Post($0, isFavorite: true) }
            }
            .eraseToAnyPublisher()
    }
    
    func create(_ editablePost: Post.EditableFields) async throws {
        let postReference = postsReference.document()
        let imageURL: URL? = try await {
            guard let image = editablePost.image else { return nil }
            let imageReference = imagesReference.child("\(postReference.documentID).jpg")
            return try await imageReference.uploadImage(image)
        }()
        let post = Post(
            title: editablePost.title,
            content: editablePost.content,
            author: user,
            id: postReference.documentID,
            imageURL: imageURL
        )
        try postReference.setData(from: post)
    }
    
    func delete(_ post: Post) async throws {
        precondition(canDelete(post), "User not authorized to delete post")
        let postReference = postsReference.document(post.id)
        try await postReference.delete()
        
        guard post.imageURL != nil else { return }
        let imageReference = imagesReference.child("\(post.id).jpg")
        try await imageReference.delete()
    }
    
    func favorite(_ post: Post) async throws {
        let favorite = Favorite(postID: post.id, userID: user.id)
        try favoritesReference.document().setData(from: favorite)
    }
    
    func unfavorite(_ post: Post) async throws {
        let snapshot = try await favoritesReference
            .whereField("postID", isEqualTo: post.id)
            .whereField("userID", isEqualTo: user.id)
            .getDocuments()
        assert(snapshot.count == 1, "Expected 1 favorite reference but found \(snapshot.count)")
        guard let favoriteReference = snapshot.documents.first?.reference else { return }
        try await favoriteReference.delete()
    }
}

private extension PostService {
    func fetchPostsFromQuery(_ query: Query) -> AnyPublisher<[Post], Error> {
        let posts = query.publishDocuments(as: Post.self)
        let favorites = fetchFavorites()
        return posts.combineLatest(favorites) { posts, favorites in
            posts.map {
                Post($0, isFavorite: favorites.contains($0.id))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchFavorites() -> AnyPublisher<[Post.ID], Error> {
        return favoritesReference
            .whereField("userID", isEqualTo: user.id)
            .publishDocuments(as: Favorite.self)
            .map { $0.map(\.postID) }
            .eraseToAnyPublisher()
    }
    
    struct Favorite: Codable {
        let postID: Post.ID
        let userID: User.ID
    }
}

private extension Post {
    init(_ post: Post, isFavorite: Bool) {
        self.title = post.title
        self.content = post.content
        self.author = post.author
        self.id = post.id
        self.timestamp = post.timestamp
        self.imageURL = post.imageURL
        self.isFavorite = isFavorite
    }
}
