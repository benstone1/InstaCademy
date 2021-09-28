//
//  User.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import Foundation

// MARK: - User

struct User: Identifiable, Hashable, Equatable, Codable {
    let id: String
    var name: String
    var imageURL: URL?
}

// MARK: - Preview Content

extension User {
    static func testUser(
        id: String = "00000000000000000000",
        name: String = "Jamie Harris",
        imageURL: URL? = URL(string: "https://source.unsplash.com/lw9LrnpUmWw/480x480")
    ) -> User {
        User(id: id, name: name, imageURL: imageURL)
    }
}
