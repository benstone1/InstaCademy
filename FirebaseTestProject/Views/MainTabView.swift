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
            
            ProfileView(user: viewModel.user)
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
        TabPreview(tab: .posts)
        TabPreview(tab: .favoritePosts)
        TabPreview(tab: .newPost)
        TabPreview(tab: .profile)
    }
    
    @MainActor
    private struct TabPreview: View {
        let tab: MainTabViewModel.Tab
        
        var body: some View {
            MainTabView(viewModel: MainTabViewModel(tab: tab))
                .environmentObject(AuthViewModel(authService: AuthServiceStub()))
        }
    }
}

private extension MainTabViewModel {
    convenience init(tab: Tab) {
        self.init(user: User.testUser(), authService: AuthServiceStub(), postService: PostServiceStub())
        self.tab = tab
    }
}
#endif
