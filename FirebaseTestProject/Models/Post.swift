//
//  Post.swift
//  Post
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation
import FirebaseFirestore

struct Post: FirebaseConvertable {
    let title: String
    let author: String
    let text: String
    let id: UUID
    let authorid: UUID
    let timestamp: Date
    
    init(title: String, text: String, author: String) {
        self.title = title
        self.author = author
        self.text = text
        self.id = UUID()
        self.timestamp = Date()
        let userid = UserDefaults.standard.value(forKey: "userid") != nil ? UUID(uuidString: UserDefaults.standard.value(forKey: "userid") as! String) : UUID(uuidString: "00854E9E-8468-421D-8AA2-605D8E6C61D9")
        self.authorid = userid!
    }
    static let testPost = Post(title: "Title", text: "Content", author: "First Last")
}

protocol FirebaseConvertable: Codable {
    init(from jsonDict: [String: Any])
    var jsonDict: [String: Any] { get }
}

extension FirebaseConvertable {
    init(from jsonDict: [String: Any]) {
        let data = try! JSONSerialization.data(withJSONObject: jsonDict)
        let newInstance = try! JSONDecoder().decode(Self.self, from: data)
        self = newInstance
    }
    var jsonDict: [String: Any] {
        let data = try! JSONEncoder().encode(self)
        let jsonObject = try! JSONSerialization.jsonObject(with: data)
        return jsonObject as! [String: Any]
    }
}

struct PostService {
    static var postsReference: CollectionReference {
        let db = Firestore.firestore()
        return db.collection("posts")
    }
    
    static func getPosts() async throws -> [Post] {
        let postsSnapshots = try await postsReference.getDocuments()
        let posts = postsSnapshots.documents.map { Post(from: $0.data()) }
        return posts
    }
    
    static func upload(_ post: Post) async throws {
        try await postsReference.document(post.id.uuidString).setData(post.jsonDict)
    }
    
    static func delete(_ post: Post) async throws {
        try await postsReference.document(post.id.uuidString).delete()
    }
}

extension DateFormatter {
    static func postFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: date)
    }
}
