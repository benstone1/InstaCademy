//
//  AppView.swift
//  AppView
//
//  Created by John Royal on 9/11/21.
//

import SwiftUI

struct AppView: View {
    @StateObject private var auth = AuthViewModel()
    
    var body: some View {
        if let user = auth.user {
            MainTabView(auth: auth)
                .environment(\.user, user)
        } else {
            SignInView(
                action: auth.signIn(email:password:),
                createAccountView: SignUpView(action: auth.createAccount(name:email:password:))
            )
        }
    }
}

// MARK: - EnvironmentValues

extension EnvironmentValues {
    var user: User {
        get { self[UserEnvironmentKey.self] }
        set { self[UserEnvironmentKey.self] = newValue }
    }
    
    private struct UserEnvironmentKey: EnvironmentKey {
        static let defaultValue = User.testUser
    }
}

// MARK: - Preview

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
