//
//  SignInView.swift
//  SignInView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI

struct SignInView<CreateAccountView: View>: View {
    let action: (String, String) async throws -> Void
    let createAccountView: CreateAccountView
    
    @State private var email = ""
    @State private var password = ""
    @StateObject private var signInTask = TaskViewModel()
    
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
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.secondary)
                        .cornerRadius(15)
                        .textContentType(.newPassword)
                    HStack {
                        Button(action: signIn) {
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
            .onSubmit(signIn)
            .disabled(signInTask.isInProgress)
            .alert("Cannot Sign In", isPresented: $signInTask.isError, presenting: signInTask.error, actions: { _ in }) { error in
                Text(error.localizedDescription)
            }
        }
    }
    
    private func signIn() {
        signInTask.run {
            try await action(email, password)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(action: { _, _ in }, createAccountView: EmptyView())
    }
}
