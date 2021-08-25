//
//  CommentsViewModel.swift
//  CommentsViewModel
//
//  Created by John Royal on 8/21/21.
//

import Foundation

@MainActor class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var state: State = .loading
    
    enum State {
        case loading
        case error
        case loaded
    }
    
    private let post: Post
    private let user: User
    
    init(post: Post, user: User) {
        self.post = post
        self.user = user
    }
    
    func loadComments() {
        Task {
            do {
                state = .loading
                comments = try await PostService.fetchComments(for: post)
                state = .loaded
            } catch {
                print("[CommentsViewModel] Cannot load comments: \(error.localizedDescription)")
                state = .error
            }
        }
    }
    
    func submitComment(content: String) async throws {
        let comment = Comment(author: user, content: content)
        try await PostService.addComment(comment, to: post)
        comments.append(comment)
    }
    
    func deleteAction(for comment: Comment) -> (() async throws -> Void)? {
        guard [comment.author.id, post.author.id].contains(user.id) else {
            return nil
        }
        return { [weak self] in
            guard let self = self else { return }
            try await PostService.removeComment(comment, from: self.post)
            self.comments.removeAll { $0 == comment }
        }
    }
}
