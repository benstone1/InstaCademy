//
//  Comment.swift
//  Comment
//
//  Created by John Royal on 8/20/21.
//

import Foundation

struct Comment: Identifiable, Equatable, FirebaseConvertable {
    let id: UUID
    let author: User
    let timestamp: Date
    let content: String
    
    init(id: UUID = .init(), author: User, timestamp: Date = .init(), content: String) {
        self.id = id
        self.author = author
        self.timestamp = timestamp
        self.content = content
    }
    
    static let preview: Comment = .init(author: .testUser, content: "Great job!")
}
