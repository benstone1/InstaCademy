//
//  AuthView.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/27/21.
//

import SwiftUI

// MARK: - AuthView

struct AuthView: View {
    @StateObject var viewModel = AuthViewModel()
    
    var body: some View {
        if let user = viewModel.user {
            MainTabView(viewModel: viewModel.makeMainTabViewModel(user: user))
        } else {
            NavigationView {
                SignInView(createAccountView: CreateAccountView())
            }
            .environmentObject(viewModel)
        }
    }
}

// MARK: - SignInView

private extension AuthView {
    struct SignInView<CreateAccountView: View>: View {
        let createAccountView: CreateAccountView
        
        @State private var email = ""
        @State private var password = ""
        
        @EnvironmentObject private var viewModel: AuthViewModel
        
        var body: some View {
            AuthView.Form("Sign In") {
                viewModel.signIn(email: email, password: password)
            } fields: {
                TextField("Email Address", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                    .textContentType(.password)
            } footer: {
                NavigationLink("Create Account", destination: createAccountView)
            }
        }
    }
}

// MARK: - CreateAccountView

private extension AuthView {
    struct CreateAccountView: View {
        @State private var name = ""
        @State private var email = ""
        @State private var password = ""
        
        @EnvironmentObject private var viewModel: AuthViewModel
        
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            AuthView.Form("Create Account") {
                viewModel.createAccount(name: name, email: email, password: password)
            } fields: {
                TextField("Name", text: $name)
                    .textContentType(.name)
                TextField("Email Address", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                    .textContentType(.password)
            } footer: {
                Button("Sign In", action: {
                    dismiss()
                })
            }
        }
    }
}

// MARK: - Form

private extension AuthView {
    struct Form<Fields: View, Footer: View>: View {
        let title: String
        let action: () -> Void
        let fields: () -> Fields
        let footer: () -> Footer
        
        init(_ title: String, action: @escaping () -> Void, @ViewBuilder fields: @escaping () -> Fields, @ViewBuilder footer: @escaping () -> Footer) {
            self.title = title
            self.action = action
            self.fields = fields
            self.footer = footer
        }
        
        @EnvironmentObject private var viewModel: AuthViewModel
        
        var body: some View {
            VStack(alignment: .center) {
                Text("SocialCademy")
                    .bold()
                    .font(.title)
                Group(content: fields)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(15)
                Button(title, action: action)
                    .buttonStyle(.prominent)
                    .padding(.top)
                footer()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondary)
            }
            .onSubmit(action)
            .alert("Error", isPresented: $viewModel.error.exists, presenting: viewModel.error, actions: { _ in }) { error in
                Text(error.localizedDescription)
            }
            .padding()
            .background {
                Color.navy
                    .frame(height: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
            }
            .preferredColorScheme(.dark)
            .animation(.default, value: viewModel.isLoading)
            .disabled(viewModel.isLoading)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(viewModel: makeAuthViewModel())
            .previewDisplayName("Unauthenticated - Sign In")
        AuthView.CreateAccountView()
            .environmentObject(makeAuthViewModel())
            .previewDisplayName("Unauthenticated - Create Account")
        AuthView(viewModel: makeAuthViewModel(user: User.testUser()))
            .previewDisplayName("Authenticated")
    }
    
    private static func makeAuthViewModel(user: User? = nil) -> AuthViewModel {
        AuthViewModel(authService: AuthServiceStub(user: user))
    }
}
#endif
