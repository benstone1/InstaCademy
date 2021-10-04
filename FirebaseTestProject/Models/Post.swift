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
    var imageURL: URL?
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

// MARK: - Partial

extension Post {
    struct EditableFields {
        var title = ""
        var content = ""
        var image: UIImage?
    }
}
