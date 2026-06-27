//
//  LedgerDataStore.swift
//  goodoldledgerapp
//

import Foundation
import SwiftData

enum LedgerDataStore {
    static let shared: ModelContainer = {
        let schema = Schema([LedgerEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @MainActor
    @discardableResult
    static func addEntry(
        type: EntryType,
        amount: Double,
        category: String,
        note: String = ""
    ) throws -> LedgerEntry {
        let context = ModelContext(shared)
        let entry = LedgerEntry(
            type: type,
            amount: amount,
            category: category,
            note: note
        )
        context.insert(entry)
        try context.save()
        return entry
    }
}
