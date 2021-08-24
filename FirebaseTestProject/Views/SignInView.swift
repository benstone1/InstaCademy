//
//  SignInView.swift
//  SignInView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI

struct SignInView<CreateAccountView: View>: View {
    let action: (String, String) async -> Void
    let createAccountView: CreateAccountView
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Image("login")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                VStack {
                    TextField("Email Address", text: $email)
                        .padding()
                        .background(Color.secondary)
                        .cornerRadius(15)
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.secondary)
                        .cornerRadius(15)
                    HStack {
                        Button {
                            guard !email.isEmpty, !password.isEmpty else {
                                return
                            }
                            Task {
                                await action(email, password)
                            }
                        } label: {
                            Text("Sign In")
                                .foregroundColor(Color.white)
                                .frame(width: 150, height: 50)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        NavigationLink("Create Account", destination: createAccountView)
                            .foregroundColor(Color.white)
                            .frame(width: 150, height: 50)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                }
                .padding()
                Spacer()
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(action: { _, _ in }, createAccountView: EmptyView())
    }
}
