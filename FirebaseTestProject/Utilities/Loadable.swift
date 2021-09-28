//
//  Loadable.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/20/21.
//

import Foundation
import Combine

enum Loadable<Value: Equatable> {
    case loading, loaded(Value), error(Error)
}

extension Loadable where Value: ExpressibleByArrayLiteral {
    static var empty: Loadable<Value> {
        .loaded([])
    }
}

extension Loadable: Equatable {
    static func == (lhs: Loadable<Value>, rhs: Loadable<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.error(_), .error(_)):
            return true
        case let (.loaded(value1), .loaded(value2)):
            return value1 == value2
        default:
            return false
        }
    }
}
