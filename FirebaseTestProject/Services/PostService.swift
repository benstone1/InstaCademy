//
//  PostService.swift
//  PostService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseFirestore

struct PostService {
    static var postsReference: CollectionReference {
        let db = Firestore.firestore()
        return db.collection("posts_v1")
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
