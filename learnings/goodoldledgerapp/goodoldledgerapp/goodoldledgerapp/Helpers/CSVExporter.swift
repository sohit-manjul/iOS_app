//
//  CSVExporter.swift
//  goodoldledgerapp
//

import Foundation

enum CSVExporter {
    static func csvString(from entries: [LedgerEntry]) -> String {
        var lines = ["Date,Type,Category,Amount,Note"]

        for entry in entries {
            let date = Formatters.dateString(entry.date)
            let type = escapeCSV(entry.type.title)
            let category = escapeCSV(entry.category)
            let amount = String(format: "%.2f", entry.amount)
            let note = escapeCSV(entry.note)
            lines.append("\(date),\(type),\(category),\(amount),\(note)")
        }

        return lines.joined(separator: "\n")
    }

    static func exportForSharing(entries: [LedgerEntry]) throws -> URL {
        let csv = csvString(from: entries)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let timestamp = formatter.string(from: Date())
        let fileName = "goodoldledger_\(timestamp).csv"

        let directory = FileManager.default.temporaryDirectory
        let fileURL = directory.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }

        try Data(csv.utf8).write(to: fileURL, options: .atomic)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw ExportError.fileNotCreated
        }

        return fileURL
    }

    private static func escapeCSV(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"") || value.contains("\n") else {
            return value
        }
        return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }

    enum ExportError: LocalizedError {
        case fileNotCreated

        var errorDescription: String? {
            switch self {
            case .fileNotCreated:
                "The export file could not be created."
            }
        }
    }
}

struct ExportedCSVFile: Identifiable {
    let id = UUID()
    let url: URL
}
