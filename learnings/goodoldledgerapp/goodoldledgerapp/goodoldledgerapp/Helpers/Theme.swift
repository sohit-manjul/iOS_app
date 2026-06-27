//
//  Theme.swift
//  goodoldledgerapp
//

import SwiftUI

enum Theme {
    static let income = Color.green
    static let expense = Color.red
    static let deposit = Color.blue

    static func color(for type: EntryType) -> Color {
        switch type {
        case .income: income
        case .expense: expense
        case .deposit: deposit
        }
    }
}
