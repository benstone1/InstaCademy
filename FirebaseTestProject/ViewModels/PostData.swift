//
//  PostData.swift
//  PostData
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

@MainActor class PostData: ObservableObject {
    @Published var posts: [Post] = []
    @Published var favorites: [Post] = []
    
    init() {
        Task {
            await loadPosts()
            await loadFavorites()
            
            // Set Post.isFavorite for all favorited posts
            let favoritesID = favorites.map({ $0.id })
            for i in 0..<posts.count {
                if favoritesID.contains(posts[i].id) {
                    posts[i].isFavorite = true
                }
            }
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
    
    func loadFavorites() async {
        do {
            let favorites = try await PostService.getFavorites()
            self.favorites = favorites
        }
        catch {
            print(error)
        }
    }
    
    func remove(post: Post) {
        Task {
            try await PostService.delete(post: post)
        }
        
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts.remove(at: index)
        
        // If is a favorite, we remove it as well. If not, it returns
        guard let index = favorites.firstIndex(where: { $0.id == post.id }) else { return }
        favorites.remove(at: index)
    }
}
