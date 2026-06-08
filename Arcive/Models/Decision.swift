//
//  Decision.swift
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
    @Relationship(deleteRule: .cascade, inverse: \Option.decision)
    var options: [Option] = []

    // Self-referential: this decision supersedes an earlier one.
    // Kept ONE-directional on purpose (see note below).
    var supersedes: Decision?

    // Many-to-many with tags.
    var tags: [Tag] = []

    init(title: String, number: Int) {
        self.title = title
        self.number = number
    }
    
    // "Has anything superseded this decision?"
    func successor(in context: ModelContext) -> Decision? {
        let id = persistentModelID
        let descriptor = FetchDescriptor<Decision>(
            predicate: #Predicate { $0.supersedes?.persistentModelID == id }
        )
        return try? context.fetch(descriptor).first
    }

    // Accepted decisions in the same project that this one could validly supersede:
    // excludes self and anything downstream in the supersession chain (cycle prevention).
    func supersedesCandidates(in context: ModelContext) -> [Decision] {
        let projectID = project?.persistentModelID
        let descriptor = FetchDescriptor<Decision>(
            predicate: #Predicate { d in
                d.project?.persistentModelID == projectID
            },
            sortBy: [SortDescriptor(\.number)]
        )
        let all = (try? context.fetch(descriptor)) ?? []
        let forbidden = forbiddenPredecessorIDs(in: context)
        return all.filter { candidate in
            candidate.status == .accepted && !forbidden.contains(candidate.persistentModelID)
        }
    }

    private func forbiddenPredecessorIDs(in context: ModelContext) -> Set<PersistentIdentifier> {
        var ids: Set<PersistentIdentifier> = [persistentModelID]
        var cursor: Decision? = successor(in: context)
        while let next = cursor {
            if !ids.insert(next.persistentModelID).inserted { break }
            cursor = next.successor(in: context)
        }
        return ids
    }

}
