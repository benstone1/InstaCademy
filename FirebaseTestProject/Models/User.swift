//
//  User.swift
//  User
//
//  Created by John Royal on 8/21/21.
//

import Foundation

struct User: Equatable, FirebaseConvertable {
    let id: UUID
    var name: String
    
    init(id: UUID = .init(), name: String) {
        self.id = id
        self.name = name
    }
    
    static let testUser = User(name: "Jane Doe")
}
