//
//  Loadable.swift
//  Loadable
//
//  Created by John Royal on 9/9/21.
//

import Foundation

enum Loadable<Value> {
    case loading, loaded(Value), error
}

extension Loadable {
    var value: Value? {
        get {
            if case let .loaded(value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .loaded(newValue)
            }
        }
    }
}
