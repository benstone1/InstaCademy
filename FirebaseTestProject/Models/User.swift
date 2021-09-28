//
//  User.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import Foundation

struct User: Identifiable, Hashable, Equatable, Codable {
    let id: String
    var name: String
    var imageURL: URL?
}
