//
//  MainTabView.swift
//  MainTabView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct MainTabView: View {
    let user: User
    let auth: AuthViewModel
    
    var body: some View {
        TabView {
            PostsList(viewModel: makePostViewModel())
                .tabItem {
                    Label("Posts", systemImage: "list.dash")
                }
            PostsList(viewModel: makePostViewModel(filter: .favorites))
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
            ProfileView(user: user, updateImageAction: auth.updateProfileImage(_:), signOutAction: auth.signOut)
                .tabItem {
                    Label("Profile", systemImage: "gear")
                }
        }
        .environment(\.user, user)
    }
    
    private func makePostViewModel(filter: PostFilter? = nil) -> PostViewModel {
        let postService = PostService(user: user)
        return PostViewModel(postService: postService, filter: filter)
    }
}

struct UserEnvironmentKey: EnvironmentKey {
    static let defaultValue = User.testUser
}

extension EnvironmentValues {
    var user: User {
        get { self[UserEnvironmentKey.self] }
        set { self[UserEnvironmentKey.self] = newValue }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(user: .testUser, auth: AuthViewModel())
    }
}
