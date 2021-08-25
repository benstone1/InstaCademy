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
    let timestamp: Date
    
    init(title: String, text: String, author: String) {
        self.title = title
        self.author = author
        self.text = text
        self.id = UUID()
        self.timestamp = Date()
    }
    static let testPost = Post(title: "Title", text: "Content", author: "First Last")
    
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
}


extension DateFormatter {
    static func postFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: date)
    }
}
