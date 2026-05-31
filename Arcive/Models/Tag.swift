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
    // Inverse of Decision.tags — declared on one side only.
    @Relationship(inverse: \Decision.tags)
    var decisions: [Decision] = []

    init(name: String) { self.name = name }
}
