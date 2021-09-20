//
//  Firestore+Extensions.swift
//  Firestore+Extensions
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension Query {
    func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        return snapshot.documents.compactMap { try! $0.data(as: type) }
    }
}
