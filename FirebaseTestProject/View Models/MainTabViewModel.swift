//
//  MainTabViewModel.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/22/21.
//

import Foundation

@MainActor
class MainTabViewModel: ObservableObject {
    enum Tab {
        case posts, favoritePosts, newPost, profile
    }
    
    @Published var tab = Tab.posts
    @Published var user: User
    
    private let authService: AuthServiceProtocol
    private let postService: PostServiceProtocol
    
    init(user: User, authService: AuthServiceProtocol, postService: PostServiceProtocol) {
        self.user = user
        self.authService = authService
        self.postService = postService
    }
    
    func makePostViewModel(filter: PostFilter? = nil) -> PostViewModel {
        PostViewModel(postService: postService, filter: filter)
    }
    
    func makePostFormViewModel() -> PostFormViewModel {
        PostFormViewModel(submitAction: { [weak self] editablePost in
            try await self?.postService.create(editablePost)
            self?.tab = .posts // Display post after creating it
        })
    }
}
