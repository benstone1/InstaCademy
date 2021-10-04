//
//  Services+Preview.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/27/21.
//

import Foundation
import UIKit

// MARK: - AuthServiceStub

struct AuthServiceStub: AuthServiceProtocol {
    var user: User? = User.testUser()
    
    func createAccount(name: String, email: String, password: String) async throws -> User {
        user!
    }
    
    func currentUser() -> User? {
        user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        user!
    }
    
    func signOut() async throws {}
    
    func updateProfileImage(_ image: UIImage) async throws -> User {
        user!
    }
    
    func removeProfileImage() async throws -> User {
        user!
    }
}

// MARK: - CommentServiceStub

struct CommentServiceStub: CommentServiceProtocol {
    var state: Loadable<[Comment]> = .loaded(Comment.testComments)
    
    let post = Post.testPost()
    let user = User.testUser()
    
    func fetchComments() async throws -> [Comment] {
        return try await state.preview()
    }
    
    func create(_ editableComment: Comment.EditableFields) async throws -> Comment {
        return Comment.testComment()
    }
    
    func delete(_ comment: Comment) async throws {}
}

// MARK: - PostServiceStub

struct PostServiceStub: PostServiceProtocol {
    var state: Loadable<[Post]> = .loaded(Post.testPosts)
    
    let user = User.testUser()
    
    func fetchPosts() async throws -> [Post] {
        return try await state.preview()
    }
    
    func fetchPosts(by author: User) async throws -> [Post] {
        return try await state.preview()
    }
    
    func fetchFavoritePosts() async throws -> [Post] {
        return try await state.preview()
    }
    
    func create(_ editablePost: Post.EditableFields) async throws {}
    
    func delete(_ post: Post) async throws {}
    
    func favorite(_ post: Post) async throws {}
    
    func unfavorite(_ post: Post) async throws {}
}
