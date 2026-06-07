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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            statusRow
            projectRow
            timestampsRow
            Divider()
            List {
                section("Context", text: $decision.context)
                section("Rationale", text: $decision.rationale)
                section("Consequences", text: $decision.consequences)
                optionsSection
                tagsSection
            }
        }
        .padding()
    }

    private var header: some View {
        HStack {
            HStack(spacing: 4) {
                Text("ADR-\(decision.number):")
                EditableText("Title", text: $decision.title, isEditing: isEditing)
            }
            .font(.title)
            Spacer()
            Button(isEditing ? "Done" : "Edit") { isEditing.toggle() }
        }
    }

    @ViewBuilder
    private var statusRow: some View {
        HStack {
            if isEditing {
                Picker("Status", selection: $decision.status) {
                    ForEach(DecisionStatus.allCases) { Text($0.label).tag($0) }
                }
                Picker("Supersedes", selection: supersedesBinding) {
                    Text("Nothing").tag(Decision?.none)
                    if let current = decision.supersedes,
                       !supersedesCandidates.contains(where: { $0.persistentModelID == current.persistentModelID }) {
                        Text("ADR-\(current.number): \(current.title)").tag(Decision?.some(current))
                    }
                    ForEach(supersedesCandidates) { d in
                        Text("ADR-\(d.number): \(d.title)").tag(Decision?.some(d))
                    }
                }
            } else {
                Text("Status: \(decision.status.label)")
                if let superseded = decision.supersedes {
                    Text("Supersedes ADR-\(superseded.number)")
                        .foregroundStyle(.secondary)
                }
                if let successor = decision.successor(in: modelContext) {
                    Button {
                        onSelectDecision(successor)
                    } label: {
                        Text("Superseded by ADR-\(successor.number) →")
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

    private var supersedesCandidates: [Decision] {
        let projectID = decision.project?.persistentModelID
        let descriptor = FetchDescriptor<Decision>(
            predicate: #Predicate { d in
                d.project?.persistentModelID == projectID
            },
            sortBy: [SortDescriptor(\.number)]
        )
        let all = (try? modelContext.fetch(descriptor)) ?? []
        let forbidden = forbiddenPredecessorIDs()
        return all.filter { decision in
            decision.status == .accepted && !forbidden.contains(decision.persistentModelID)
        }
    }

    private func forbiddenPredecessorIDs() -> Set<PersistentIdentifier> {
        var ids: Set<PersistentIdentifier> = [decision.persistentModelID]
        var cursor: Decision? = decision.successor(in: modelContext)
        while let next = cursor {
            if !ids.insert(next.persistentModelID).inserted { break }
            cursor = next.successor(in: modelContext)
        }
        return ids
    }

    @ViewBuilder
    private var projectRow: some View {
        if let project = decision.project {
            Text("Project: \(project.name)").foregroundStyle(.secondary)
        }
    }

    private var timestampsRow: some View {
        HStack {
            Text("Created \(decision.createdAt.formatted(date: .abbreviated, time: .shortened))")
            if let decidedAt = decision.decidedAt {
                Text("· Decided \(decidedAt.formatted(date: .abbreviated, time: .shortened))")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private func section(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            EditableText(title, text: text, isEditing: isEditing, multiline: true)
        }
    }

    private var optionsSection: some View {
        GroupBox {
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
        } label: {
            Text("Options considered").font(.headline)
        }
    }

    private var tagsSection: some View {
        HStack(spacing: 4) {
            Text("Tags:")
            ForEach(decision.tags, id: \.self) { tag in
                Text(tag.name)
                    .padding(4)
                    .background(Color.blue)
                    .cornerRadius(4)
            }
            if isEditing {
                TextField("New tag", text: $newTagName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 120)
                Button("Add tag", action: addTag)
                    .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func addTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        decision.tags.append(Tag(name: trimmed))
        newTagName = ""
    }
}

private struct EditableText: View {
    let placeholder: String
    @Binding var text: String
    let isEditing: Bool
    var multiline: Bool = false

    init(_ placeholder: String, text: Binding<String>, isEditing: Bool, multiline: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.isEditing = isEditing
        self.multiline = multiline
    }

    var body: some View {
        if isEditing {
            if multiline {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(3...10)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
            }
        } else {
            Text(text.isEmpty ? "—" : text)
        }
    }
}

private struct OptionRow: View {
    @Bindable var option: Option
    var isEditing: Bool
    var onDelete: () -> Void
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button {
                    isExpanded.toggle()
                } label: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.15), value: isExpanded)
                }
                .buttonStyle(.plain)
                Button {
                    option.wasChosen.toggle()
                } label: {
                    Image(systemName: option.wasChosen ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(option.wasChosen ? Color.green : .secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .disabled(!isEditing)
                EditableText("Title", text: $option.title, isEditing: isEditing)
                if isEditing {
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                }
            }
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    field("Detail", text: $option.detail)
                    field("Pros", text: $option.pros)
                    field("Cons", text: $option.cons)
                }
                .padding(.leading, 20)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            EditableText(title, text: text, isEditing: isEditing, multiline: true)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSamples.container)
}
