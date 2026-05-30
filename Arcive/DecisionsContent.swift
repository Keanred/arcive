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
    @Query private var decisions: [Decision]
    var project: Project?
    @Binding var selection: Decision?

    init(project: Project?, selection: Binding<Decision?>) {
        self.project = project
        self._selection = selection
        let projectID = project?.persistentModelID
        _decisions = Query(filter: #Predicate { $0.project?.persistentModelID == projectID },
                           sort: \.number)
    }

    var body: some View {
        List(decisions, selection: $selection) { decision in
            HStack{
                Text("\(decision.number)")
                Text(decision.title)
                Text(decision.status.label)
                    .foregroundStyle(decision.status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(decision.status.color.opacity(0.15))
                    )
                Text(decision.createdAt, format: Date.VerbatimFormatStyle(
                    format: "\(day: .twoDigits)/\(month: .twoDigits)/\(year: .twoDigits)",
                    timeZone: .current,
                    calendar: .current
                ))
            }
            .tag(decision)
        }
        Button("New") {
            let decision = Decision(title: "New Decision", number: (decisions.last?.number ?? 0) + 1)
            decision.project = project
            modelContext.insert(decision)
        }
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
