//
//  Post.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation
import UIKit

// MARK: - Post

struct Post: Identifiable, Hashable, Equatable {
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

// MARK: - Preview Content

extension Post {
    static func testPost(
        title: String = "Lorem ipsum",
        content: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        author: User = User.testUser(),
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        imageURL: URL? = URL(string: "https://source.unsplash.com/eOpewngf68w/800x800"),
        isFavorite: Bool = false
    ) -> Post {
        Post(title: title, content: content, author: author, id: id, timestamp: timestamp, imageURL: imageURL, isFavorite: isFavorite)
    }
}

// MARK: - Codable

extension Post: Codable {
    enum CodingKeys: CodingKey {
        case title, content, author, id, timestamp, imageURL
    }
}

// MARK: - Partial

extension Post {
    struct EditableFields {
        var title = ""
        var content = ""
        var image: UIImage?
    }
}
