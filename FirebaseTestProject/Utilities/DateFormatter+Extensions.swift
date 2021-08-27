//
//  DateFormatter+Extensions.swift
//  DateFormatter+Extensions
//
//  Created by John Royal on 8/27/21.
//

import Foundation

extension DateFormatter {
    static func postFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: date)
    }
}
