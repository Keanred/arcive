//
//  DecisionDetail.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import SwiftUI
import SwiftData

struct DecisionDetail: View {
    var decision: Decision?

    var body: some View {
        if let decision {
            VStack(alignment: .leading, spacing: 12) {
                Text("ADR-\(decision.number): \(decision.title)")
                    .font(.title)
                Text(decision.status.label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Divider()
                if !decision.context.isEmpty {
                    Text("Context").font(.headline)
                    Text(decision.context)
                }
                if !decision.rationale.isEmpty {
                    Text("Rationale").font(.headline)
                    Text(decision.rationale)
                }
                if !decision.consequences.isEmpty {
                    Text("Consequences").font(.headline)
                    Text(decision.consequences)
                }
                Spacer()
            }
            .padding()
        } else {
            Text("Select a decision")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSamples.container)
}
