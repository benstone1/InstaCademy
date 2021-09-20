//
//  Comment.swift
//  Comment
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

// MARK: - Test

extension Comment {
    static let testComment = Comment(
        content: "Great job!",
        author: .testUser,
        id: "00000000000000000000"
    )
}

// MARK: - Partial

extension Comment {
    struct EditableFields {
        var content = ""
    }
}
