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

struct UserService {
    var auth = Auth.auth()
    var usersReference = Firestore.firestore().collection("users")
    var imagesReference = Storage.storage().reference().child("images/users")
    var cache = Cache<User>(key: "user")
    
    func createAccount(name: String, email: String, password: String) async throws -> User {
        let response = try await auth.createUser(withEmail: email, password: password)
        let createdUser = User(name: name)
        try await usersReference.document(response.user.uid).setData(createdUser.jsonDict)
        cache.save(createdUser)
        return createdUser
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let response = try await auth.signIn(withEmail: email, password: password)
        guard let signedInUser = try await user(response.user.uid) else {
            preconditionFailure("Cannot find user \(response.user.uid) (email: \(email), password: \(password))")
        }
        cache.save(signedInUser)
        return signedInUser
    }
    
    func currentUser() -> User? {
        cache.load()
    }
    
    func currentUser() async throws -> User? {
        guard let uid = auth.currentUser?.uid else {
            return nil
        }
        guard let user = try await user(uid) else {
            preconditionFailure("Cannot find current user \(uid)")
        }
        cache.save(user)
        return user
    }
    
    func signOut() throws {
        try auth.signOut()
        cache.save(nil)
    }
    
    func updateImage(_ image: UIImage, for user: User) async throws -> User {
        guard let uid = auth.currentUser?.uid else {
            preconditionFailure("Cannot update image without an authenticated user")
        }
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            preconditionFailure("Cannot obtain JPEG data from image")
        }
        let userImageReference = imagesReference.child("\(uid).jpg")
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            userImageReference.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        var user = user
        user.imageURL = try await userImageReference.downloadURL().absoluteString
        try await usersReference.document(uid).updateData(["imageURL": user.imageURL])
        cache.save(user)
        return user
    }
    
    private func user(_ uid: String) async throws -> User? {
        let user = try await usersReference.document(uid).getDocument()
        guard let userData = user.data() else {
            return nil
        }
        return User(from: userData)
    }
    
    struct Cache<Record: Codable> {
        var key: String
        var defaults = UserDefaults.standard
        
        func load() -> Record? {
            if let data = defaults.data(forKey: key), let record = try? JSONDecoder().decode(Record.self, from: data) {
                return record
            }
            return nil
        }
        
        func save(_ record: Record?) {
            if let record = record, let data = try? JSONEncoder().encode(record) {
                defaults.set(data, forKey: key)
            } else {
                defaults.set(nil, forKey: key)
            }
        }
    }
}
