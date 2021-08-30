//
//  User.swift
//  User
//
//  Created by John Royal on 8/21/21.
//

import Foundation

struct User: Equatable, FirebaseConvertable {
    let id: String
    var imageURL: String
    var name: String

    
    init(id: String, name: String, imageURL: String = "https://firebasestorage.googleapis.com/v0/b/instacademy-test1.appspot.com/o/images%2Fusers%2Fdefault_profile.png?alt=media&token=6700ffd7-2675-45ad-a197-bb2e4e307da7") {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
    static let testUser = User(id: UUID().uuidString, name: "Jane Doe")
}
