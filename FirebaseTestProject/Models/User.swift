//
//  User.swift
//  User
//
//  Created by John Royal on 8/21/21.
//

import Foundation

struct User: Equatable, FirebaseConvertable {
    let id: String
    var name: String
    var imageURL: URL {
        get {
            URL(string: imageURLString) ?? Bundle.main.url(forResource: "ProfileImagePlaceholder", withExtension: "png")!
        }
        set {
            imageURLString = newValue.absoluteString
        }
    }
    private var imageURLString = ""
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    static let testUser = User(id: "0000000000000000000000000000", name: "Jane Doe")
}
