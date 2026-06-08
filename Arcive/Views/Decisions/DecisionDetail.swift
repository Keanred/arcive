//
//  DecisionDetail.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import SwiftUI
import SwiftData

struct DecisionDetail: View {
    @Bindable var decision: Decision
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false
    @State private var newTagName = ""
    var onSelectDecision: (Decision) -> Void
    @Query private var tags: [Tag]

    var body: some View {
        Form {
            Section {
                HStack(spacing: 4) {
                    Text("ADR-\(decision.number):")
                    EditableText("Title", text: $decision.title, isEditing: isEditing)
                }
                .font(.title)
            }

            Section("Details") {
                statusRows
                if let project = decision.project {
                    LabeledContent("Project", value: project.name)
                }
                LabeledContent("Created", value: decision.createdAt.formatted(date: .abbreviated, time: .shortened))
                if let decidedAt = decision.decidedAt {
                    LabeledContent("Decided", value: decidedAt.formatted(date: .abbreviated, time: .shortened))
                }
            }

            Section("Context") {
                EditableText("Context", text: $decision.context, isEditing: isEditing, multiline: true)
            }

            Section("Rationale") {
                EditableText("Rationale", text: $decision.rationale, isEditing: isEditing, multiline: true)
            }

            Section("Consequences") {
                EditableText("Consequences", text: $decision.consequences, isEditing: isEditing, multiline: true)
            }

            Section("Options Considered") {
                optionsContent
            }

            Section("Tags") {
                tagsContent
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem {
                Button(isEditing ? "Done" : "Edit") { isEditing.toggle() }
                    .buttonStyle(.glassProminent)
            }
        }
    }

    @ViewBuilder
    private var statusRows: some View {
        if isEditing {
            Picker("Status", selection: $decision.status) {
                ForEach(DecisionStatus.allCases) { Text($0.label).tag($0) }
            }
            let candidates = decision.supersedesCandidates(in: modelContext)
            Picker("Supersedes", selection: supersedesBinding) {
                Text("Nothing").tag(Decision?.none)
                if let current = decision.supersedes,
                   !candidates.contains(where: { $0.persistentModelID == current.persistentModelID }) {
                    Text("ADR-\(current.number): \(current.title)").tag(Decision?.some(current))
                }
                ForEach(candidates) { d in
                    Text("ADR-\(d.number): \(d.title)").tag(Decision?.some(d))
                }
            }
        } else {
            LabeledContent("Status", value: decision.status.label)
            if let superseded = decision.supersedes {
                LabeledContent("Supersedes", value: "ADR-\(superseded.number)")
            }
            if let successor = decision.successor(in: modelContext) {
                LabeledContent("Superseded by") {
                    Button {
                        onSelectDecision(successor)
                    } label: {
                        Text("ADR-\(successor.number) →")
                    }
                    .buttonStyle(.link)
                }
            }
        }
    }

    private var supersedesBinding: Binding<Decision?> {
        Binding(
            get: { decision.supersedes },
            set: { setPredecessor($0) }
        )
    }

    private func setPredecessor(_ new: Decision?) {
        decision.supersedes = new
        new?.status = .superseded
    }

    private var optionsContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(decision.options.enumerated()), id: \.element.id) { index, option in
                OptionRow(
                    option: option,
                    isEditing: isEditing,
                    onDelete: { modelContext.delete(option) }
                )
                if index < decision.options.count - 1 {
                    Divider()
                }
            }
            if isEditing {
                if !decision.options.isEmpty { Divider() }
                Button {
                    decision.options.append(.init(title: ""))
                } label: {
                    Label("Add option", systemImage: "plus")
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
    }

    private var tagsContent: some View {
        FlowLayout(spacing: 6, rowSpacing: 6) {
            ForEach(decision.tags, id: \.persistentModelID) { tag in
                tagPill(for: tag)
            }
            if isEditing {
                Picker("", selection: $newTagName) {
                    Text("Add tag…").tag("")
                    ForEach(availableTags, id: \.persistentModelID) { tag in
                        Text(tag.name).tag(tag.name)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: newTagName) { _, newValue in
                    guard !newValue.isEmpty else { return }
                    addTag()
                }
            }
        }
    }

    private var availableTags: [Tag] {
        let assigned = Set(decision.tags.map(\.persistentModelID))
        return tags.filter { !assigned.contains($0.persistentModelID) }
    }

    private func addTag() {
        guard let tag = Tag.fetchOrCreate(named: newTagName, in: modelContext) else { return }
        if !decision.tags.contains(where: { $0.persistentModelID == tag.persistentModelID }) {
            decision.tags.append(tag)
        }
        newTagName = ""
    }

    private func tagPill(for tag: Tag) -> some View {
        HStack(spacing: 4) {
            Text(tag.name)
            if isEditing {
                Button {
                    decision.tags.removeAll { $0 == tag }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove tag \(tag.name)")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .glassEffect()
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSamples.container)
}
