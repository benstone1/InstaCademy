//
//  SignUpView.swift
//  SignUpView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @StateObject private var createAccountTask = TaskViewModel()
    
    var body: some View {
        VStack {
            Image("login")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            VStack {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.secondary)
                    .cornerRadius(15)
                    .textContentType(.name)
                TextField("Email Address", text: $email)
                    .padding()
                    .background(Color.secondary)
                    .cornerRadius(15)
                    .textContentType(.emailAddress)
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.secondary)
                    .cornerRadius(15)
                    .textContentType(.password)
                Button(action: createAccount) {
                    Text("Create Account")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                Divider()
                    .padding(.vertical)
                SignInWithAppleButton(.signUp) { request in
                    auth.configureAppleSignInRequest(request)
                } onCompletion: { result in
                    createAccountTask.run {
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
        .onSubmit(createAccount)
        .disabled(createAccountTask.isInProgress)
        .alert("Cannot Create Account", isPresented: $createAccountTask.isError, presenting: createAccountTask.error, actions: { _ in }) { error in
            Text(error.localizedDescription)
        }
    }
    
    private func createAccount() {
        createAccountTask.run {
            try await auth.createAccount(name: name, email: email, password: password)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
