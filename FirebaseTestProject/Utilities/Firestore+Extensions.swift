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
    /// Encodes an instance of `Encodable`and writes the encoded data to the document referred by this `DocumentReference`.
    /// If no document exists, it is created. If a document already exists, it is overwritten.
    ///
    /// This is an async wrapper for an existing method. The compiler was unable to synthesize this wrapper
    /// automatically because the completion handler for the wrapped method is an optional value.
    ///
    /// - Parameters:
    ///   - value: An instance of `Encodable` to be encoded to a document.
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
    /// Reads the documents matching this query and converts them to instances of the caller-specified type.
    ///
    /// - Parameters
    ///   - type: The type to convert the document fields to.
    func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        return snapshot.documents.compactMap { try! $0.data(as: type) }
    }
}
