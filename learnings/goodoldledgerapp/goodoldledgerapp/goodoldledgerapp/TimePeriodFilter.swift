//
//  TimePeriodFilter.swift
//  goodoldledgerapp
//

import Foundation

enum TimePeriodFilter: String, CaseIterable, Identifiable, Codable {
    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week: "Week"
        case .month: "Month"
        case .year: "Year"
        }
    }

    func dateRange(calendar: Calendar = .current, reference: Date = .now) -> Range<Date> {
        let component: Calendar.Component
        switch self {
        case .week: component = .weekOfYear
        case .month: component = .month
        case .year: component = .year
        }

        let interval = calendar.dateInterval(of: component, for: reference)!
        return interval.start..<interval.end
    }

    func contains(_ date: Date, calendar: Calendar = .current, reference: Date = .now) -> Bool {
        dateRange(calendar: calendar, reference: reference).contains(date)
    }

    func rangeDescription(calendar: Calendar = .current, reference: Date = .now) -> String {
        let range = dateRange(calendar: calendar, reference: reference)
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: range.lowerBound, to: range.upperBound.addingTimeInterval(-1))
    }

    func normalizedReference(calendar: Calendar = .current, date: Date = .now) -> Date {
        switch self {
        case .week:
            return calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        case .month:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
        case .year:
            return calendar.date(from: calendar.dateComponents([.year], from: date)) ?? date
        }
    }
}
