//
//  Query+Extensions.swift
//  Query+Extensions
//
//  Created by John Royal on 8/30/21.
//

import Foundation
import FirebaseFirestore

extension Query {
    func getDocuments<Model: FirebaseConvertable>(as modelType: Model.Type) async throws -> [Model] {
        let snapshot = try await getDocuments()
        return snapshot.documents.map { Model(from: $0.data()) }
    }
}
