//
//  UserService.swift
//  UserService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import CryptoKit

// MARK: - UserService

struct UserService {
    var auth = Auth.auth()
    var usersReference = Firestore.firestore().collection("users")
    var cache = Cache<User>(key: "user")
    
    // MARK: Create Account
    
    func createAccount(name: String, email: String, password: String) async throws -> User {
        let response = try await auth.createUser(withEmail: email, password: password)
        let createdUser = User(name: name)
        try await usersReference.document(response.user.uid).setData(createdUser.jsonDict)
        cache.save(createdUser)
        return createdUser
    }
    
    // MARK: Sign In
    
    func signIn(email: String, password: String) async throws -> User {
        let response = try await auth.signIn(withEmail: email, password: password)
        guard let signedInUser = try await user(response.user.uid) else {
            preconditionFailure("Cannot find user \(response.user.uid) (email: \(email), password: \(password))")
        }
        cache.save(signedInUser)
        return signedInUser
    }
    
    func configureAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        let nonce = Crypto.nonceString(length: 32)
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = Crypto.sha256(nonce)
        
        return nonce
    }
    
    func signInWithApple(_ authorization: ASAuthorization, nonce: String) async throws -> User {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleIDCredential.identityToken,
              let idToken = String(data: idTokenData, encoding: .utf8) else {
                  preconditionFailure()
              }
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: nonce)
        let response = try await auth.signIn(with: credential)
        
        let userReference = usersReference.document(response.user.uid)
        let userSnapshot = try await userReference.getDocument()
        
        if userSnapshot.exists, let userData = userSnapshot.data() {
            let user = User(from: userData)
            cache.save(user)
            return user
        }
        
        let name = appleIDCredential.fullName?.formatted() ?? ""
        let user = User(name: name)
        try await userReference.setData(user.jsonDict)
        cache.save(user)
        return user
    }
    
    // MARK: Sign Out
    
    func signOut() throws {
        try auth.signOut()
        cache.save(nil)
    }
    
    // MARK: Current User
    
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
    
    private func user(_ uid: String) async throws -> User? {
        let user = try await usersReference.document(uid).getDocument()
        guard let userData = user.data() else {
            return nil
        }
        return User(from: userData)
    }
}

// MARK: - Cache

extension UserService {
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

// MARK: - Crypto

private enum Crypto {
    static func nonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }
            .joined()
        return hashString
    }
}
