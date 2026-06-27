//
//  Formatters.swift
//  goodoldledgerapp
//

import Foundation

enum Formatters {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter
    }()

    static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    nonisolated static func currencyString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
    }

    nonisolated static func dateString(_ value: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: value)
    }
}
