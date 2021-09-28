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
