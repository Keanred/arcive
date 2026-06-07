//
//  DecisionsContent.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import SwiftUI
import SwiftData

struct DecisionsContent: View {
    @Environment(\.modelContext) private var modelContext
    @State private var query = ""
    @State private var tokens: [SearchToken] = []
    @State private var sortField: SortField = .number
    @State private var sortOrder: SortOrder = .forward
    var project: Project?
    @Binding var selection: Decision?

    enum SearchToken: Identifiable, Hashable {
        case status(DecisionStatus)

        var id: Self { self }

        var label: String {
            switch self {
            case .status(let status): status.label
            }
        }

        var systemImage: String {
            switch self {
            case .status: "circle.fill"
            }
        }

        var tintColor: Color {
            switch self {
            case .status(let status): status.color
            }
        }
    }

    enum SortField: String, CaseIterable, Identifiable {
        case number, title, createdAt, status

        var id: Self { self }

        var label: String {
            switch self {
            case .number:    "ADR Number"
            case .title:     "Title"
            case .createdAt: "Date Created"
            case .status:    "Status"
            }
        }

        func descriptor(order: SortOrder) -> SortDescriptor<Decision> {
            switch self {
            case .number:    SortDescriptor(\.number,           order: order)
            case .title:     SortDescriptor(\.title,            order: order)
            case .createdAt: SortDescriptor(\.createdAt,        order: order)
            case .status:    SortDescriptor(\.status.rawValue,  order: order)
            }
        }
    }

    private var suggestedTokens: [SearchToken] {
        DecisionStatus.allCases.map(SearchToken.status)
    }

    private var decisionPredicate: Predicate<Decision> {
        let projectID = project?.persistentModelID
        let statusFilter = Set(tokens.map { token -> DecisionStatus in
            switch token {
            case .status(let status): status
            }
        })
        let hasStatusFilter = !statusFilter.isEmpty
        let searchText = query
        let hasSearchText = !searchText.isEmpty

        return #Predicate<Decision> { decision in
            decision.project?.persistentModelID == projectID
            && (!hasStatusFilter || statusFilter.contains(decision.status))
            && (!hasSearchText
                || decision.title.localizedStandardContains(searchText)
                || decision.context.localizedStandardContains(searchText))
        }
    }

    var body: some View {
        if let project {
            DecisionList(
                predicate: decisionPredicate,
                sort: [sortField.descriptor(order: sortOrder)],
                selection: $selection
            )
            .searchable(
                text: $query,
                tokens: $tokens,
                suggestedTokens: .constant(suggestedTokens),
                prompt: "Decisions"
            ) { token in
                Label(token.label, systemImage: token.systemImage)
                    .foregroundStyle(token.tintColor)
            }
            .toolbar {
                ToolbarItem {
                    Menu {
                        Picker("Sort by", selection: $sortField) {
                            ForEach(SortField.allCases) { field in
                                Text(field.label).tag(field)
                            }
                        }
                        Divider()
                        Picker("Order", selection: $sortOrder) {
                            Text("Ascending").tag(SortOrder.forward)
                            Text("Descending").tag(SortOrder.reverse)
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarSpacer(.fixed)
                ToolbarItem {
                    Button {
                        let decision = Decision(title: "New Decision", number: nextNumber(in: project))
                        modelContext.insert(decision)
                        decision.project = project
                    } label: {
                        Label("New Decision", systemImage: "plus")
                    }
                    .buttonStyle(.glassProminent)
                }
            }
        } else {
            ContentUnavailableView(
                "No Project Selected",
                systemImage: "folder",
                description: Text("Select a project from the sidebar to view its decisions.")
            )
        }
    }

    func nextNumber(in project: Project) -> Int {
        var highest = 0
        for decision in project.decisions {
            highest = max(highest, decision.number)
        }
        return highest + 1
    }
}

extension DecisionStatus {
    var color: Color {
        switch self {
        case .accepted:   .green
        case .proposed:   .orange
        case .rejected:   .red
        case .deprecated: .secondary
        case .superseded: .gray
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSamples.container)
}
