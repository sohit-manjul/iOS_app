//
//  HistoryRow.swift
//  goodoldledgerapp
//

import SwiftUI

struct HistoryRow: View {
    let entry: LedgerEntry
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.type.icon)
                .font(.title3)
                .foregroundStyle(Theme.color(for: entry.type))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.category)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(Formatters.currencyString(entry.amount))
                        .font(.subheadline.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(Theme.color(for: entry.type))
                }

                Text(Formatters.date.string(from: entry.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            if let onDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
