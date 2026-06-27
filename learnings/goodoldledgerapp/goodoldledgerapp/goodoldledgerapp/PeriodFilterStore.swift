//
//  PeriodFilterStore.swift
//  goodoldledgerapp
//

import Foundation
import Observation

@Observable
final class PeriodFilterStore {
    private static let periodKey = "timePeriodFilter"
    private static let referenceDateKey = "timePeriodReferenceDate"
    private static let calendar = Calendar.current

    var period: TimePeriodFilter {
        didSet {
            UserDefaults.standard.set(period.rawValue, forKey: Self.periodKey)
            setReferenceDate(referenceDate)
        }
    }

    private(set) var referenceDate: Date

    init() {
        let raw = UserDefaults.standard.string(forKey: Self.periodKey) ?? TimePeriodFilter.month.rawValue
        let loadedPeriod = TimePeriodFilter(rawValue: raw) ?? .month

        let storedReference = UserDefaults.standard.object(forKey: Self.referenceDateKey) as? Date ?? .now
        period = loadedPeriod
        referenceDate = loadedPeriod.normalizedReference(date: storedReference)
    }

    var selectedMonth: Int {
        get { Self.calendar.component(.month, from: referenceDate) }
        set { setMonthYear(month: newValue, year: selectedYear) }
    }

    var selectedYear: Int {
        get { Self.calendar.component(.year, from: referenceDate) }
        set {
            switch period {
            case .month:
                setMonthYear(month: selectedMonth, year: newValue)
            case .year:
                setYear(newValue)
            case .week:
                break
            }
        }
    }

    var rangeDescription: String {
        period.rangeDescription(reference: referenceDate)
    }

    var periodLabel: String {
        switch period {
        case .week:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let start = period.dateRange(reference: referenceDate).lowerBound
            return "the week of \(formatter.string(from: start))"
        case .month:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return "in \(formatter.string(from: referenceDate))"
        case .year:
            return "in \(selectedYear)"
        }
    }

    func filter(_ entries: [LedgerEntry]) -> [LedgerEntry] {
        let range = period.dateRange(reference: referenceDate)
        return entries.filter { range.contains($0.date) }
    }

    func availableReferences(for period: TimePeriodFilter, entries: [LedgerEntry]) -> [Date] {
        guard !entries.isEmpty else { return [] }

        let starts = entries.map { period.normalizedReference(date: $0.date) }
        var unique: [Date] = []
        for start in starts {
            if !unique.contains(where: { Self.isSamePeriod($0, start, period: period) }) {
                unique.append(start)
            }
        }
        return unique.sorted(by: >)
    }

    func availableYears(from entries: [LedgerEntry]) -> [Int] {
        guard !entries.isEmpty else { return [] }

        let years = entries.map { Self.calendar.component(.year, from: $0.date) }
        return Array(Set(years)).sorted(by: >)
    }

    func availableMonths(for year: Int, entries: [LedgerEntry]) -> [Int] {
        guard !entries.isEmpty else { return [] }

        let months = entries.compactMap { entry -> Int? in
            let yearComponent = Self.calendar.component(.year, from: entry.date)
            guard yearComponent == year else { return nil }
            return Self.calendar.component(.month, from: entry.date)
        }
        return Array(Set(months)).sorted()
    }

    func syncReferenceDate(with entries: [LedgerEntry]) {
        let available = availableReferences(for: period, entries: entries)
        guard !available.isEmpty else { return }

        let current = period.normalizedReference(date: referenceDate)
        if let match = available.first(where: { Self.isSamePeriod($0, current, period: period) }) {
            referenceDate = match
            UserDefaults.standard.set(referenceDate, forKey: Self.referenceDateKey)
            if period == .month {
                syncMonthForSelectedYear(entries: entries)
            }
            return
        }

        setReferenceDate(available[0])

        if period == .month {
            syncMonthForSelectedYear(entries: entries)
        }
    }

    func setReferenceDate(_ date: Date) {
        referenceDate = period.normalizedReference(date: date)
        UserDefaults.standard.set(referenceDate, forKey: Self.referenceDateKey)
    }

    func stepPeriod(by value: Int, entries: [LedgerEntry]) {
        let available = availableReferences(for: period, entries: entries).sorted()
        guard !available.isEmpty else { return }

        let current = period.normalizedReference(date: referenceDate)
        let currentIndex = available.firstIndex(where: { Self.isSamePeriod($0, current, period: period) })
            ?? max(available.count - 1, 0)
        let targetIndex = currentIndex + value
        guard available.indices.contains(targetIndex) else { return }

        referenceDate = available[targetIndex]
        UserDefaults.standard.set(referenceDate, forKey: Self.referenceDateKey)
    }

    func canStep(by value: Int, entries: [LedgerEntry]) -> Bool {
        let available = availableReferences(for: period, entries: entries).sorted()
        guard !available.isEmpty else { return false }

        let current = period.normalizedReference(date: referenceDate)
        let currentIndex = available.firstIndex(where: { Self.isSamePeriod($0, current, period: period) })
            ?? max(available.count - 1, 0)
        return available.indices.contains(currentIndex + value)
    }

    func matchingWeekID(in available: [Date]) -> TimeInterval {
        let current = TimePeriodFilter.week.normalizedReference(date: referenceDate)
        if let match = available.first(where: { Self.isSamePeriod($0, current, period: .week) }) {
            return match.timeIntervalSince1970
        }
        return available.first?.timeIntervalSince1970 ?? current.timeIntervalSince1970
    }

    func setReferenceDate(fromWeekID weekID: TimeInterval, entries: [LedgerEntry]) {
        let available = availableReferences(for: .week, entries: entries)
        if let match = available.first(where: { $0.timeIntervalSince1970 == weekID }) {
            referenceDate = match
            UserDefaults.standard.set(referenceDate, forKey: Self.referenceDateKey)
        } else {
            setReferenceDate(Date(timeIntervalSince1970: weekID))
        }
    }

    private static func isSamePeriod(_ lhs: Date, _ rhs: Date, period: TimePeriodFilter) -> Bool {
        let calendar = calendar
        let left = period.normalizedReference(date: lhs)
        let right = period.normalizedReference(date: rhs)

        switch period {
        case .week:
            return calendar.isDate(left, equalTo: right, toGranularity: .weekOfYear)
        case .month:
            return calendar.isDate(left, equalTo: right, toGranularity: .month)
        case .year:
            return calendar.isDate(left, equalTo: right, toGranularity: .year)
        }
    }

    private func setMonthYear(month: Int, year: Int) {
        guard let date = Self.calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return
        }
        setReferenceDate(date)
    }

    private func setYear(_ year: Int) {
        guard let date = Self.calendar.date(from: DateComponents(year: year, month: 1, day: 1)) else {
            return
        }
        setReferenceDate(date)
    }

    private func syncMonthForSelectedYear(entries: [LedgerEntry]) {
        let months = availableMonths(for: selectedYear, entries: entries)
        guard !months.isEmpty, !months.contains(selectedMonth) else { return }
        setMonthYear(month: months.last ?? selectedMonth, year: selectedYear)
    }
}
