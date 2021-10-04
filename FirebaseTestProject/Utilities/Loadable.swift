//
//  Loadable.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/20/21.
//

import Foundation

enum Loadable<Value: Equatable> {
    case loading, loaded(Value), error(Error)
}

extension Loadable {
    var value: Value? {
        get {
            guard case let .loaded(value) = self else {
                return nil
            }
            return value
        }
        set {
            self = newValue.map { .loaded($0) } ?? .loading
        }
    }
    var error: Error? {
        get {
            guard case let .error(error) = self else {
                return nil
            }
            return error
        }
        set {
            self = newValue.map { .error($0) } ?? .loading
        }
    }
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
