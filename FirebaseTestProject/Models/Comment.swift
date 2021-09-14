//
//  Comment.swift
//  Comment
//
//  Created by John Royal on 8/20/21.
//

import Foundation

// MARK: - Comment

struct Comment: Identifiable, Equatable, FirestoreConvertable {
    let content: String
    let author: User
    let id: UUID
    let timestamp: Date
    
    init(content: String, author: User, id: UUID = UUID(), timestamp: Date = Date()) {
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
        author: .testUser
    )
}

// MARK: - Partial

extension Comment {
    struct Partial {
        var content = ""
    }
}
