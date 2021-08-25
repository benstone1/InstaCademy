//
//  PostData.swift
//  PostData
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

@MainActor class PostData: ObservableObject {
    @Published var posts: [Post] = []
    
    init() {
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
    
    func index(of post: Post) -> Int? {
        for i in posts.indices {
            if posts[i].id == post.id {
                return i
            }
        }
        return nil
    }
    
    func remove(post: Post) {
        // Will the task stop if we exit the function, prior to deletion?
        Task {
            try await PostService.delete(post)
        }
        
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts.remove(at: index)
    }
}
