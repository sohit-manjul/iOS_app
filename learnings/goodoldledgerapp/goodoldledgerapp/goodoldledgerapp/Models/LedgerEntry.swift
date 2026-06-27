//
//  LedgerEntry.swift
//  goodoldledgerapp
//

import Foundation
import SwiftData

@Model
final class LedgerEntry {
    var id: UUID
    var typeRaw: String
    var amount: Double
    var category: String
    var note: String
    var date: Date

    var type: EntryType {
        get { EntryType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    init(
        type: EntryType,
        amount: Double,
        category: String,
        note: String = "",
        date: Date = .now
    ) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
    }
}
