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
    var usersReference = Firestore.firestore().collection("users_v2")
    var imagesReference = Storage.storage().reference().child("images/users")
    var cache = Cache<User>(key: "user")
    
    func createAccount(name: String, email: String, password: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        let user = User(id: result.user.uid, name: name)
        try await usersReference.document(user.id).setData(user.jsonDict)
        cache.save(user)
        return user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        guard let user = try await user(result.user.uid) else {
            preconditionFailure("Cannot find user \(result.user.uid) (email: \(email), password: \(password))")
        }
        cache.save(user)
        return user
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
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            preconditionFailure("Cannot obtain JPEG data from image")
        }
        let userImageReference = imagesReference.child("\(user.id).jpg")
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
        try await usersReference.document(user.id).updateData(["imageURL": user.imageURL])
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
