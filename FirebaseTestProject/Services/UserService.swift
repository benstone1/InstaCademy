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
    private var users = Firestore.firestore().collection("users")
    static var usersReference: CollectionReference {
        let db = Firestore.firestore()
        return db.collection("users")
    }
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
        try await users.document(response.user.uid).setData(createdUser.jsonDict)
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
    static func updateURL(_ user: User, imageURL: String) {
//        usersReference.document(user.id).setValue(imageURL, forKey: "imageURL")
        usersReference.document(user.id).updateData(["imageURL": imageURL])
//        usersReference.child(user.id).setValue(["imageURL": imageURL])
    }
    
    static var imagesRef: StorageReference {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        return storageRef.child("images/users")
    }
    
    static func uploadPhoto(_ user: User, image: UIImage) async -> String{
        let postImageRef = imagesRef.child("\(user.id).jpg")
        var imageURL = ""
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            // withCheckedContinuation creates an async function out of the putData completion handler
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                postImageRef.putData(imageData, metadata: nil) { metadata, error in
                    continuation.resume()
                }
            }
        }
        do {
            imageURL = try await postImageRef.downloadURL().absoluteString
            try await usersReference.document(user.id).updateData(["imageURL": imageURL])
            return imageURL
        } catch {
            print("There was an error obtaining the download URL: \(error)")
        }
        return imageURL
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
        let user = try await users.document(uid).getDocument()
        guard let userData = user.data() else {
            return nil
        }
        return User(from: userData)
    }
}
