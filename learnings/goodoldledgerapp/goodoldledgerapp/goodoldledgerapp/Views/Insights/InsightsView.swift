//
//  InsightsView.swift
//  goodoldledgerapp
//

import SwiftUI
import SwiftData
import Observation

struct InsightsView: View {
    @Environment(PeriodFilterStore.self) private var periodFilter
    @Query(sort: \LedgerEntry.date, order: .reverse) private var allEntries: [LedgerEntry]

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

    private var insights: [Insight] {
        var results: [Insight] = []
        let periodLabel = periodFilter.periodLabel

        if entries.isEmpty {
            return [Insight(
                icon: "lightbulb.fill",
                title: "No Data",
                message: "No entries for \(periodLabel). Try a different period or add new entries.",
                color: .orange
            )]
        }

        if incomeTotal > 0 {
            let savingsRate = ((incomeTotal - expenseTotal) / incomeTotal) * 100
            let savingsIcon = savingsRate >= 20 ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
            let savingsColor: Color = savingsRate >= 20 ? Theme.income : .orange
            results.append(Insight(
                icon: savingsIcon,
                title: "Savings Rate",
                message: String(format: "%@ you're saving %.0f%% of your income. %@", periodLabel.capitalized, savingsRate, savingsRate >= 20 ? "Great job!" : "Try to aim for at least 20%."),
                color: savingsColor
            ))
        }

        if let topExpense = topCategory(for: .expense) {
            results.append(Insight(
                icon: "cart.fill",
                title: "Top Expense",
                message: "Your biggest spending category \(periodLabel) is \(topExpense.category) at \(Formatters.currencyString(topExpense.amount)).",
                color: Theme.expense
            ))
        }

        if let topIncome = topCategory(for: .income) {
            results.append(Insight(
                icon: "dollarsign.circle.fill",
                title: "Top Income Source",
                message: "Most of your income \(periodLabel) comes from \(topIncome.category) — \(Formatters.currencyString(topIncome.amount)).",
                color: Theme.income
            ))
        }

        if depositTotal > 0, incomeTotal > 0 {
            let depositRate = (depositTotal / incomeTotal) * 100
            results.append(Insight(
                icon: "building.columns.fill",
                title: "Deposit Habits",
                message: String(format: "%@ you've deposited %.0f%% of your income into savings or investments.", periodLabel.capitalized, depositRate),
                color: Theme.deposit
            ))
        }

        let recentExpenses = entries.filter { $0.type == .expense }.prefix(7)
        if recentExpenses.count >= 3 {
            let recentTotal = recentExpenses.reduce(0) { $0 + $1.amount }
            let avg = recentTotal / Double(recentExpenses.count)
            results.append(Insight(
                icon: "chart.line.uptrend.xyaxis",
                title: "Recent Spending",
                message: "Your average expense \(periodLabel) is \(Formatters.currencyString(avg)) per transaction.",
                color: .purple
            ))
        }

        let net = incomeTotal - expenseTotal
        if net < 0 {
            results.append(Insight(
                icon: "exclamationmark.circle.fill",
                title: "Spending Alert",
                message: "Your expenses exceed income by \(Formatters.currencyString(abs(net))) \(periodLabel). Review your spending categories.",
                color: Theme.expense
            ))
        } else if net > 0 {
            results.append(Insight(
                icon: "hand.thumbsup.fill",
                title: "Healthy Balance",
                message: "You're earning more than you spend \(periodLabel). Consider increasing your deposits.",
                color: Theme.income
            ))
        }

        return results
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Insights")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    PeriodFilterPicker()
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    if entries.isEmpty {
                        ContentUnavailableView(
                            "No Insights Yet",
                            systemImage: "sparkles",
                            description: Text("No entries for \(periodFilter.periodLabel).")
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(insights) { insight in
                                InsightCard(insight: insight)
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

    private func topCategory(for type: EntryType) -> (category: String, amount: Double)? {
        let grouped = Dictionary(grouping: entries.filter { $0.type == type }, by: \.category)
        guard let top = grouped.max(by: { $0.value.reduce(0) { $0 + $1.amount } < $1.value.reduce(0) { $0 + $1.amount } }) else {
            return nil
        }
        let amount = top.value.reduce(0) { $0 + $1.amount }
        return (category: top.key, amount: amount)
    }
}

private struct Insight: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let message: String
    let color: Color
}

private struct InsightCard: View {
    let insight: Insight

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: insight.icon)
                .font(.title2)
                .foregroundStyle(insight.color)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.headline)
                Text(insight.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    InsightsView()
        .environment(PeriodFilterStore())
        .modelContainer(for: LedgerEntry.self, inMemory: true)
}
