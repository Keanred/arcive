//
//  DecisionStatus.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import Foundation

enum DecisionStatus: String, Codable, CaseIterable, Identifiable {
    case proposed, accepted, rejected, deprecated, superseded
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}
