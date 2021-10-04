//
//  AuthService.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import FirebaseAuth
import FirebaseStorage
import UIKit

// MARK: - AuthServiceProtocol

protocol AuthServiceProtocol {
    func createAccount(name: String, email: String, password: String) async throws -> User
    func currentUser() -> User?
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
    func updateProfileImage(_ image: UIImage) async throws -> User
    func removeProfileImage() async throws -> User
}

// MARK: - AuthService

struct AuthService: AuthServiceProtocol {
    let auth = Auth.auth()
    let imageHelper = ImageStorageAdapter(namespace: "users")
    
    func createAccount(name: String, email: String, password: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        
        return User(from: result.user)
    }
    
    func currentUser() -> User? {
        if let user = auth.currentUser {
            return User(from: user)
        }
        return nil
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return User(from: result.user)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func updateProfileImage(_ image: UIImage) async throws -> User {
        guard let user = auth.currentUser else {
            preconditionFailure("Cannot update image because there is no signed in user")
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.photoURL = try await imageHelper.createImage(image, named: user.uid)
        try await changeRequest.commitChanges()
        
        let updatedUser = User(from: user)
        assert(changeRequest.photoURL != nil)
        assert(updatedUser.imageURL == changeRequest.photoURL)
        
        return User(from: user)
    }
    
    func removeProfileImage() async throws -> User {
        guard let user = auth.currentUser else {
            preconditionFailure("Cannot update image because there is no signed in user")
        }
        
        try await imageHelper.deleteImage(named: user.uid)
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.photoURL = nil
        try await changeRequest.commitChanges()
        
        let updatedUser = User(from: user)
        assert(changeRequest.photoURL == nil)
        assert(updatedUser.imageURL == changeRequest.photoURL)
        
        return User(from: user)
    }
}

private extension User {
    init(from user: FirebaseAuth.User) {
        self.id = user.uid
        self.name = user.displayName ?? "User \(user.uid)"
        self.imageURL = user.photoURL
    }
}
