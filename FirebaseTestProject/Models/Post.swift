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
    var isFavorite = false

    init(title: String, text: String, author: User, id: UUID = .init(), timestamp: Date = .init(), isFavorite: Bool = false) {
        self.title = title
        self.text = text
        self.author = author
        self.id = id
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }
    
    static let testPost = Post(title: "Test post title", text: "This post has some content!", author: .testUser)

    enum CodingKeys: CodingKey {
        case title, text, author, id, timestamp
    }
    
    func contains(_ string: String) -> Bool {
        let strings = jsonDict.values.compactMap { value -> String? in
            if let value = value as? String {
                return value.lowercased()
            } else if let value = value as? Date {
                return DateFormatter.postFormat(date: value).lowercased()
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

extension DateFormatter {
    static func postFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: date)
    }
}
