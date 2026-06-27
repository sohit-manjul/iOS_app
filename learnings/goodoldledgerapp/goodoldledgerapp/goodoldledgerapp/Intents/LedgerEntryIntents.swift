//
//  LedgerEntryIntents.swift
//  goodoldledgerapp
//

import AppIntents
import Foundation

// MARK: - Category options

struct IncomeCategoryProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        EntryType.defaultCategories[.income] ?? []
    }

    func defaultResult() async -> String? { "Other" }
}

struct ExpenseCategoryProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        EntryType.defaultCategories[.expense] ?? []
    }

    func defaultResult() async -> String? { "Other" }
}

struct DepositCategoryProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        EntryType.defaultCategories[.deposit] ?? []
    }

    func defaultResult() async -> String? { "Other" }
}

// MARK: - Intents

struct AddIncomeIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Income"
    static var description = IntentDescription("Add an income entry to Good Old Ledger.")

    @Parameter(title: "Amount")
    var amount: Double

    @Parameter(title: "Category", optionsProvider: IncomeCategoryProvider())
    var category: String

    @Parameter(title: "Note")
    var note: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$amount) income for \(\.$category)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await MainActor.run {
            try saveLedgerEntry(type: .income, amount: amount, category: category, note: note)
        }
        return .result(dialog: "Added \(Formatters.currencyString(amount)) income for \(category).")
    }
}

struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Expense"
    static var description = IntentDescription("Add an expense entry to Good Old Ledger.")

    @Parameter(title: "Amount")
    var amount: Double

    @Parameter(title: "Category", optionsProvider: ExpenseCategoryProvider())
    var category: String

    @Parameter(title: "Note")
    var note: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$amount) expense for \(\.$category)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await MainActor.run {
            try saveLedgerEntry(type: .expense, amount: amount, category: category, note: note)
        }
        return .result(dialog: "Added \(Formatters.currencyString(amount)) expense for \(category).")
    }
}

struct AddDepositIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Deposit"
    static var description = IntentDescription("Add a deposit entry to Good Old Ledger.")

    @Parameter(title: "Amount")
    var amount: Double

    @Parameter(title: "Category", optionsProvider: DepositCategoryProvider())
    var category: String

    @Parameter(title: "Note")
    var note: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$amount) deposit for \(\.$category)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await MainActor.run {
            try saveLedgerEntry(type: .deposit, amount: amount, category: category, note: note)
        }
        return .result(dialog: "Added \(Formatters.currencyString(amount)) deposit for \(category).")
    }
}

// MARK: - Shared intent helpers

@MainActor
private func saveLedgerEntry(
    type: EntryType,
    amount: Double,
    category: String,
    note: String?
) throws {
    guard amount > 0 else {
        throw IntentError.invalidAmount
    }

    let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedCategory.isEmpty else {
        throw IntentError.missingCategory
    }

    try LedgerDataStore.addEntry(
        type: type,
        amount: amount,
        category: trimmedCategory,
        note: note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    )
}

private enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case invalidAmount
    case missingCategory

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .invalidAmount:
            "Please provide an amount greater than zero."
        case .missingCategory:
            "Please provide a category."
        }
    }
}

// MARK: - Siri shortcuts

struct GoodOldLedgerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddIncomeIntent(),
            phrases: [
                "Add income in \(.applicationName)",
                "Log income in \(.applicationName)",
                "Record income with \(.applicationName)",
            ],
            shortTitle: "Add Income",
            systemImageName: "arrow.down.circle.fill"
        )

        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "Add expense in \(.applicationName)",
                "Log expense in \(.applicationName)",
                "Record spending in \(.applicationName)",
            ],
            shortTitle: "Add Expense",
            systemImageName: "arrow.up.circle.fill"
        )

        AppShortcut(
            intent: AddDepositIntent(),
            phrases: [
                "Add deposit in \(.applicationName)",
                "Log deposit in \(.applicationName)",
                "Save money in \(.applicationName)",
            ],
            shortTitle: "Add Deposit",
            systemImageName: "banknote.fill"
        )
    }
}

// MARK: - Shortcut donation

enum ShortcutDonation {
    static func donate(type: EntryType, amount: Double, category: String, note: String) {
        Task {
            switch type {
            case .income:
                await donateIntent(makeIncomeIntent(amount: amount, category: category, note: note))
            case .expense:
                await donateIntent(makeExpenseIntent(amount: amount, category: category, note: note))
            case .deposit:
                await donateIntent(makeDepositIntent(amount: amount, category: category, note: note))
            }
        }
    }

    private static func makeIncomeIntent(amount: Double, category: String, note: String) -> AddIncomeIntent {
        let intent = AddIncomeIntent()
        intent.amount = amount
        intent.category = category
        intent.note = note.isEmpty ? nil : note
        return intent
    }

    private static func makeExpenseIntent(amount: Double, category: String, note: String) -> AddExpenseIntent {
        let intent = AddExpenseIntent()
        intent.amount = amount
        intent.category = category
        intent.note = note.isEmpty ? nil : note
        return intent
    }

    private static func makeDepositIntent(amount: Double, category: String, note: String) -> AddDepositIntent {
        let intent = AddDepositIntent()
        intent.amount = amount
        intent.category = category
        intent.note = note.isEmpty ? nil : note
        return intent
    }

    private static func donateIntent<I: AppIntent>(_ intent: I) async {
        _ = try? await intent.donate()
    }
}
