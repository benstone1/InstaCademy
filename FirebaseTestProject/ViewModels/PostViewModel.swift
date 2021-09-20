//
//  PostViewModel.swift
//  PostViewModel
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

@MainActor class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var state: LoadingState = .loading
    
    private let postService: PostServiceProtocol
    private let filter: PostFilter?
    
    init(postService: PostServiceProtocol, filter: PostFilter? = nil) {
        self.postService = postService
        self.filter = filter
    }
    
    func loadPosts() {
        state = .loading
        Task {
            await refreshPosts()
        }
    }
    
    func refreshPosts() async {
        do {
            posts = try await postService.fetchPosts(matching: filter)
            state = .loaded
        } catch {
            print("[PostViewModel] Cannot load posts: \(error.localizedDescription)")
            state = .error
        }
    }
    
    func submitPost(_ editablePost: Post.EditableFields) async throws {
        let post = try await postService.create(editablePost)
        posts.insert(post, at: 0)
    }
    
    func deleteAction(for post: Post) -> (() async throws -> Void)? {
        guard postService.canDelete(post) else {
            return nil
        }
        return { [weak self] in
            guard let self = self else { return }
            try await self.postService.delete(post)
            self.posts.removeAll { $0.id == post.id }
        }
    }
    
    func favoriteAction(for post: Post) -> (() async throws -> Void) {
        return { [weak self] in
            guard let self = self,
                  let i = self.posts.firstIndex(of: post) else {
                      return
                  }
            if post.isFavorite {
                try await self.postService.unfavorite(post)
                self.posts[i].isFavorite = false
            } else {
                try await self.postService.favorite(post)
                self.posts[i].isFavorite = true
            }
        }
    }
}
