//
//  PostRowViewModel.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/22/21.
//

import Foundation

@MainActor
@dynamicMemberLookup
class PostRowViewModel: ObservableObject {
    subscript<T>(dynamicMember keyPath: KeyPath<Post, T>) -> T {
        post[keyPath: keyPath]
    }
    
    enum Route {
        case author, comments
    }
    
    @Published var route: Route?
    @Published var error: Error?
    @Published private var post: Post
    
    private let postService: PostServiceProtocol
    
    init(post: Post, postService: PostServiceProtocol) {
        self.post = post
        self.postService = postService
    }
    
    func canDelete() -> Bool {
        postService.canDelete(post)
    }
    
    func delete() {
        precondition(canDelete())
        Task {
            do {
                try await postService.delete(post)
            } catch {
                self.error = error
            }
        }
    }
    
    func toggleFavorite() {
        Task {
            do {
                post.isFavorite.toggle()
                try await post.isFavorite ? postService.favorite(post) : postService.unfavorite(post)
            } catch {
                self.error = error
            }
        }
    }
    
    func makeCommentViewModel() -> CommentViewModel {
        CommentViewModel(commentService: CommentService(post: post, user: postService.user))
    }
    
    func makePostViewModel() -> PostViewModel {
        PostViewModel(postService: postService, filter: .author(post.author))
    }
}
