//
//  PeriodFilterPicker.swift
//  goodoldledgerapp
//

import SwiftUI
import SwiftData
import Observation

struct PeriodFilterPicker: View {
    @Environment(PeriodFilterStore.self) private var periodFilter
    @Query(sort: \LedgerEntry.date, order: .reverse) private var allEntries: [LedgerEntry]

    var body: some View {
        @Bindable var periodFilter = periodFilter

        VStack(spacing: 10) {
            Picker("Period", selection: $periodFilter.period) {
                ForEach(TimePeriodFilter.allCases) { period in
                    Text(period.title).tag(period)
                }
            }
            .pickerStyle(.segmented)

            if !allEntries.isEmpty {
                periodSelector
            }

            if !allEntries.isEmpty {
                Text(periodFilter.rangeDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear {
            periodFilter.syncReferenceDate(with: allEntries)
        }
        .onChange(of: allEntries.count) { _, _ in
            periodFilter.syncReferenceDate(with: allEntries)
        }
        .onChange(of: periodFilter.period) { _, _ in
            periodFilter.syncReferenceDate(with: allEntries)
        }
        .onChange(of: availableWeeks.count) { _, _ in
            periodFilter.syncReferenceDate(with: allEntries)
        }
    }

    @ViewBuilder
    private var periodSelector: some View {
        switch periodFilter.period {
        case .week:
            weekSelector
        case .month:
            monthSelector
        case .year:
            yearSelector
        }
    }

    private var availableWeeks: [Date] {
        periodFilter.availableReferences(for: .week, entries: allEntries)
    }

    private var availableYears: [Int] {
        periodFilter.availableYears(from: allEntries)
    }

    private var availableMonths: [Int] {
        periodFilter.availableMonths(for: periodFilter.selectedYear, entries: allEntries)
    }

    private var weekSelector: some View {
        HStack(spacing: 12) {
            stepButton(direction: -1)

            Picker("Week", selection: weekIDBinding) {
                ForEach(availableWeeks, id: \.timeIntervalSince1970) { week in
                    Text(TimePeriodFilter.week.rangeDescription(reference: week))
                        .tag(week.timeIntervalSince1970)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)

            stepButton(direction: 1)
        }
    }

    private var monthSelector: some View {
        HStack(spacing: 12) {
            stepButton(direction: -1)

            Picker("Month", selection: monthBinding) {
                ForEach(availableMonths, id: \.self) { month in
                    Text(Calendar.current.shortMonthSymbols[month - 1]).tag(month)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)

            Picker("Year", selection: yearBinding) {
                ForEach(availableYears, id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.menu)

            stepButton(direction: 1)
        }
    }

    private var yearSelector: some View {
        HStack(spacing: 12) {
            stepButton(direction: -1)

            Picker("Year", selection: yearBinding) {
                ForEach(availableYears, id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)

            stepButton(direction: 1)
        }
    }

    private func stepButton(direction: Int) -> some View {
        Button {
            periodFilter.stepPeriod(by: direction, entries: allEntries)
        } label: {
            Image(systemName: direction < 0 ? "chevron.left" : "chevron.right")
                .font(.body.weight(.semibold))
                .frame(width: 36, height: 36)
                .background(.quaternary.opacity(0.5), in: Circle())
        }
        .buttonStyle(.plain)
        .disabled(!periodFilter.canStep(by: direction, entries: allEntries))
    }

    private var weekIDBinding: Binding<TimeInterval> {
        Binding(
            get: { periodFilter.matchingWeekID(in: availableWeeks) },
            set: { periodFilter.setReferenceDate(fromWeekID: $0, entries: allEntries) }
        )
    }

    private var monthBinding: Binding<Int> {
        Binding(
            get: { periodFilter.selectedMonth },
            set: { periodFilter.selectedMonth = $0 }
        )
    }

    private var yearBinding: Binding<Int> {
        Binding(
            get: { periodFilter.selectedYear },
            set: { newYear in
                periodFilter.selectedYear = newYear
                periodFilter.syncReferenceDate(with: allEntries)
            }
        )
    }
}
