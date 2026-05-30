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
            Text("\(project.name)")
                .tag(project)
                .listRowInsets(EdgeInsets(top: 0, leading: 1, bottom: 0, trailing: 1))
                .listRowSeparator(.hidden)
        }
        Button("New Project", systemImage: "document.badge.plus.fill") {
            modelContext.insert(Project(name: "Test", detail: "hello"))
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSamples.container)
}
