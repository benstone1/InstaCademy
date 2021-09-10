//
//  Firestore+Extensions.swift
//  Firestore+Extensions
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseFirestore

// MARK: - FirestoreConvertable

protocol FirestoreConvertable: Codable {
    init(from jsonDict: [String: Any])
    var jsonDict: [String: Any] { get }
}

extension FirestoreConvertable {
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

// MARK: - Query

extension Query {
    func getDocuments<T: FirestoreConvertable>(as modelType: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        return snapshot.documents.map { T(from: $0.data()) }
    }
}
