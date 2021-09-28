//
//  Services+Preview.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/27/21.
//

import Foundation
import Combine
import UIKit

// MARK: - AuthServiceStub

struct AuthServiceStub: AuthServiceProtocol {
    var user: User? = User.testUser()
    
    func currentUser() -> AnyPublisher<User?, Never> {
        Just(user).eraseToAnyPublisher()
    }
    
    func createAccount(name: String, email: String, password: String) async throws {}
    
    func signIn(email: String, password: String) async throws {}
    
    func signOut() async throws {}
    
    func updateProfileImage(_ image: UIImage) async throws {}
    
    func removeProfileImage() async throws {}
}

// MARK: - CommentServiceStub

struct CommentServiceStub: CommentServiceProtocol {
    var state: Loadable<[Comment]> = .loaded(Comment.testComments)
    
    let post = Post.testPost()
    let user = User.testUser()
    
    func fetchComments() -> AnyPublisher<[Comment], Error> {
        state.preview()
    }
    
    func create(_ editableComment: Comment.EditableFields) async throws {}
    
    func delete(_ comment: Comment) async throws {}
}

// MARK: - PostServiceStub

struct PostServiceStub: PostServiceProtocol {
    var state: Loadable<[Post]> = .loaded(Post.testPosts)
    
    let user = User.testUser()
    
    func fetchPosts() -> AnyPublisher<[Post], Error> {
        state.preview()
    }
    
    func fetchPosts(by author: User) -> AnyPublisher<[Post], Error> {
        state.preview()
    }
    
    func fetchFavoritePosts() -> AnyPublisher<[Post], Error> {
        state.preview()
    }
    
    func create(_ editablePost: Post.EditableFields) async throws {}
    
    func delete(_ post: Post) async throws {}
    
    func favorite(_ post: Post) async throws {}
    
    func unfavorite(_ post: Post) async throws {}
}
