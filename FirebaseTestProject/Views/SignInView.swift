//
//  SignInView.swift
//  SignInView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI
import AuthenticationServices

struct SignInView<CreateAccountView: View>: View {
    let createAccountView: CreateAccountView
    @EnvironmentObject private var auth: AuthViewModel
    
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
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.secondary)
                        .cornerRadius(15)
                        .textContentType(.newPassword)
                    HStack {
                        Button(action: signIn) {
                            Text("Sign In")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color.white)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        NavigationLink("Create Account", destination: createAccountView)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    Divider()
                        .padding(.vertical)
                    SignInWithAppleButton { request in
                        auth.configureAppleSignInRequest(request)
                    } onCompletion: { result in
                        signInTask.run {
                            try await auth.signInWithApple(result)
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(15)
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
            try await auth.signIn(email: email, password: password)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(createAccountView: EmptyView())
            .environmentObject(AuthViewModel())
    }
}
