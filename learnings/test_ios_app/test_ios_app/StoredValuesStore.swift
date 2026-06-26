//
//  StoredValuesStore.swift
//  test_ios_app
//

import Foundation
import Observation

struct StoredCalculation: Codable, Identifiable, Equatable {
    let id: UUID
    let value: String
    let storedAt: Date
}

@Observable
final class StoredValuesStore {
    private(set) var items: [StoredCalculation] = []

    private let fileURL: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent("stored_calculations.json")
        load()
    }

    func store(value: String) {
        guard value != "Error", Double(value) != nil else { return }

        let entry = StoredCalculation(id: UUID(), value: value, storedAt: Date())
        items.insert(entry, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            items.remove(at: index)
        }
        save()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            items = []
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            items = try JSONDecoder().decode([StoredCalculation].self, from: data)
        } catch {
            items = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Keep in-memory items even if write fails.
        }
    }
}
