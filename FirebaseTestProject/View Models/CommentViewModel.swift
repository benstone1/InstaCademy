//
//  CommentsViewModel.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import Foundation

@MainActor
class CommentViewModel: ObservableObject {
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
            print("[CommentViewModel] Cannot load comments: \(error.localizedDescription)")
            comments = .error(error)
        }
    }
    
    func makeCommentFormViewModel() -> CommentFormViewModel {
        return CommentFormViewModel(submitAction: { [weak self] editableComment in
            guard let self = self else { return }
            
            let comment = try await self.commentService.create(editableComment)
            self.comments.value?.append(comment)
        })
    }
    
    func makeCommentRowViewModel(for comment: Comment) -> CommentRowViewModel {
        let deleteAction: () async throws -> Void = { [weak self] in
            guard let self = self else { return }
            
            try await self.commentService.delete(comment)
            self.comments.value?.removeAll { $0.id == comment.id }
        }
        
        return CommentRowViewModel(
            comment: comment,
            deleteAction: commentService.canDelete(comment) ? deleteAction : nil
        )
    }
}
