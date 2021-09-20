//
//  Post.swift
//  Post
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation
import UIKit

// MARK: - Post

struct Post: Identifiable, Equatable {
    let title: String
    let content: String
    let author: User
    let id: String
    let timestamp: Date
    let imageURL: URL?
    var isFavorite = false
    
    init(title: String, content: String, author: User, id: String, timestamp: Date = Date(), imageURL: URL? = nil, isFavorite: Bool = false) {
        self.title = title
        self.content = content
        self.author = author
        self.id = id
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.isFavorite = isFavorite
    }
    
    func contains(_ string: String) -> Bool {
        let properties = [title, content, author.name].map { $0.lowercased() }
        let query = string.lowercased()
        
        let matches = properties.filter { $0.contains(query) }
        return !matches.isEmpty
    }
}

// MARK: - Codable

extension Post: Codable {
    enum CodingKeys: CodingKey {
        case title, content, author, id, timestamp, imageURL
    }
}

// MARK: - Test

extension Post {
    static let testPost = Post(
        title: "Lorem ipsum",
        content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        author: .testUser,
        id: "00000000000000000000",
        imageURL: URL(string: "https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80"),
        isFavorite: true
    )
}

// MARK: - Partial

extension Post {
    struct EditableFields {
        var title = ""
        var content = ""
        var image: UIImage?
    }
}
