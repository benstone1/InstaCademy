//
//  CommentsViewModel.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import Combine

@MainActor
class CommentViewModel: ObservableObject {
    @Published var comments: Loadable<[Comment]> = .loading
    
    private let commentService: CommentServiceProtocol
    private var cancellable: AnyCancellable?
    
    init(commentService: CommentServiceProtocol) {
        self.commentService = commentService
    }
    
    func loadComments() {
        comments = .loading
        cancellable = commentService.fetchComments()
            .sink { [weak self] result in
                guard case let .failure(error) = result else { return }
                print("[CommentViewModel] Cannot load comments: \(error.localizedDescription)")
                self?.comments = .error(error)
            } receiveValue: { [weak self] comments in
                self?.comments = .loaded(comments)
            }
    }
    
    func makeCommentFormViewModel() -> CommentFormViewModel {
        CommentFormViewModel(submitAction: { [weak self] editableComment in
            try await self?.commentService.create(editableComment)
        })
    }
    
    func makeCommentRowViewModel(for comment: Comment) -> CommentRowViewModel {
        CommentRowViewModel(comment: comment, commentService: commentService)
    }
}
