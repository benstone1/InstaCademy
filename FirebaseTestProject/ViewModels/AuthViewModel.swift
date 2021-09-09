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
    
    private let userService: UserService
    
    init(userService: UserService = .init()) {
        self.user = userService.currentUser()
        self.userService = userService
    }
    
    func createAccount(name: String, email: String, password: String) async throws {
        user = try await userService.createAccount(name: name, email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        user = try await userService.signIn(email: email, password: password)
    }
    
    func signOut() throws {
        try userService.signOut()
        user = nil
    }
    
    func updateProfileImage(_ image: UIImage) async throws {
        guard let currentUser = user else {
            preconditionFailure("Cannot update profile image because there is no authenticated user")
        }
        user = try await userService.updateProfileImage(image, for: currentUser)
    }
}
