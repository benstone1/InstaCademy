//
//  PostViewModel.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation
import Combine

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
    private var cancellable: AnyCancellable?
    
    init(postService: PostServiceProtocol, filter: PostFilter? = nil) {
        self.postService = postService
        self.filter = filter
    }
    
    func loadPosts() {
        posts = .loading
        cancellable = postService.fetchPosts(matching: filter)
            .sink { [weak self] result in
                guard case let .failure(error) = result else { return }
                print("[PostViewModel] Cannot load posts: \(error.localizedDescription)")
                self?.posts = .error(error)
            } receiveValue: { [weak self] posts in
                self?.posts = .loaded(posts)
            }
    }
    
    func makePostRowViewModel(for post: Post) -> PostRowViewModel {
        PostRowViewModel(post: post, postService: postService)
    }
}
