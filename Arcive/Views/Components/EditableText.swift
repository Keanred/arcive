import SwiftUI

struct EditableText: View {
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
