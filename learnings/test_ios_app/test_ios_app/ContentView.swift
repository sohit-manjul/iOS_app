//
//  ContentView.swift
//  test_ios_app
//
//  Created by Sohit Manjul on 27/06/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CalculatorView()
                .tabItem {
                    Label("Calculator", systemImage: "plus.forwardslash.minus")
                }

            StoredValuesView()
                .tabItem {
                    Label("Stored", systemImage: "tray.full")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(StoredValuesStore())
}
