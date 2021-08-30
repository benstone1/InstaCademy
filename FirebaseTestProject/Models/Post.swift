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
    
    init(title: String, text: String, author: User, id: UUID = .init(), timestamp: Date = .init()) {
        self.title = title
        self.text = text
        self.author = author
        self.id = id
        self.timestamp = timestamp
    }
    static let testPost = Post(title: "Title", text: "Content", author: "First Last")
    
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
        return matches.count > 0
    }
}

extension Post {
    @available(*, deprecated, message: "Specify the author with a User object instead.")
    init(title: String, text: String, author: String) {
        self.title = title
        self.author = .init(name: author)
        self.text = text
        self.id = UUID()
        self.timestamp = Date()
    }
}
