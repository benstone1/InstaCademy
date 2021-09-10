//
//  AuthViewModel.swift
//  AuthViewModel
//
//  Created by John Royal on 8/26/21.
//

import Foundation
import UIKit

@MainActor class AuthViewModel: ObservableObject {
    @Published var user: User?
    
    private let authService: AuthService
    
    init(authService: AuthService = AuthService()) {
        self.user = authService.currentUser()
        self.authService = authService
    }
    
    func createAccount(name: String, email: String, password: String) async throws {
        user = try await authService.createAccount(name: name, email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        user = try await authService.signIn(email: email, password: password)
    }
    
    func signOut() throws {
        try authService.signOut()
        user = nil
    }
    
    func updateProfileImage(_ image: UIImage) async throws {
        guard let currentUser = user else {
            preconditionFailure("Cannot update profile image because there is no authenticated user")
        }
        user = try await authService.updateProfileImage(image, for: currentUser)
    }
}
