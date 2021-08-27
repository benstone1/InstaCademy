//
//  FirebaseConvertable.swift
//  FirebaseConvertable
//
//  Created by John Royal on 8/21/21.
//

import Foundation

protocol FirebaseConvertable: Codable {
    init(from jsonDict: [String: Any])
    var jsonDict: [String: Any] { get }
}

extension FirebaseConvertable {
    init(from jsonDict: [String: Any]) {
        let data = try! JSONSerialization.data(withJSONObject: jsonDict)
        let newInstance = try! JSONDecoder().decode(Self.self, from: data)
        self = newInstance
    }
    var jsonDict: [String: Any] {
        let data = try! JSONEncoder().encode(self)
        let jsonObject = try! JSONSerialization.jsonObject(with: data)
        return jsonObject as! [String: Any]
    }
}
