//
//  CommentService.swift
//  CommentService
//
//  Created by John Royal on 8/30/21.
//

import Foundation
import FirebaseFirestore

private let COMMENT_CHARACTER_LIMIT = 1000

struct CommentService {
    let post: Post
    let user: User
    let commentsReference: CollectionReference
    
    init(post: Post, postService: PostService) {
        self.post = post
        self.user = postService.user
        
        let postReference = postService.postsReference.document(post.id.uuidString)
        self.commentsReference = postReference.collection("comments")
    }
    
    func comments() async throws -> [Comment] {
        try await commentsReference.order(by: "timestamp", descending: true).getDocuments(as: Comment.self)
    }
    
    func create(_ comment: Comment) async throws {
        if comment.content.count > COMMENT_CHARACTER_LIMIT {
            throw CommentError.exceedsCharacterLimit
        }
        let commentReference = commentsReference.document(comment.id.uuidString)
        try await commentReference.setData(comment.jsonDict)
    }
    
    func delete(_ comment: Comment) async throws {
        precondition(isDeletable(comment), "User not authorized to delete comment")
        let commentReference = commentsReference.document(comment.id.uuidString)
        try await commentReference.delete()
    }
    
    func isDeletable(_ comment: Comment) -> Bool {
        [post.author.id, comment.author.id].contains(user.id)
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
