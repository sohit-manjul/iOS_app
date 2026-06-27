//
//  ContentView.swift
//  goodoldledgerapp
//
//  Created by Sohit Manjul on 27/06/26.
//

import SwiftUI
import SwiftData
import Observation

struct ContentView: View {
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.light.rawValue
    @State private var periodFilter = PeriodFilterStore()

    private var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceRaw) ?? .light
    }

    var body: some View {
        VStack(spacing: 0) {
            AppearanceToggleBar()

            TabView {
                LedgerView()
                    .tabItem {
                        Label("Ledger", systemImage: "book.closed.fill")
                    }

                StatsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }

                InsightsView()
                    .tabItem {
                        Label("Insights", systemImage: "sparkles")
                    }
            }
        }
        .environment(periodFilter)
        .preferredColorScheme(appearance.colorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LedgerEntry.self, inMemory: true)
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var icon: String {
        switch self {
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }
}

struct AppearanceToggleBar: View {
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.light.rawValue

    var body: some View {
        HStack {
            Spacer()
            Picker("Appearance", selection: $appearanceRaw) {
                ForEach(AppAppearance.allCases) { mode in
                    Label(mode.title, systemImage: mode.icon)
                        .tag(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 220)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }
}
