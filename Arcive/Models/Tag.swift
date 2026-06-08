//
//  Tag.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import Foundation
import SwiftData

@Model
final class Tag {
    var name: String = ""
    @Relationship(inverse: \Decision.tags)
    var decisions: [Decision] = []

    init(name: String) { self.name = name }

    static func fetchOrCreate(named rawName: String, in context: ModelContext) -> Tag? {
        let name = Tag.normalize(rawName)
        guard !name.isEmpty else { return nil }

        var descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.name == name }
        )
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let new = Tag(name: name)
        context.insert(new)
        return new
    }

    static func normalize(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}
