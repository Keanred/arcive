import SwiftUI

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
