//
//  MainTabView.swift
//  MainTabView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

@MainActor struct MainTabView: View {
    let auth: AuthViewModel
    
    @Environment(\.user) private var user
    
    var body: some View {
        TabView {
            PostsList.MainView(viewModel: makePostViewModel())
                .tabItem {
                    Label("Posts", systemImage: "list.dash")
                }
            PostsList.FavoritesView(viewModel: makePostViewModel(filter: .favorites))
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
            ProfileView(user: user, updateImageAction: auth.updateProfileImage(_:), signOutAction: auth.signOut)
                .tabItem {
                    Label("Profile", systemImage: "gear")
                }
        }
    }
    
    private func makePostViewModel(filter: PostFilter? = nil) -> PostViewModel {
        let postService = PostService(user: user)
        return PostViewModel(postService: postService, filter: filter)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(auth: AuthViewModel())
    }
}
