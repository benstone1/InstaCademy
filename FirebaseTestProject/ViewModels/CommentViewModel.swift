//
//  CommentsViewModel.swift
//  CommentsViewModel
//
//  Created by John Royal on 8/21/21.
//

import Foundation

@MainActor class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var state: State = .loading
    
    enum State {
        case loading
        case error
        case loaded
    }
    
    private let commentService: CommentService
    
    init(commentService: CommentService) {
        self.commentService = commentService
    }
    
    func loadComments() {
        Task {
            do {
                state = .loading
                comments = try await commentService.comments()
                state = .loaded
            } catch {
                print("[CommentsViewModel] Cannot load comments: \(error.localizedDescription)")
                state = .error
            }
        }
    }
    
    func submitComment(content: String) async throws {
        let comment = Comment(author: commentService.user, content: content)
        try await commentService.create(comment)
        comments.append(comment)
    }
    
    func deleteAction(for comment: Comment) -> (() async throws -> Void)? {
        guard commentService.isDeletable(comment) else {
            return nil
        }
        return { [weak self] in
            guard let self = self else { return }
            try await self.commentService.delete(comment)
            self.comments.removeAll { $0 == comment }
        }
    }
}
