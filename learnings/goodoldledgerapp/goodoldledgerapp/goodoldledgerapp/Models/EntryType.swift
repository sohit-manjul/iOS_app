//
//  EntryType.swift
//  goodoldledgerapp
//

import Foundation

enum EntryType: String, Codable, CaseIterable, Identifiable {
    case income
    case expense
    case deposit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .income: "Income"
        case .expense: "Expense"
        case .deposit: "Deposits"
        }
    }

    var icon: String {
        switch self {
        case .income: "arrow.down.circle.fill"
        case .expense: "arrow.up.circle.fill"
        case .deposit: "banknote.fill"
        }
    }

    var accentColorName: String {
        switch self {
        case .income: "IncomeGreen"
        case .expense: "ExpenseRed"
        case .deposit: "DepositBlue"
        }
    }

    static let defaultCategories: [EntryType: [String]] = [
        .income: ["Salary", "Freelance", "Investment", "Gift", "Other"],
        .expense: ["Food", "Transport", "Shopping", "Bills", "Health", "Entertainment", "Other"],
        .deposit: ["Savings", "Emergency Fund", "Investment", "Retirement", "Other"],
    ]
}
