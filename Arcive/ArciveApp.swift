//
//  ArciveApp.swift
//  Arcive
//
//  Created by Anssi Keinänen on 29.5.2026.
//

import SwiftUI
import SwiftData

@main
struct ArciveApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Project.self, Decision.self, Option.self, Tag.self])
    }
}
