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
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: Project.self, Decision.self, Option.self, Tag.self
            )
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)

        Window("Tags", id: "tags") {
            TagList()
        }
        .defaultSize(width: 500, height: 400)
        .modelContainer(modelContainer)
    }
}
