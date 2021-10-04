//
//  Models+Preview.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/27/21.
//

import Foundation

// MARK: - Comment

extension Comment {
    static let testComments = [
        Comment.testComment(),
        Comment.testComment(author: User.testUser(id: ""))
    ]
    
    static func testComment(
        content: String = "Lorem ipsum dolor sit amet",
        author: User = User.testUser(),
        id: String = "00000000000000000000",
        timestamp: Date = Date()
    ) -> Comment {
        Comment(content: content, author: author, id: id, timestamp: timestamp)
    }
}

// MARK: - Post

extension Post {
    static let testPosts = [
        Post.testPost(imageURL: nil),
        Post.testPost(author: User.testUser(id: "", imageURL: nil)),
        Post.testPost(),
        Post.testPost(isFavorite: true)
    ]
    
    static func testPost(
        title: String = "Lorem ipsum",
        content: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        author: User = User.testUser(),
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        imageURL: URL? = URL(string: "https://source.unsplash.com/eOpewngf68w/800x800"),
        isFavorite: Bool = false
    ) -> Post {
        Post(title: title, content: content, author: author, id: id, timestamp: timestamp, imageURL: imageURL, isFavorite: isFavorite)
    }
}

// MARK: - User

extension User {
    static func testUser(
        id: String = "00000000000000000000",
        name: String = "Jamie Harris",
        imageURL: URL? = URL(string: "https://source.unsplash.com/lw9LrnpUmWw/480x480")
    ) -> User {
        User(id: id, name: name, imageURL: imageURL)
    }
}
