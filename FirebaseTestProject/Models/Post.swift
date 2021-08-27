//
//  Post.swift
//  Post
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

struct Post: Identifiable, Equatable, FirebaseConvertable {
    let title: String
    let text: String
    let author: User
    let id: UUID
    let timestamp: Date
    
    init(title: String, text: String, author: User, id: UUID = .init(), timestamp: Date = .init()) {
        self.title = title
        self.text = text
        self.author = author
        self.id = id
        self.timestamp = timestamp
    }
    static let testPost = Post(title: "Title", text: "Content", author: "First Last")
    
    func contains(_ string: String) -> Bool {
        let strings = jsonDict.values.compactMap { value -> String? in
            if let value = value as? String {
                return value.lowercased()
            } else if let value = value as? Date {
                return DateFormatter.postFormat(date: value).lowercased()
            }
            return nil
        }
        let matches = strings.filter { $0.contains(string.lowercased()) }
        return matches.count > 0
    }
}

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

extension Post {
    @available(*, deprecated, message: "Specify the author with a User object instead.")
    init(title: String, text: String, author: String) {
        self.title = title
        self.author = .init(name: author)
        self.text = text
        self.id = UUID()
        self.timestamp = Date()
    }
    
    static let testPost = Post(title: "Title", text: "Content", author: "First Last")
}


extension DateFormatter {
    static func postFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: date)
    }
}
