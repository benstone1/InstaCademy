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
            MainTabView(user: user, auth: auth)
        } else {
            SignInView(
                action: auth.signIn(email:password:),
                createAccountView: SignUpView(action: auth.createAccount(name:email:password:))
            )
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
