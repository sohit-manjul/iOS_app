//
//  goodoldledgerappApp.swift
//  goodoldledgerapp
//
//  Created by Sohit Manjul on 27/06/26.
//

import SwiftUI
import SwiftData

@main
struct goodoldledgerappApp: App {
    var sharedModelContainer: ModelContainer = LedgerDataStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
