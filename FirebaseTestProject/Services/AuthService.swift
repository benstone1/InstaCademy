//
//  AuthService.swift
//  AuthService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

struct AuthService {
    var auth = Auth.auth()
    var imagesReference = Storage.storage().reference().child("images/users")
    
    func createAccount(name: String, email: String, password: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        let user = User(id: result.user.uid, name: name)
        
        try await result.user.update {
            $0.displayName = user.name
        }
        
        return user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return User(from: result.user)
    }
    
    func currentUser() -> User? {
        guard let currentUser = auth.currentUser else {
            return nil
        }
        return User(from: currentUser)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func updateProfileImage(_ image: UIImage, for user: User) async throws -> User {
        guard let currentUser = auth.currentUser, currentUser.uid == user.id else {
            preconditionFailure("Cannot update image because there is no signed in user")
        }
        
        let imageReference = imagesReference.child("\(user.id).jpg")
        let imageURL = try await imageReference.uploadImage(image)
        
        try await currentUser.update {
            $0.photoURL = imageURL
        }
        
        return User(from: currentUser)
    }
}

private extension User {
    init(from user: FirebaseAuth.User) {
        id = user.uid
        name = user.displayName ?? "User \(user.uid)"
        imageURL = user.photoURL ?? imageURL
    }
}

private extension FirebaseAuth.User {
    func update(updateHandler: @escaping (UserProfileChangeRequest) -> Void) async throws {
        let profileChangeRequest = createProfileChangeRequest()
        updateHandler(profileChangeRequest)
        try await profileChangeRequest.commitChanges()
    }
}
