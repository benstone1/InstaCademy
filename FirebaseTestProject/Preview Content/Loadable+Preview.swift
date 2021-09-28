//
//  Loadable+Preview.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/22/21.
//

import Foundation
import Combine

extension Loadable {
    static var error: Loadable<Value> {
        .error(NSError(domain: "PreviewError", code: 0))
    }
    
    func preview() async throws -> Value {
        switch self {
        case .loading:
            await Task.sleep(1_000_000_000 * 5)
            fatalError()
        case let .loaded(value):
            return value
        case let .error(error):
            throw error
        }
    }
    
    func preview() -> AnyPublisher<Value, Error> {
        switch self {
        case .loading:
            return PassthroughSubject<Value, Error>().eraseToAnyPublisher()
        case let .loaded(value):
            return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
        case let .error(error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
