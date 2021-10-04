//
//  Optional+Exists.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/23/21.
//

import SwiftUI

extension Optional {
    var exists: Bool {
        get { self != nil }
        set { self = newValue ? self : nil }
    }
}

