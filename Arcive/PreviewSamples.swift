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

        let d1o1 = Option(title: "SwiftData")
        d1o1.detail = "Apple's declarative persistence framework built on top of Core Data."
        d1o1.pros = "Native SwiftUI @Query bindings; concise @Model macro; iCloud sync built in."
        d1o1.cons = "iOS 17+ minimum; framework still maturing; some Core Data features missing."
        d1o1.wasChosen = true
        d1o1.decision = d1

        let d1o2 = Option(title: "Core Data")
        d1o2.detail = "Apple's mature object graph and persistence framework."
        d1o2.pros = "Battle-tested; deep tooling and documentation; works on older OS versions."
        d1o2.cons = "Verbose Objective-C-flavored API; weak SwiftUI integration without wrappers."
        d1o2.decision = d1

        let d1o3 = Option(title: "GRDB")
        d1o3.detail = "Third-party Swift wrapper around SQLite with a Codable-friendly API."
        d1o3.pros = "Fast; explicit SQL when you want it; no Objective-C runtime."
        d1o3.cons = "External dependency; no iCloud sync story; manual SwiftUI plumbing."
        d1o3.decision = d1

        let d2o1 = Option(title: "NavigationSplitView")
        d2o1.detail = "SwiftUI's first-party three-column container."
        d2o1.pros = "Platform-correct on iPhone, iPad, and Mac; respects column visibility settings."
        d2o1.cons = "Limited customization of transitions and column widths."
        d2o1.wasChosen = true
        d2o1.decision = d2

        let d2o2 = Option(title: "NavigationStack with custom sidebar")
        d2o2.detail = "Use NavigationStack for the detail column and hand-roll the sidebar."
        d2o2.pros = "Total control over layout and animation."
        d2o2.cons = "Reimplementing system behavior; feels less native on Mac."
        d2o2.decision = d2

        let d2o3 = Option(title: "UIKit/AppKit hybrid")
        d2o3.detail = "Host SwiftUI inside a UISplitViewController / NSSplitViewController."
        d2o3.pros = "Mature, well-understood split-view APIs."
        d2o3.cons = "Two layout systems to reason about; sidebar/detail communication gets awkward."
        d2o3.decision = d2

        let d5o1 = Option(title: "Kafka")
        d5o1.detail = "Distributed log-based event streaming platform."
        d5o1.pros = "Industry standard; high throughput; rich ecosystem of connectors."
        d5o1.cons = "Operational complexity; overkill at our current scale; needs ZooKeeper or KRaft."
        d5o1.decision = d5

        let d5o2 = Option(title: "NATS")
        d5o2.detail = "Lightweight pub/sub messaging system."
        d5o2.pros = "Simple to operate; low latency; clustering is straightforward."
        d5o2.cons = "Smaller ecosystem; still another piece of infrastructure to run."
        d5o2.decision = d5

        let d5o3 = Option(title: "Postgres LISTEN/NOTIFY")
        d5o3.detail = "Use Postgres's built-in pub/sub channels for inter-service events."
        d5o3.pros = "Zero new infrastructure; transactional with existing data; easy to reason about."
        d5o3.cons = "Not durable across listener disconnects; throughput ceiling; payloads capped at 8 KB."
        d5o3.wasChosen = true
        d5o3.decision = d5

        context.insert(d1)
        context.insert(d2)
        context.insert(d3)
        context.insert(d4)
        context.insert(d5)
        context.insert(d1o1)
        context.insert(d1o2)
        context.insert(d1o3)
        context.insert(d2o1)
        context.insert(d2o2)
        context.insert(d2o3)
        context.insert(d5o1)
        context.insert(d5o2)
        context.insert(d5o3)

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
