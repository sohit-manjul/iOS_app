//
//  AddEntrySheet.swift
//  goodoldledgerapp
//

import SwiftUI
import SwiftData

struct AddEntrySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let entryType: EntryType

    @State private var amountText = ""
    @State private var selectedCategory = ""
    @State private var customCategory = ""
    @State private var note = ""
    @State private var useCustomCategory = false

    private var categories: [String] {
        EntryType.defaultCategories[entryType] ?? []
    }

    private var resolvedCategory: String {
        useCustomCategory ? customCategory.trimmingCharacters(in: .whitespacesAndNewlines) : selectedCategory
    }

    private var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: ""))
    }

    private var isValid: Bool {
        guard let amount, amount > 0 else { return false }
        return !resolvedCategory.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.title3.monospacedDigit())
                    }
                } header: {
                    Label(entryType.title, systemImage: entryType.icon)
                        .foregroundStyle(Theme.color(for: entryType))
                }

                Section("Category") {
                    if useCustomCategory {
                        TextField("Enter category", text: $customCategory)
                    } else {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    Toggle("Custom category", isOn: $useCustomCategory)
                }

                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add \(entryType.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
            .onAppear {
                selectedCategory = categories.first ?? ""
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func saveEntry() {
        guard let amount, isValid else { return }

        let entry = LedgerEntry(
            type: entryType,
            amount: amount,
            category: resolvedCategory,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(entry)
        try? modelContext.save()

        ShortcutDonation.donate(
            type: entryType,
            amount: amount,
            category: resolvedCategory,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        dismiss()
    }
}

#Preview {
    AddEntrySheet(entryType: .income)
        .modelContainer(for: LedgerEntry.self, inMemory: true)
}
