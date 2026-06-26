//
//  StoredValuesView.swift
//  test_ios_app
//

import SwiftUI

struct StoredValuesView: View {
    @Environment(StoredValuesStore.self) private var storedValuesStore

    var body: some View {
        NavigationStack {
            Group {
                if storedValuesStore.items.isEmpty {
                    ContentUnavailableView(
                        "No Stored Values",
                        systemImage: "tray",
                        description: Text("Tap Store on the calculator to save a result.")
                    )
                } else {
                    List {
                        ForEach(storedValuesStore.items) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.value)
                                    .font(.title2.monospacedDigit())
                                Text(item.storedAt, format: .dateTime.month().day().year().hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: storedValuesStore.delete)
                    }
                }
            }
            .navigationTitle("Stored")
            .toolbar {
                if !storedValuesStore.items.isEmpty {
                    EditButton()
                }
            }
        }
    }
}

#Preview {
    StoredValuesView()
        .environment(StoredValuesStore())
}
