import SwiftUI
import SwiftData

struct OptionRow: View {
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
