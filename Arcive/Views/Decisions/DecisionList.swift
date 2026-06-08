//
//  DecisionList.swift
//  Arcive
//
//  Created by Anssi Keinänen on 5.6.2026.
//
import SwiftUI
import SwiftData

struct DecisionList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var decisions: [Decision]
    @Binding var selection: Decision?

    init(predicate: Predicate<Decision>,
         sort: [SortDescriptor<Decision>],
         selection: Binding<Decision?>) {
        _decisions = Query(filter: predicate, sort: sort)
        _selection = selection
    }

    var body: some View {
        List(decisions, selection: $selection) { decision in
            HStack {
                Text("\(decision.number)")
                Text(decision.title)
                Spacer()
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
                .accessibilityLabel(Text("Created at"))
            }
            .tag(decision)
            .swipeActions {
                Button(role: .destructive) {
                    modelContext.delete(decision)
                } label: {
                    Text("Delete")
                }
            }
            .contextMenu {
                Button(role: .destructive) {
                    modelContext.delete(decision)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .onDeleteCommand {
            guard let selected = selection else { return }
            selection = nil
            modelContext.delete(selected)
        }
    }
}
