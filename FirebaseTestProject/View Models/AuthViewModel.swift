//
//  AuthViewModel.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/26/21.
//

import Foundation
import UIKit

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var error: Error?
    @Published var isLoading = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.user = authService.currentUser()
        self.authService = authService
    }
    
    func makeMainTabViewModel(user: User) -> MainTabViewModel {
        MainTabViewModel(user: user, authService: authService, postService: PostService(user: user))
    }
    
    func createAccount(name: String, email: String, password: String) {
        updateUserTask {
            return try await $0.createAccount(name: name, email: email, password: password)
        }
    }
    
    func signIn(email: String, password: String) {
        updateUserTask {
            return try await $0.signIn(email: email, password: password)
        }
    }
    
    func signOut() {
        updateUserTask {
            try await $0.signOut()
            return nil
        }
    }
    
    func updateProfileImage(_ image: UIImage) {
        updateUserTask {
            return try await $0.updateProfileImage(image)
        }
    }
    
    func removeProfileImage() {
        updateUserTask {
            return try await $0.removeProfileImage()
        }
    }
    
    private func updateUserTask(with action: @escaping (AuthServiceProtocol) async throws -> User?) {
        Task {
            isLoading = true
            do {
                user = try await action(authService)
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}
