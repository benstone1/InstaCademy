//
//  PostViewModel.swift
//  PostViewModel
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation
import UIKit

private typealias PostLoader = () async throws -> [Post]

@MainActor class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    
    enum Filter {
        case favorites
    }
    
    private let postService: PostService
    private let postLoader: PostLoader
    
    init(filter: Filter? = .none, user: User) {
        postService = .init(user: user)
        postLoader = postService.postLoader(for: filter)
        
        Task {
            await loadPosts()
        }
    }
    
    func loadPosts() async {
        do {
            posts = try await postLoader()
        } catch {
            print(error)
        }
    }
    
    func commentViewModel(for post: Post) -> CommentViewModel {
        .init(commentService: .init(post: post, postService: postService))
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

private extension PostService {
    func postLoader(for filter: PostViewModel.Filter?) -> PostLoader {
        switch filter {
        case .none:
            return posts
        case .favorites:
            return favoritePosts
        }
    }
}
