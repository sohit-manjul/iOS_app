//
//  StatsView.swift
//  goodoldledgerapp
//

import SwiftUI
import SwiftData
import Observation
import Charts

struct StatsView: View {
    @Environment(PeriodFilterStore.self) private var periodFilter
    @Query private var allEntries: [LedgerEntry]

    private var entries: [LedgerEntry] {
        periodFilter.filter(allEntries)
    }

    private var incomeTotal: Double {
        entries.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    private var expenseTotal: Double {
        entries.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var depositTotal: Double {
        entries.filter { $0.type == .deposit }.reduce(0) { $0 + $1.amount }
    }

    private var netBalance: Double {
        incomeTotal - expenseTotal
    }

    private var expenseByCategory: [(category: String, amount: Double)] {
        Dictionary(grouping: entries.filter { $0.type == .expense }, by: \.category)
            .map { (category: $0.key, amount: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.amount > $1.amount }
    }

    private var typeBreakdown: [(type: EntryType, amount: Double)] {
        EntryType.allCases.map { type in
            let total = entries.filter { $0.type == type }.reduce(0) { $0 + $1.amount }
            return (type: type, amount: total)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Stats")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    PeriodFilterPicker()
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    if entries.isEmpty {
                        ContentUnavailableView(
                            "No Data Yet",
                            systemImage: "chart.bar",
                            description: Text("No entries for \(periodFilter.periodLabel).")
                        )
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 20) {
                            overviewCards
                            typeChart
                            if !expenseByCategory.isEmpty {
                                expenseBreakdown
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var overviewCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(title: "Income", value: incomeTotal, color: Theme.income, icon: "arrow.down.circle.fill")
            statCard(title: "Expenses", value: expenseTotal, color: Theme.expense, icon: "arrow.up.circle.fill")
            statCard(title: "Deposits", value: depositTotal, color: Theme.deposit, icon: "banknote.fill")
            statCard(title: "Net", value: netBalance, color: netBalance >= 0 ? Theme.income : Theme.expense, icon: "equal.circle.fill")
        }
    }

    private func statCard(title: String, value: Double, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(Formatters.currencyString(value))
                .font(.system(.title3, design: .rounded, weight: .bold))
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var typeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)

            Chart(typeBreakdown, id: \.type) { item in
                BarMark(
                    x: .value("Amount", item.amount),
                    y: .value("Type", item.type.title)
                )
                .foregroundStyle(Theme.color(for: item.type))
                .cornerRadius(4)
            }
            .frame(height: 140)
            .chartXAxis {
                AxisMarks(format: Decimal.FormatStyle.Currency(code: Locale.current.currency?.identifier ?? "USD"))
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var expenseBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expenses by Category")
                .font(.headline)

            ForEach(expenseByCategory, id: \.category) { item in
                let fraction = expenseTotal > 0 ? item.amount / expenseTotal : 0
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.category)
                            .font(.subheadline)
                        Spacer()
                        Text(Formatters.currencyString(item.amount))
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                    }
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Theme.expense.opacity(0.15))
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Theme.expense)
                                    .frame(width: geo.size.width * fraction)
                            }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    StatsView()
        .environment(PeriodFilterStore())
        .modelContainer(for: LedgerEntry.self, inMemory: true)
}
