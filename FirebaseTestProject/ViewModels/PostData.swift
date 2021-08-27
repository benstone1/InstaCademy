//
//  PostData.swift
//  PostData
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

@MainActor class PostData: ObservableObject {
    @Published var posts: [Post] = []
    
    private let user: User
    
    init(user: User) {
        self.user = user
        
        Task {
            await loadPosts()
        }
    }
    
    func loadPosts() async {
        do {
            let posts = try await PostService.getPosts()
            self.posts = posts
        }
        catch {
            print(error)
        }
    }
    
    func deleteAction(for post: Post) -> (() async throws -> Void)? {
        guard post.author.id == user.id else {
            return nil
        }
        return {
            try await PostService.delete(post)
            self.posts.removeAll { $0 == post }
        }
    }
}
