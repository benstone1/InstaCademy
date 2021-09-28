//
//  ProfileViewModel.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/22/21.
//

import Foundation
import Combine
import UIKit

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isLoading = false
    @Published var error: Error?
    
    private let authService: AuthServiceProtocol
    private var cancellable: AnyCancellable?
    
    init(user: User, authService: AuthServiceProtocol) {
        self.user = user
        self.authService = authService
        
        refreshProfile()
    }
    
    private func refreshProfile() {
        if let cancellable = cancellable {
            cancellable.cancel()
        }
        cancellable = authService.currentUser()
            .replaceError(with: nil)
            .sink { [weak self] user in
                guard let user = user else { return }
                self?.user = user
            }
    }
    
    func signOut() {
        performTask { [weak self] in
            try await self?.authService.signOut()
        }
    }
    
    func updateProfileImage(_ image: UIImage) {
        performTask { [weak self] in
            try await self?.authService.updateProfileImage(image)
            self?.refreshProfile()
        }
    }
    
    private func performTask(action: @escaping () async throws -> Void) {
        Task {
            isLoading = true
            do {
                try await action()
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}
