//
//  CommentService.swift
//  CommentService
//
//  Created by John Royal on 8/30/21.
//

import Foundation
import FirebaseFirestore

// MARK: - CommentServiceProtocol

protocol CommentServiceProtocol {
    var post: Post { get }
    var user: User { get }
    
    func fetchComments() async throws -> [Comment]
    
    func create(_ comment: Comment) async throws
    func delete(_ comment: Comment) async throws
    
    func canDelete(_ comment: Comment) -> Bool
}

extension CommentServiceProtocol {
    func canDelete(_ comment: Comment) -> Bool {
        [post.author.id, comment.author.id].contains(user.id)
    }
}

// MARK: - CommentService

struct CommentService: CommentServiceProtocol {
    let post: Post
    let user: User
    let commentsReference: CollectionReference
    
    init(post: Post, postService: PostService) {
        self.post = post
        self.user = postService.user
        
        let postReference = postService.postsReference.document(post.id.uuidString)
        self.commentsReference = postReference.collection("comments")
    }
    
    func fetchComments() async throws -> [Comment] {
        try await commentsReference.order(by: "timestamp", descending: true).getDocuments(as: Comment.self)
    }
    
    func create(_ comment: Comment) async throws {
        let commentReference = commentsReference.document(comment.id.uuidString)
        try await commentReference.setData(comment.jsonDict)
    }
    
    func delete(_ comment: Comment) async throws {
        precondition(canDelete(comment), "User not authorized to delete comment")
        let commentReference = commentsReference.document(comment.id.uuidString)
        try await commentReference.delete()
    }
}
