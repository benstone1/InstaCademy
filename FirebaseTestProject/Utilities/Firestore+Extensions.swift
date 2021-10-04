//
//  Firestore+Extensions.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension DocumentReference {
    /// Encodes an instance of `Encodable` and overwrites the encoded data
    /// to the document referred by this `DocumentReference`. If no document exists,
    /// it is created. If a document already exists, it is overwritten.
    ///
    /// This is an async wrapper for `setData(from:completion:)`.
    /// The compiler doesn’t synthesize this wrapper automatically because the completion handler is an optional type.
    ///
    /// - Parameters:
    ///   - value: An `Encodable` instance to be encoded to a document.
    func setData<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try setData(from: value) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: ())
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

extension Query {
    /// Retrieves documents for this this query and converts them to instances of the caller-specified type.
    /// - Parameter type: The `Decodable` type to convert documents to.
    func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        return snapshot.documents.compactMap { try! $0.data(as: type) }
    }
}
