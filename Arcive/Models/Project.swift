//
//  Project.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import Foundation
import SwiftData

@Model
final class Project {
    var name: String = ""
    var detail: String = ""
    var createdAt: Date = Date.now
    var isArchived: Bool = false

    // One project → many decisions. Inverse + delete rule declared here.
    // .cascade: deleting a project deletes its decisions.
    @Relationship(deleteRule: .cascade, inverse: \Decision.project)
    var decisions: [Decision] = []

    init(name: String, detail: String = "") {
        self.name = name
        self.detail = detail
    }

    var nextDecisionNumber: Int {
        (decisions.map(\.number).max() ?? 0) + 1
    }
}
