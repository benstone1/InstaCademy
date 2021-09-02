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
            PostsList(postData: .init(user: user))
                .tabItem {
                    Label("Posts", systemImage: "list.dash")
                }
            PostsList(postData: .init(filter: .favorites, user: user))
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
            NewPostForm()
                .tabItem {
                    Label("New Post", systemImage: "plus.circle")
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
