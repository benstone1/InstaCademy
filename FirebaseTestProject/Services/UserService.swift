//
//  UserService.swift
//  UserService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

@MainActor class UserService: ObservableObject {
    @Published var user: User?
    
    private var auth = Auth.auth()
    private var usersReference = Firestore.firestore().collection("users")
    private var imagesReference = Storage.storage().reference().child("images/users")
    private var listener: AuthStateDidChangeListenerHandle?
    
    init() {
        Task {
            user = try? await currentUser()
        }
        listener = auth.addStateDidChangeListener { _, _ in
            Task { [weak self] in
                guard let self = self else { return }
                self.user = try? await self.currentUser()
            }
        }
    }
    
    func createAccount(name: String, email: String, password: String) async throws {
        let response = try await auth.createUser(withEmail: email, password: password)
        let createdUser = User(id: response.user.uid, name: name)
        try await usersReference.document(response.user.uid).setData(createdUser.jsonDict)
        user = createdUser
    }
    
    func signIn(email: String, password: String) async throws {
        let response = try await auth.signIn(withEmail: email, password: password)
        guard let signedInUser = try await user(response.user.uid) else {
            preconditionFailure("Cannot find user \(response.user.uid) (email: \(email), password: \(password))")
        }
        user = signedInUser
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func updateImage(_ image: UIImage) async throws {
        guard let id = auth.currentUser?.uid else {
            preconditionFailure("Cannot update image without an authenticated user")
        }
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            preconditionFailure("Cannot obtain JPEG data from image")
        }
        let userImageReference = imagesReference.child("\(id).jpg")
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            userImageReference.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        let imageURL = try await userImageReference.downloadURL().absoluteString
        try await usersReference.document(id).updateData(["imageURL": imageURL])
        
        // Without async dispatch, update is sent from background thread and does not propagate to views. This is almost surely a bug.
        DispatchQueue.main.async { [weak self] in
            self?.user?.imageURL = imageURL
        }
    }
}

private extension UserService {
    func currentUser() async throws -> User? {
        guard let uid = auth.currentUser?.uid else {
            return nil
        }
        guard let user = try await user(uid) else {
            preconditionFailure("Cannot find current user \(uid)")
        }
        return user
    }
    
    func user(_ uid: String) async throws -> User? {
        let user = try await usersReference.document(uid).getDocument()
        guard let userData = user.data() else {
            return nil
        }
        return User(from: userData)
    }
}
