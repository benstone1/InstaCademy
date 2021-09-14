//
//  Post.swift
//  Post
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation
import UIKit

// MARK: - Post

struct Post: Identifiable, Equatable, FirestoreConvertable {
    let title: String
    let text: String
    let author: User
    let id: String
    let timestamp: Date
    var imageURL: URL? {
        get {
            URL(string: imageURLString)
        }
        set {
            imageURLString = newValue?.absoluteString ?? ""
        }
    }
    var isFavorite = false
    
    private var imageURLString = ""
    
    init(title: String, text: String, author: User, id: String, timestamp: Date = Date(), imageURL: URL? = nil, isFavorite: Bool = false) {
        self.title = title
        self.text = text
        self.author = author
        self.id = id
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.isFavorite = isFavorite
    }
    
    func contains(_ string: String) -> Bool {
        let content = [title, text, author.name].map { $0.lowercased() }
        let query = string.lowercased()
        
        let matches = content.filter { $0.contains(query) }
        return !matches.isEmpty
    }
}

// MARK: - Test

extension Post {
    static let testPost = Post(
        title: "Lorem ipsum",
        text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        author: .testUser,
        id: "00000000000000000000",
        imageURL: URL(string: "https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80"),
        isFavorite: true
    )
}

// MARK: - CodingKeys

extension Post {
    enum CodingKeys: CodingKey {
        case title, text, author, id, timestamp, imageURLString
    }
}

// MARK: - Partial

extension Post {
    struct Partial {
        var title = ""
        var content = ""
        var image: UIImage?
    }
}
