//
//  CommentRowViewModel.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/23/21.
//

import Foundation

@MainActor
class CommentRowViewModel: ObservableObject {
    typealias DeleteAction = () async throws -> Void
    
    let authorName: String
    let timestamp: Date
    let content: String
    
    @Published var error: Error?
    
    private let comment: Comment
    private let deleteAction: DeleteAction?
    
    init(comment: Comment, deleteAction: DeleteAction?) {
        self.authorName = comment.author.name
        self.timestamp = comment.timestamp
        self.content = comment.content
        
        self.comment = comment
        self.deleteAction = deleteAction
    }
    
    func canDelete() -> Bool {
        deleteAction != nil
    }
    
    func delete() {
        precondition(canDelete())
        Task {
            do {
                try await deleteAction?()
            } catch {
                self.error = error
            }
        }
    }
}
