//
//  PreviewSamples.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import Foundation
import SwiftData

@MainActor
enum PreviewSamples {
    static let container: ModelContainer = {
        let container = try! ModelContainer(
            for: Project.self, Decision.self, Option.self, Tag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let alpha = Project(name: "Alpha", detail: "Customer-facing iOS app for tracking architectural decisions.")
        let beta = Project(name: "Beta", detail: "Internal data pipeline rewrite to consolidate ingestion.")
        context.insert(alpha)
        context.insert(beta)

        let swiftTag = Tag(name: "swift")
        let architectureTag = Tag(name: "architecture")
        let infraTag = Tag(name: "infrastructure")
        context.insert(swiftTag)
        context.insert(architectureTag)
        context.insert(infraTag)

        let d1 = Decision(title: "Use SwiftData", number: 1)
        d1.project = alpha
        d1.status = .accepted
        d1.context = "We need local persistence with iCloud sync and tight SwiftUI integration."
        d1.rationale = "SwiftData provides a modern, declarative API on top of Core Data with first-class SwiftUI bindings via @Query."
        d1.consequences = "We lock into iOS 17+ and accept the early-adopter risk of an evolving framework."
        d1.decidedAt = Calendar.current.date(byAdding: .day, value: -30, to: .now)
        d1.createdAt = Calendar.current.date(byAdding: .day, value: -32, to: .now) ?? .now
        d1.tags = [swiftTag, architectureTag]

        let d2 = Decision(title: "Adopt NavigationSplitView", number: 2)
        d2.project = alpha
        d2.status = .accepted
        d2.context = "The app needs a three-pane layout that adapts across iPhone, iPad, and Mac."
        d2.rationale = "NavigationSplitView gives us platform-correct sidebar/content/detail behavior with minimal custom code."
        d2.consequences = "Some custom transitions become harder; we rely on system defaults for column visibility."
        d2.decidedAt = Calendar.current.date(byAdding: .day, value: -20, to: .now)
        d2.createdAt = Calendar.current.date(byAdding: .day, value: -22, to: .now) ?? .now
        d2.tags = [swiftTag, architectureTag]

        let d3 = Decision(title: "Deprecate legacy CSV importer", number: 3)
        d3.project = alpha
        d3.status = .deprecated
        d3.context = "The CSV importer was a stopgap before the JSON pipeline shipped."
        d3.rationale = "Maintaining two import paths doubled the test surface and confused users."
        d3.consequences = "Existing CSV users must migrate before the next release."
        d3.decidedAt = Calendar.current.date(byAdding: .day, value: -10, to: .now)
        d3.createdAt = Calendar.current.date(byAdding: .day, value: -12, to: .now) ?? .now
        d3.supersedes = d1
        d3.tags = [architectureTag]

        let d4 = Decision(title: "Ship MVP", number: 1)
        d4.project = beta
        d4.status = .proposed
        d4.context = "Stakeholders want an early end-to-end demo to validate the ingestion approach."
        d4.rationale = "Shipping a thin slice proves the architecture and surfaces unknowns before scaling out."
        d4.consequences = "Polish and edge cases get deferred; we accept short-term tech debt."
        d4.createdAt = Calendar.current.date(byAdding: .day, value: -5, to: .now) ?? .now
        d4.tags = [infraTag]

        let d5 = Decision(title: "Use Kafka for event bus", number: 2)
        d5.project = beta
        d5.status = .rejected
        d5.context = "We evaluated Kafka, NATS, and Postgres LISTEN/NOTIFY for inter-service events."
        d5.rationale = "Kafka's operational overhead outweighed its benefits at our current scale."
        d5.consequences = "We start with Postgres LISTEN/NOTIFY and revisit if throughput becomes a problem."
        d5.decidedAt = Calendar.current.date(byAdding: .day, value: -3, to: .now)
        d5.createdAt = Calendar.current.date(byAdding: .day, value: -4, to: .now) ?? .now
        d5.tags = [infraTag, architectureTag]

        context.insert(d1)
        context.insert(d2)
        context.insert(d3)
        context.insert(d4)
        context.insert(d5)

        return container
    }()

    @MainActor
    static var firstProject: Project {
        let descriptor = FetchDescriptor<Project>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? container.mainContext.fetch(descriptor).first) ?? Project(name: "Fallback")
    }

    @MainActor
    static var firstDecision: Decision {
        let descriptor = FetchDescriptor<Decision>(sortBy: [SortDescriptor(\.number)])
        return (try? container.mainContext.fetch(descriptor).first) ?? Decision(title: "Fallback", number: 0)
    }
}
