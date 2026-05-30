//
//  RootView.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @State private var selectedProject: Project?
    @State private var selectedDecision: Decision?

    var body: some View {
        NavigationSplitView {
            ProjectsSidebar(selection: $selectedProject)
        } content: {
            DecisionsContent(project: selectedProject, selection: $selectedDecision)
        } detail: {
            DecisionDetail(decision: selectedDecision)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSamples.container)
}
