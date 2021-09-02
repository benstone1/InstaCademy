//
//  Post.swift
//  Post
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

struct Post: Identifiable, Equatable, FirebaseConvertable {
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
    
    static let testPost = Post(title: "Test post title", text: "This post has some content!", author: .testUser)

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
