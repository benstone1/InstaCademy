//
//  CommentsViewModel.swift
//  CommentsViewModel
//
//  Created by John Royal on 8/21/21.
//

import Foundation

@MainActor class CommentViewModel: ObservableObject {
    @Published var comments: Loadable<[Comment]> = .loading
    
    private let commentService: CommentServiceProtocol
    
    init(commentService: CommentServiceProtocol) {
        self.commentService = commentService
    }
    
    func loadComments() {
        comments = .loading
        Task {
            await refreshComments()
        }
    }
    
    func refreshComments() async {
        do {
            comments = .loaded(try await commentService.fetchComments())
        } catch {
            print("[CommentsViewModel] Cannot load comments: \(error.localizedDescription)")
            comments = .error
        }
    }
    
    func submitComment(_ comment: Comment.Partial) async throws {
        let comment = try await commentService.create(comment)
        comments.value?.append(comment)
    }
    
    func deleteAction(for comment: Comment) -> (() async throws -> Void)? {
        guard commentService.canDelete(comment) else {
            return nil
        }
        return { [weak self] in
            guard let self = self else { return }
            try await self.commentService.delete(comment)
            self.comments.value?.removeAll { $0 == comment }
        }
    }
}
