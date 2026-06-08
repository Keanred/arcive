//
//  RootView.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.openWindow) private var openWindow
    @State private var selectedProject: Project?
    @State private var selectedDecision: Decision?

    var body: some View {
        NavigationSplitView {
            ProjectsSidebar(selection: $selectedProject)

        } content: {
            DecisionsContent(project: selectedProject, selection: $selectedDecision)

        } detail: {
            if let selectedDecision {
                DecisionDetail(decision: selectedDecision) { successor in
                    self.selectedDecision = successor
                    self.selectedProject = successor.project
                }
            } else {
                Text("Select a decision")
                    .foregroundStyle(.secondary)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Tags", systemImage: "tag") {
                    openWindow(id: "tags")
                }
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSamples.container)
}
