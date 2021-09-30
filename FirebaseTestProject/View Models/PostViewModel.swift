//
//  PostViewModel.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

@MainActor
class PostViewModel: ObservableObject {
    @Published var posts: Loadable<[Post]> = .loading
    
    var title: String {
        switch filter {
        case .none:
            return "Posts"
        case .favorites:
            return "Favorites"
        case let .author(author):
            return "\(author.name)’s Posts"
        }
    }
    
    private let postService: PostServiceProtocol
    private let filter: PostFilter?
    
    init(postService: PostServiceProtocol, filter: PostFilter? = nil) {
        self.postService = postService
        self.filter = filter
    }
    
    func loadPosts() {
        if posts.value == nil {
            posts = .loading
        }
        Task {
            do {
                posts = .loaded(try await postService.fetchPosts(matching: filter))
            } catch {
                print("[PostViewModel] Cannot load posts: \(error.localizedDescription)")
                posts = .error(error)
            }
        }
    }
    
    func makePostRowViewModel(for post: Post) -> PostRowViewModel {
        let favoriteAction = { [weak self] in
            guard let self = self else { return }
            
            try await post.isFavorite ? self.postService.unfavorite(post) : self.postService.favorite(post)
            
            if let i = self.posts.value?.firstIndex(of: post) {
                self.posts.value?[i].isFavorite = !post.isFavorite
            }
        }
        let deleteAction = { [weak self] in
            try await self?.postService.delete(post)
            self?.posts.value?.removeAll { $0.id == post.id }
        }
        
        return PostRowViewModel(
            post: post,
            postService: postService,
            favoriteAction: favoriteAction,
            deleteAction: postService.canDelete(post) ? deleteAction : nil
        )
    }
}
