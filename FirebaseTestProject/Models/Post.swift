//
//  Post.swift
//  Post
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation
import UIKit

struct Post: Identifiable, Equatable, FirestoreConvertable {
    let title: String
    let text: String
    let author: User
    let id: UUID
    let timestamp: Date
    var imageURL: URL? {
        get {
            URL(string: imageURLString)
        }
        set {
            imageURLString = newValue?.absoluteString ?? ""
        }
    }
    private var imageURLString = ""
    var isFavorite = false
    
    init(title: String, text: String, author: User, id: UUID = UUID(), timestamp: Date = Date(), imageURL: URL? = nil, isFavorite: Bool = false) {
        self.title = title
        self.text = text
        self.author = author
        self.id = id
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.isFavorite = isFavorite
    }
    
    static let testPost = Post(
        title: "Lorem ipsum",
        text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        author: .testUser,
        imageURL: URL(string: "https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80"),
        isFavorite: true
    )
    
    enum CodingKeys: CodingKey {
        case id, title, text, author, timestamp, imageURLString
    }
    
    func contains(_ string: String) -> Bool {
        let strings = jsonDict.values.compactMap { value -> String? in
            if let value = value as? String {
                return value.lowercased()
            } else if let value = value as? Date {
                return value.formatted()
            }
            return nil
        }
        let matches = strings.filter { $0.contains(string.lowercased()) }
        return !matches.isEmpty
    }
}

extension Post {
    struct Partial {
        var title = ""
        var content = ""
        var image: UIImage?
    }
}
