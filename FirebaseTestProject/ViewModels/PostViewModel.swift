//
//  PostViewModel.swift
//  PostViewModel
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation
import UIKit

@MainActor class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    
    private let filter: PostFilter?
    private let postService: PostService
    
    init(user: User, filter: PostFilter? = nil) {
        self.filter = filter
        self.postService = PostService(user: user)
    }
    
    func loadPosts() {
        Task {
            await refreshPosts()
        }
    }
    
    func refreshPosts() async {
        do {
            posts = try await postService.fetchPosts(matching: filter)
        } catch {
            print("[PostViewModel] Cannot load posts: \(error.localizedDescription)")
        }
    }
    
    func commentViewModel(for post: Post) -> CommentViewModel {
        CommentViewModel(commentService: CommentService(post: post, postService: postService))
    }
    
    func createPost(title: String, content: String, image: UIImage?) async throws {
        let initialPost = Post(title: title, text: content, author: postService.user)
        let post = try await postService.create(initialPost, with: image)
        posts.insert(post, at: 0)
    }
    
    func deleteAction(for post: Post) -> (() async throws -> Void)? {
        guard postService.canDelete(post) else {
            return nil
        }
        return { [self] in
            try await postService.delete(post)
            posts.removeAll { $0.id == post.id }
        }
    }
    
    func favoriteAction(for post: Post) -> (() async throws -> Void) {
        return { [self] in
            if let i = posts.firstIndex(of: post) {
                posts[i].isFavorite = !post.isFavorite
            }
            try await (post.isFavorite ? postService.unfavorite(post) : postService.favorite(post))
        }
    }
}
