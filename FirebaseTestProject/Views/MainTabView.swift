//
//  MainTabView.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

// MARK: - MainTabView

@MainActor
struct MainTabView: View {
    @StateObject var viewModel: MainTabViewModel
    
    private typealias Tab = MainTabViewModel.Tab
    
    var body: some View {
        TabView(selection: $viewModel.tab) {
            PostsList.withNavigationView(viewModel: viewModel.makePostViewModel())
                .tabItem {
                    Label("Posts", systemImage: "list.dash")
                }
                .tag(Tab.posts)
            
            PostsList.withNavigationView(viewModel: viewModel.makePostViewModel(filter: .favorites))
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .tag(Tab.favoritePosts)
            
            NewPostForm(viewModel: viewModel.makePostFormViewModel())
                .tabItem {
                    Label("New Post", systemImage: "square.and.pencil")
                }
                .tag(Tab.newPost)
            
            ProfileView(viewModel: viewModel.makeProfileViewModel())
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(viewModel: MainTabViewModel(user: User.testUser(), authService: AuthService(), postService: PostService(user: User.testUser())))
    }
}
#endif
