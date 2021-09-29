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
    typealias Action = () async throws -> Void
    
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
    private let favoriteAction: Action
    private let deleteAction: Action?
    
    init(post: Post, postService: PostServiceProtocol, favoriteAction: @escaping Action, deleteAction: Action?) {
        self.post = post
        self.postService = postService
        self.favoriteAction = favoriteAction
        self.deleteAction = deleteAction
    }
    
    func canDelete() -> Bool {
        deleteAction != nil
    }
    
    func delete() {
        guard let deleteAction = deleteAction else {
            // To prevent this method from being called erroneously, views should use the canDelete() method to hide the delete button when the delete action is missing.
            preconditionFailure("Cannot delete post because no delete action was provided")
        }
        Task {
            do {
                try await deleteAction()
            } catch {
                self.error = error
            }
        }
    }
    
    func toggleFavorite() {
        Task {
            do {
                try await favoriteAction()
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
