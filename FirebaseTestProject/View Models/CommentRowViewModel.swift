//
//  CommentRowViewModel.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/23/21.
//

import Foundation

@MainActor
class CommentRowViewModel: ObservableObject {
    let authorName: String
    let timestamp: Date
    let content: String
    
    @Published var error: Error?
    
    private let comment: Comment
    private let commentService: CommentServiceProtocol
    
    init(comment: Comment, commentService: CommentServiceProtocol) {
        self.authorName = comment.author.name
        self.timestamp = comment.timestamp
        self.content = comment.content
        
        self.comment = comment
        self.commentService = commentService
    }
    
    func canDelete() -> Bool {
        commentService.canDelete(comment)
    }
    
    func delete() {
        precondition(canDelete())
        Task {
            do {
                try await commentService.delete(comment)
            } catch {
                self.error = error
            }
        }
    }
}
