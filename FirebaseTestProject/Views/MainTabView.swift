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
        }
        .environment(\.user, user)
    }
    
    private var unauthenticatedView: some View {
        // TODO: Replace this with Tim’s authentication UI. This is a placeholder to facilitate the development of comments, which rely on there being an authenticated user.
        ProgressView()
            .onAppear {
                Task {
                    try! await userService.signIn(email: "A21-4@testuser.com", password: "password")
                }
            }
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
