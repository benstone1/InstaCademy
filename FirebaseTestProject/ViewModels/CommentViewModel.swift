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
    
    private let post: Post
    private let user: User
    private let postService: PostService
    
    init(post: Post, user: User) {
        self.post = post
        self.user = user
        self.postService = .init(user: user)
    }
    
    func loadComments() {
        Task {
            do {
                state = .loading
                comments = try await postService.fetchComments(for: post)
                state = .loaded
            } catch {
                print("[CommentsViewModel] Cannot load comments: \(error.localizedDescription)")
                state = .error
            }
        }
    }
    
    func submitComment(content: String) async throws {
        let comment = Comment(author: user, content: content)
        try await postService.addComment(comment, to: post)
        comments.append(comment)
    }
    
    func deleteAction(for comment: Comment) -> (() async throws -> Void)? {
        guard [comment.author.id, post.author.id].contains(user.id) else {
            return nil
        }
        return { [weak self] in
            guard let self = self else { return }
            try await self.postService.removeComment(comment, from: self.post)
            self.comments.removeAll { $0 == comment }
        }
    }
}
