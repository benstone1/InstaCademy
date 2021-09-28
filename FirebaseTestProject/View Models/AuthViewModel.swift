//
//  AuthViewModel.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/26/21.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var error: Error?
    @Published var isLoading = false
    
    private let authService: AuthServiceProtocol
    private var cancellable: AnyCancellable?
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        
        cancellable = authService.currentUser()
            .assign(to: \.user, on: self)
    }
    
    func makeMainTabViewModel(user: User) -> MainTabViewModel {
        MainTabViewModel(user: user, authService: authService, postService: PostService(user: user))
    }
    
    func createAccount(name: String, email: String, password: String) {
        Task {
            isLoading = true
            do {
                try await authService.createAccount(name: name, email: email, password: password)
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    
    func signIn(email: String, password: String) {
        Task {
            isLoading = true
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}
