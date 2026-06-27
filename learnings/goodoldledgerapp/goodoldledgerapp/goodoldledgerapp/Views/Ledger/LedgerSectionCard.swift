//
//  LedgerSectionCard.swift
//  goodoldledgerapp
//

import SwiftUI

struct LedgerSectionCard: View {
    let type: EntryType
    let total: Double
    let entries: [LedgerEntry]
    let onAdd: () -> Void
    var onDeleteEntry: ((LedgerEntry) -> Void)?

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(type.title, systemImage: type.icon)
                    .font(.headline)
                    .foregroundStyle(Theme.color(for: type))

                Spacer()

                Button(action: onAdd) {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderless)
                .foregroundStyle(Theme.color(for: type))
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Formatters.currencyString(total))
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(.primary)

                        Text(entries.isEmpty ? "No entries yet" : entryCountLabel)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if !entries.isEmpty {
                        Image(systemName: "chevron.down")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(entries.isEmpty)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(entries, id: \.id) { entry in
                        sectionEntryRow(entry)
                        if entry.id != entries.last?.id {
                            Divider()
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Theme.color(for: type).opacity(0.2), lineWidth: 1)
        }
    }

    private var entryCountLabel: String {
        let count = entries.count
        return count == 1 ? "1 entry" : "\(count) entries"
    }

    private func sectionEntryRow(_ entry: LedgerEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.category)
                    .font(.subheadline.weight(.medium))
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
            Spacer()
            Text(Formatters.currencyString(entry.amount))
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
        .padding(.vertical, 8)
        .contextMenu {
            if let onDeleteEntry {
                Button(role: .destructive) {
                    onDeleteEntry(entry)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
