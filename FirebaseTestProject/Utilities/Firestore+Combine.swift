//
//  Firestore+Combine.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

extension Query {
    func publishDocuments<T: Decodable>(as type: T.Type) -> AnyPublisher<[T], Error> {
        let publisher = PassthroughSubject<QuerySnapshot, Error>()
        let listener = addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                if let error = error {
                    publisher.send(completion: .failure(error))
                }
                return
            }
            publisher.send(snapshot)
        }
        return publisher
            .map { snapshot in
                snapshot.documents.compactMap { try! $0.data(as: type) }
            }
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
}
