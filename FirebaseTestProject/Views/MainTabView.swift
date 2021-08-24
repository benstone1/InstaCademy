//
//  MainTabView.swift
//  MainTabView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var userService = UserService()
    
    var body: some View {
        if let user = userService.user {
            authenticatedView(user)
        } else {
            unauthenticatedView
        }
    }
    
    private func authenticatedView(_ user: User) -> some View {
        TabView {
            PostsList()
                .tabItem {
                    Label("Posts", systemImage: "list.dash")
                }
            NewPostForm()
                .tabItem {
                    Label("New Post", systemImage: "plus.circle")
                }
            ProfileView(user: user, signOutAction: { try! userService.signOut() })
                .tabItem {
                    Label("Profile", systemImage: "gear")
                }
        }
        .environment(\.user, user)
    }
    
    private var unauthenticatedView: some View {
        SignInView(
            action: { email, password in
                try! await userService.signIn(email: email, password: password)
            },
            createAccountView: SignUpView(action: { email, password in
                try! await userService.createAccount(name: "", email: email, password: password)
            })
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
