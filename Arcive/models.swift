//
//  models.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import Foundation
import SwiftData

enum DecisionStatus: String, Codable, CaseIterable, Identifiable {
    case proposed, accepted, rejected, deprecated, superseded
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

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
}

@Model
final class Decision {
    var title: String = ""
    var number: Int = 0              // ADR number within its project (ADR-0007)
    var status: DecisionStatus = DecisionStatus.proposed
    var context: String = ""        // the forces at play
    var rationale: String = ""      // what was decided and why
    var consequences: String = ""   // resulting tradeoffs
    var createdAt: Date = Date.now
    var decidedAt: Date?

    // Many decisions → one project. Optional endpoint (the safe default).
    var project: Project?

    // One decision → many options considered. Inverse on this (to-many) side.
    //@Relationship(deleteRule: .cascade, inverse: \Option.decision)
    //var options: [Option] = []

    // Self-referential: this decision supersedes an earlier one.
    // Kept ONE-directional on purpose (see note below).
    var supersedes: Decision?

    // Many-to-many with tags.
    var tags: [Tag] = []

    init(title: String, number: Int) {
        self.title = title
        self.number = number
    }
}

@Model
final class Option {
    var title: String = ""
    var detail: String = ""
    var pros: String = ""
    var cons: String = ""
    var wasChosen: Bool = false
    var decision: Decision?

    init(title: String) { self.title = title }
}

@Model
final class Tag {
    var name: String = ""
    // Inverse of Decision.tags — declared on one side only.
    @Relationship(inverse: \Decision.tags)
    var decisions: [Decision] = []

    init(name: String) { self.name = name }
}
