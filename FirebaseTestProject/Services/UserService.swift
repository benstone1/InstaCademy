//
//  UserService.swift
//  UserService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct UserService {
    var auth = Auth.auth()
    var usersReference = Firestore.firestore().collection("users")
    
    func createAccount(name: String, email: String, password: String) async throws -> User {
        let response = try await auth.createUser(withEmail: email, password: password)
        let createdUser = User(name: name)
        try await usersReference.document(response.user.uid).setData(createdUser.jsonDict)
        return createdUser
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let response = try await auth.signIn(withEmail: email, password: password)
        guard let signedInUser = try await user(response.user.uid) else {
            preconditionFailure("Cannot find user \(response.user.uid) (email: \(email), password: \(password))")
        }
        return signedInUser
    }
    
    func currentUser() async throws -> User? {
        guard let uid = auth.currentUser?.uid else {
            return nil
        }
        guard let user = try await user(uid) else {
            preconditionFailure("Cannot find current user \(uid)")
        }
        return user
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    private func user(_ uid: String) async throws -> User? {
        let user = try await usersReference.document(uid).getDocument()
        guard let userData = user.data() else {
            return nil
        }
        return User(from: userData)
    }
}
