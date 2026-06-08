//
//  TagList.swift
//  Arcive
//
//  Created by Anssi Keinänen on 7.6.2026.
//

import SwiftUI
import SwiftData

struct TagList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var tags: [Tag]

    @State private var editingTag: Tag?
    @State private var editedName: String = ""
    @State private var isAddingTag = false
    @State private var newTagName: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Table(tags) {
                TableColumn("Tag", value: \.name)
                TableColumn("Used") { tag in
                    Text("\(tag.decisions.count)")
                        .monospacedDigit()
                }
                TableColumn("") { tag in
                    HStack(spacing: 8) {
                        Button {
                            beginEditing(tag)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .buttonStyle(.borderless)
                        .labelStyle(.iconOnly)
                        .accessibilityLabel("Edit tag \(tag.name)")

                        Button(role: .destructive) {
                            delete(tag)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .buttonStyle(.borderless)
                        .labelStyle(.iconOnly)
                        .accessibilityLabel("Delete tag \(tag.name)")
                    }
                }
            }

            Button("New Tag", systemImage: "tag.fill") {
                newTagName = ""
                isAddingTag = true
            }
            .buttonStyle(.glassProminent)
            .padding()
        }
        .alert("Rename tag", isPresented: Binding(
            get: { editingTag != nil },
            set: { if !$0 { editingTag = nil } }
        )) {
            TextField("Name", text: $editedName)
            Button("Save", action: commitEdit)
            Button("Cancel", role: .cancel) { editingTag = nil }
        }
        .alert("New tag", isPresented: $isAddingTag) {
            TextField("Name", text: $newTagName)
            Button("Add", action: commitNewTag)
            Button("Cancel", role: .cancel) { }
        }
    }

    private func beginEditing(_ tag: Tag) {
        editedName = tag.name
        editingTag = tag
    }

    private func commitEdit() {
        guard let tag = editingTag else { return }
        let normalized = Tag.normalize(editedName)
        if !normalized.isEmpty {
            tag.name = normalized
        }
        editingTag = nil
    }

    private func commitNewTag() {
        _ = Tag.fetchOrCreate(named: newTagName, in: modelContext)
        newTagName = ""
    }

    private func delete(_ tag: Tag) {
        modelContext.delete(tag)
    }
}

#Preview {
    TagList()
        .modelContainer(PreviewSamples.container)
}
