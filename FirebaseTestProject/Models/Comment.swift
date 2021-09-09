//
//  Comment.swift
//  Comment
//
//  Created by John Royal on 8/20/21.
//

import Foundation

struct Comment: Identifiable, Equatable, FirebaseConvertable {
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
    
    static let testComment: Comment = .init(content: "Great job!", author: .testUser)
}
