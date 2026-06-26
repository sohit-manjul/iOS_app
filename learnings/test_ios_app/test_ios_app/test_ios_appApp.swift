//
//  test_ios_appApp.swift
//  test_ios_app
//
//  Created by Sohit Manjul on 27/06/26.
//

import SwiftUI

@main
struct test_ios_appApp: App {
    @State private var storedValuesStore = StoredValuesStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(storedValuesStore)
        }
    }
}
