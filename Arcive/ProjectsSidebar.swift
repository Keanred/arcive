//
//  ProjectsSidebar.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import SwiftUI
import SwiftData

struct ProjectsSidebar: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @Binding var selection: Project?

    var body: some View {
        Text("Projects").padding(.horizontal)
        List(projects, selection: $selection) { project in
            @Bindable var project = project
            TextField("Name", text: $project.name)
                .textFieldStyle(.plain)
                .tag(project)
                .listRowInsets(EdgeInsets(top: 0, leading: 1, bottom: 0, trailing: 1))
                .listRowSeparator(.hidden)
                .swipeActions {
                    Button(role: .destructive) {
                        delete(project)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .contextMenu {
                    Button(role: .destructive) {
                        delete(project)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .onDeleteCommand {
            guard let selected = selection else { return }
            delete(selected)
        }
        Button("New Project", systemImage: "document.badge.plus.fill") {
            addProject()
        }
    }
    
    private func addProject() {
        let project = Project(name: "New project")
        modelContext.insert(project)
        selection = project
    }
    
    private func delete(_ project: Project) {
        if selection == project { selection = nil }
        modelContext.delete(project)
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSamples.container)
}
