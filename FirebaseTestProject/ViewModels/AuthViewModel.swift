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
    
    func signOut() throws {
        try userService.signOut()
        user = nil
    }
    
    func updateImage(_ image: UIImage) async throws {
        user = try await userService.updateImage(image, for: user!)
    }
}
