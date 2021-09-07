//
//  PostData.swift
//  PostData
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

private typealias PostLoader = () async throws -> [Post]

@MainActor class PostData: ObservableObject {
    @Published var posts: [Post] = []
    
    private let postService: PostService
    private let postLoader: PostLoader
    
    init(filter: Filter? = .none, user: User) {
        postService = .init(user: user)
        postLoader = postService.postLoader(for: filter)
        
        
        Task {
            await loadPosts()
        }
    }
    
    enum Filter {
        case favorites
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
    
    func favoriteAction(for post: Post) -> (() async throws -> Void) {
        return { [self] in
            if let i = posts.firstIndex(of: post) {
                posts[i].isFavorite = !post.isFavorite
            }
            try await (post.isFavorite ? postService.unfavorite(post) : postService.favorite(post))
        }
    }
    
    func deleteAction(for post: Post) -> (() async throws -> Void)? {
        guard post.author.id == postService.user.id else {
            return nil
        }
        return { [self] in
            try await postService.delete(post)
            posts.removeAll { $0.id == post.id }
        }
    }
}

private extension PostService {
    func postLoader(for filter: PostData.Filter?) -> PostLoader {
        switch filter {
        case .none:
            return posts
        case .favorites:
            return favoritePosts
        }
    }
}
