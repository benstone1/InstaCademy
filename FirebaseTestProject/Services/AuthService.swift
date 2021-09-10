//
//  AuthService.swift
//  AuthService
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
    func signOut() throws
    func updateProfileImage(_ image: UIImage) async throws -> User
}

// MARK: - AuthService

struct AuthService: AuthServiceProtocol {
    var auth = Auth.auth()
    var imagesReference = Storage.storage().reference().child("images/users")
    
    func createAccount(name: String, email: String, password: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        
        let profileUpdate = result.user.createProfileChangeRequest()
        profileUpdate.displayName = name
        try await profileUpdate.commitChanges()
        
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
        
        let imageReference = imagesReference.child("\(user.uid).jpg")
        let imageURL = try await imageReference.uploadImage(image)
        
        let profileUpdate = user.createProfileChangeRequest()
        profileUpdate.photoURL = imageURL
        try await profileUpdate.commitChanges()
        
        return User(from: user)
    }
}

private extension User {
    init(from user: FirebaseAuth.User) {
        id = user.uid
        name = user.displayName ?? "User \(user.uid)"
        imageURL = user.photoURL ?? imageURL
    }
}
