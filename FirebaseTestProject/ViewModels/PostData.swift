//
//  PostData.swift
//  PostData
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

@MainActor class PostData: ObservableObject {
    @Published var posts: [Post] = []
    
    private let postService: PostService
    
    init(user: User) {
        postService = .init(user: user)
        
        Task {
            await loadPosts()
        }
    }
    
    func loadPosts() async {
        do {
            let posts = try await postService.posts()
            self.posts = posts
        }
        catch {
            print(error)
        }
    }
    
    func favoriteAction(for post: Post) -> (() async throws -> Void) {
        return { [weak self] in
            guard let self = self else { return }
            try await (post.isFavorite ? self.unfavorite(post) : self.favorite(post))
        }
    }
    
    func deleteAction(for post: Post) -> (() async throws -> Void)? {
        guard post.author.id == postService.user.id else {
            return nil
        }
        return { [weak self] in
            try await self?.delete(post)
        }
    }
    
    private func favorite(_ post: Post) async throws {
        if let i = posts.firstIndex(of: post) {
            posts[i].isFavorite = true
        }
        try await postService.favorite(post)
    }
    
    private func unfavorite(_ post: Post) async throws {
        if let i = posts.firstIndex(of: post) {
            posts[i].isFavorite = false
        }
        try await postService.unfavorite(post)
    }
    
    private func delete(_ post: Post) async throws {
        try await postService.delete(post)
        posts.removeAll { $0.id == post.id }
    }
}
