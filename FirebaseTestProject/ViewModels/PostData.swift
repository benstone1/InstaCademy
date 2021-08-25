//
//  PostData.swift
//  PostData
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

@MainActor class PostData: ObservableObject {
    @Published var posts: [Post] = []
    @Published var favorites: [Favorite] = []
    
    init() {
        Task {
            await loadPosts()
            await loadFavorites()
            
            // Set Post.isFavorite for all favorited posts
            let favoritesID = favorites.map({ $0.postid })
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
    func index(of post: Post) -> Int? {
        for i in posts.indices {
            if posts[i].id == post.id {
                return i
            }
        }
        return nil
    }
    
    func remove(post: Post) {
        Task {
            try await PostService.delete(post)
        }
        
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts.remove(at: index)
        
        // If is a favorite, we remove it as well. If not, it returns
        unfavorite(post)
    }
    
    func favorite(_ post: Post) {
        let userid = UserDefaults.standard.value(forKey: "userid") as? String ?? "00854E9E-8468-421D-8AA2-605D8E6C61D9"
        let favorite = Favorite(postid: post.id.uuidString, userid: userid)
        favorites.append(favorite)
        
        Task {
            try await PostService.favorite(favorite)
        }
    }
    
    func unfavorite(_ post: Post) {
        guard let index = favorites.firstIndex(where: { $0.postid == post.id }) else { return }
        let favorite = favorites[index]
        favorites.remove(at: index)
        
        Task {
            try await PostService.unfavorite(favorite)
        }
    }
}
