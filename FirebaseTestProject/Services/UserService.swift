//
//  UserService.swift
//  UserService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor class UserService: ObservableObject {
    @Published var user: User?
    
    private var auth = Auth.auth()
    private var users = Firestore.firestore().collection("users")
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
        let createdUser = User(name: name)
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
