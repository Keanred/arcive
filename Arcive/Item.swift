//
//  Item.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
