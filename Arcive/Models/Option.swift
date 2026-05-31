//
//  Option.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import Foundation
import SwiftData

@Model
final class Option {
    var title: String = ""
    var detail: String = ""
    var pros: String = ""
    var cons: String = ""
    var wasChosen: Bool = false
    var decision: Decision?

    init(title: String) { self.title = title }
}
