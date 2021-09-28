//
//  Comment.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/20/21.
//

import Foundation

// MARK: - Comment

struct Comment: Identifiable, Equatable, Codable {
    let content: String
    let author: User
    let id: String
    let timestamp: Date
    
    init(content: String, author: User, id: String, timestamp: Date = Date()) {
        self.content = content
        self.author = author
        self.id = id
        self.timestamp = timestamp
    }
}

// MARK: - Preview Content

extension Comment {
    static func testComment(
        content: String = "Lorem ipsum dolor sit amet",
        author: User = User.testUser(),
        id: String = "00000000000000000000",
        timestamp: Date = Date()
    ) -> Comment {
        Comment(content: content, author: author, id: id, timestamp: timestamp)
    }
}

// MARK: - Partial

extension Comment {
    struct EditableFields {
        var content = ""
    }
}
