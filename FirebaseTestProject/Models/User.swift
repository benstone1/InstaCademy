//
//  User.swift
//  User
//
//  Created by John Royal on 8/21/21.
//

import Foundation

// MARK: - User

struct User: Identifiable, Equatable, FirestoreConvertable {
    let id: String
    var name: String
    var imageURL: URL? {
        get {
            URL(string: imageURLString)
        }
        set {
            imageURLString = newValue?.absoluteString ?? ""
        }
    }
    
    private var imageURLString = ""
    
    init(id: String, name: String, imageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}

// MARK: - Test

extension User {
    static let testUser = User(
        id: "0000000000000000000000000000",
        name: "Jamie Harris",
        imageURL: URL(string: "https://images.unsplash.com/photo-1578916045370-25461e0cf390?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1288&q=80")
    )
}
