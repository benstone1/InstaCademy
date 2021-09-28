//
//  AuthService.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import Combine
import FirebaseAuth
import FirebaseStorage
import UIKit

// MARK: - AuthServiceProtocol

protocol AuthServiceProtocol {
    func currentUser() -> AnyPublisher<User?, Never>
    func createAccount(name: String, email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() async throws
    func updateProfileImage(_ image: UIImage) async throws
    func removeProfileImage() async throws
}

// MARK: - AuthService

struct AuthService: AuthServiceProtocol {
    var auth = Auth.auth()
    var imagesReference = Storage.storage().reference().child("images/users")
    
    func currentUser() -> AnyPublisher<User?, Never> {
        let publisher = CurrentValueSubject<FirebaseAuth.User?, Never>(auth.currentUser)
        let listener = auth.addIDTokenDidChangeListener { _, user in
            publisher.send(user)
        }
        return publisher
            .map { user in
                user.map { User(from: $0) }
            }
            .handleEvents(receiveCancel: { auth.removeIDTokenDidChangeListener(listener) })
            .eraseToAnyPublisher()
    }
    
    func createAccount(name: String, email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        
        try await result.user.updateProfile {
            $0.displayName = name
        }
    }
    
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func updateProfileImage(_ image: UIImage) async throws {
        guard let user = auth.currentUser else {
            preconditionFailure("Cannot update image because there is no signed in user")
        }
        
        let imageReference = imagesReference.child("\(user.uid).jpg")
        let imageURL = try await imageReference.uploadImage(image)
        
        try await user.updateProfile {
            $0.photoURL = imageURL
        }
    }
    
    func removeProfileImage() async throws {
        guard let user = auth.currentUser else {
            preconditionFailure("Cannot update image because there is no signed in user")
        }
        
        let imageReference = imagesReference.child("\(user.uid).jpg")
        try await imageReference.delete()
        
        try await user.updateProfile {
            $0.photoURL = nil
        }
    }
}

private extension FirebaseAuth.User {
    func updateProfile(_ performChanges: @escaping (UserProfileChangeRequest) -> Void) async throws {
        let changeRequest = createProfileChangeRequest()
        performChanges(changeRequest)
        try await changeRequest.commitChanges()
        
        // Refresh ID token. This tells the currentUser publisher to refresh, ensuring the user’s profile information is updated globally.
        try await getIDTokenResult(forcingRefresh: true)
    }
}

private extension User {
    init(from user: FirebaseAuth.User) {
        self.id = user.uid
        self.name = user.displayName ?? "User \(user.uid)"
        self.imageURL = user.photoURL
    }
}
