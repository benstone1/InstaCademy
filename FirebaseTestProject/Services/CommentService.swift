//
//  CommentService.swift
//  CommentService
//
//  Created by John Royal on 8/30/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - CommentServiceProtocol

protocol CommentServiceProtocol {
    var post: Post { get }
    var user: User { get }
    
    func fetchComments() async throws -> [Comment]
    
    func create(_ editableComment: Comment.EditableFields) async throws -> Comment
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
    
    func fetchComments() async throws -> [Comment] {
        try await commentsReference.order(by: "timestamp", descending: true).getDocuments(as: Comment.self)
    }
    
    func create(_ editableComment: Comment.EditableFields) async throws -> Comment {
        let commentReference = commentsReference.document()
        let comment = Comment(
            content: editableComment.content,
            author: user,
            id: commentReference.documentID
        )
        try commentReference.setData(from: comment)
        return comment
    }
    
    func delete(_ comment: Comment) async throws {
        precondition(canDelete(comment), "User not authorized to delete comment")
        let commentReference = commentsReference.document(comment.id)
        try await commentReference.delete()
    }
}

extension CommentService {
    init(post: Post, user: User) {
        self.post = post
        self.user = user
        
        let postReference = PostService(user: user).postsReference.document(post.id)
        self.commentsReference = postReference.collection("comments")
    }
}
