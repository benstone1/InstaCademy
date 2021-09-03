//
//  SignUpView.swift
//  SignUpView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI

struct SignUpView: View {
    let action: (String, String, String) async throws -> Void
    
    @State private var authenticating = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @StateObject private var createAccountTask = TaskViewModel()
    
    var body: some View {
        if authenticating {
            ZStack {
                withAnimation(.none) {
                    content
                }
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.black)
                    .scaleEffect(2)
            }
        }
        else {
            content
        }
    }
    
    var content: some View {
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
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.secondary)
                    .cornerRadius(15)
                    .textContentType(.password)
                Button(action: createAccount) {
                    Text("Create Account")
                        .foregroundColor(Color.white)
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
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
        authenticating = true
        createAccountTask.run {
            try await action(name, email, password)
            authenticating = false
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(action: { _, _, _ in })
    }
}
