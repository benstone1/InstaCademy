//
//  AuthViewModel.swift
//  AuthViewModel
//
//  Created by John Royal on 8/26/21.
//

import Foundation
import AuthenticationServices

@MainActor class AuthViewModel: ObservableObject {
    @Published var user: User?
    
    private let userService: UserService
    private var signInWithAppleNonce: String?
    
    init(userService: UserService = .init()) {
        self.user = userService.currentUser()
        self.userService = userService
        
        Task {
            user = try await userService.currentUser()
        }
    }
    
    func createAccount(name: String, email: String, password: String) async throws {
        user = try await userService.createAccount(name: name, email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        user = try await userService.signIn(email: email, password: password)
    }
    
    func configureAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        signInWithAppleNonce = userService.configureAppleSignInRequest(request)
    }
    
    func signInWithApple(_ result: Result<ASAuthorization, Error>) async throws {
        switch result {
        case let .success(authorization):
            guard let nonce = signInWithAppleNonce else {
                preconditionFailure("Completion handler for Sign in with Apple called with no nonce present")
            }
            user = try await userService.signInWithApple(authorization, nonce: nonce)
        case let .failure(error):
            if let error = error as? ASAuthorizationError, error.code == .canceled {
                return
            }
            throw error
        }
        signInWithAppleNonce = nil
    }
    
    func signOut() throws {
        try userService.signOut()
        user = nil
    }
}
