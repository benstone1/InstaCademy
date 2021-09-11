//
//  MainTabView.swift
//  MainTabView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var auth = AuthViewModel()
    
    var body: some View {
        if let user = auth.user {
            authenticatedView(user)
        } else {
            unauthenticatedView
        }
    }
    
    private func authenticatedView(_ user: User) -> some View {
        TabView {
            PostsList(viewModel: makePostViewModel(user: user))
                .tabItem {
                    Label("Posts", systemImage: "list.dash")
                }
            PostsList(viewModel: makePostViewModel(user: user, filter: .favorites))
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
    
    private var unauthenticatedView: some View {
        SignInView(
            action: auth.signIn(email:password:),
            createAccountView: SignUpView(action: auth.createAccount(name:email:password:))
        )
    }
    
    private func makePostViewModel(user: User, filter: PostFilter? = nil) -> PostViewModel {
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
        MainTabView()
    }
}
