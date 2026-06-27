//
//  LedgerView.swift
//  goodoldledgerapp
//

import SwiftUI
import SwiftData
import Observation

struct LedgerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PeriodFilterStore.self) private var periodFilter
    @Query(sort: \LedgerEntry.date, order: .reverse) private var allEntries: [LedgerEntry]

    @State private var sheetType: EntryType?
    @State private var exportedFile: ExportedCSVFile?
    @State private var showExportAlert = false
    @State private var exportAlertMessage = ""

    private var filteredHistory: [LedgerEntry] {
        periodFilter.filter(allEntries)
    }

    private func entries(for type: EntryType) -> [LedgerEntry] {
        allEntries
            .filter { $0.type == type }
            .sorted { $0.date > $1.date }
    }

    private func total(for type: EntryType) -> Double {
        entries(for: type).reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Good Old Ledger")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    balanceSummary

                    ForEach(EntryType.allCases) { type in
                        LedgerSectionCard(
                            type: type,
                            total: total(for: type),
                            entries: entries(for: type),
                            onAdd: { sheetType = type },
                            onDeleteEntry: deleteEntry
                        )
                    }

                    historySection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $sheetType) { type in
                AddEntrySheet(entryType: type)
            }
            .sheet(item: $exportedFile) { file in
                ShareSheet(items: [CSVActivityItem(url: file.url)])
            }
            .alert("Export Failed", isPresented: $showExportAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(exportAlertMessage)
            }
        }
    }

    private var balanceSummary: some View {
        let income = total(for: .income)
        let expense = total(for: .expense)
        let deposits = total(for: .deposit)
        let net = income - expense

        return VStack(spacing: 8) {
            Text("Net Balance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(Formatters.currencyString(net))
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(net >= 0 ? Theme.income : Theme.expense)

            HStack(spacing: 16) {
                summaryPill(label: "Deposits", value: deposits, color: Theme.deposit)
                summaryPill(label: "Saved", value: net - deposits, color: .secondary)
            }
            .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func summaryPill(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(Formatters.currencyString(value))
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .monospacedDigit()
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("History", systemImage: "clock.arrow.circlepath")
                    .font(.headline)

                Spacer()

                Button(action: exportFilteredHistory) {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderless)
                .disabled(filteredHistory.isEmpty)
            }

            PeriodFilterPicker()

            if filteredHistory.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "tray",
                    description: Text("No entries for \(periodFilter.periodLabel).")
                )
                .frame(minHeight: 160)
            } else {
                List {
                    ForEach(filteredHistory, id: \.id) { entry in
                        HistoryRow(entry: entry, onDelete: { deleteEntry(entry) })
                            .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteEntry(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .frame(height: historyListHeight)
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var historyListHeight: CGFloat {
        CGFloat(filteredHistory.count) * 76
    }

    private func deleteEntry(_ entry: LedgerEntry) {
        withAnimation {
            modelContext.delete(entry)
        }
    }

    private func exportFilteredHistory() {
        do {
            let fileURL = try CSVExporter.exportForSharing(entries: filteredHistory)
            exportedFile = ExportedCSVFile(url: fileURL)
        } catch {
            exportAlertMessage = "Could not export CSV: \(error.localizedDescription)"
            showExportAlert = true
        }
    }
}

#Preview {
    LedgerView()
        .environment(PeriodFilterStore())
        .modelContainer(for: LedgerEntry.self, inMemory: true)
}
