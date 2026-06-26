//
//  CalculatorView.swift
//  test_ios_app
//

import SwiftUI

struct CalculatorView: View {
    @Environment(StoredValuesStore.self) private var storedValuesStore

    @State private var display = "0"
    @State private var storedValue: Double?
    @State private var pendingOperation: Operation?
    @State private var isFreshInput = true

    private enum Operation {
        case add, subtract, multiply, divide

        func apply(_ lhs: Double, _ rhs: Double) -> Double? {
            switch self {
            case .add: return lhs + rhs
            case .subtract: return lhs - rhs
            case .multiply: return lhs * rhs
            case .divide:
                guard rhs != 0 else { return nil }
                return lhs / rhs
            }
        }

        var symbol: String {
            switch self {
            case .add: return "+"
            case .subtract: return "−"
            case .multiply: return "×"
            case .divide: return "÷"
            }
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            HStack(alignment: .center, spacing: 12) {
                Text(display)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Button(action: storeCurrentValue) {
                    Text("Store")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(white: 0.35))
                        .clipShape(Capsule())
                }
                .disabled(display == "Error" || Double(display) == nil)
            }
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                CalculatorButton(title: "C", style: .function, action: clear)

                HStack(spacing: 12) {
                    CalculatorButton(title: "7", style: .digit, action: { inputDigit("7") })
                    CalculatorButton(title: "8", style: .digit, action: { inputDigit("8") })
                    CalculatorButton(title: "9", style: .digit, action: { inputDigit("9") })
                    CalculatorButton(title: Operation.divide.symbol, style: .operation, action: { setOperation(.divide) })
                }

                HStack(spacing: 12) {
                    CalculatorButton(title: "4", style: .digit, action: { inputDigit("4") })
                    CalculatorButton(title: "5", style: .digit, action: { inputDigit("5") })
                    CalculatorButton(title: "6", style: .digit, action: { inputDigit("6") })
                    CalculatorButton(title: Operation.multiply.symbol, style: .operation, action: { setOperation(.multiply) })
                }

                HStack(spacing: 12) {
                    CalculatorButton(title: "1", style: .digit, action: { inputDigit("1") })
                    CalculatorButton(title: "2", style: .digit, action: { inputDigit("2") })
                    CalculatorButton(title: "3", style: .digit, action: { inputDigit("3") })
                    CalculatorButton(title: Operation.subtract.symbol, style: .operation, action: { setOperation(.subtract) })
                }

                HStack(spacing: 12) {
                    CalculatorButton(title: "0", style: .digit, action: { inputDigit("0") })
                    CalculatorButton(title: ".", style: .digit, action: inputDecimal)
                    CalculatorButton(title: Operation.add.symbol, style: .operation, action: { setOperation(.add) })
                    CalculatorButton(title: "=", style: .equals, action: calculate)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .background(Color.black)
    }

    private var currentValue: Double {
        Double(display) ?? 0
    }

    private func storeCurrentValue() {
        storedValuesStore.store(value: display)
    }

    private func inputDigit(_ digit: String) {
        if display == "Error" {
            display = digit
            isFreshInput = false
            return
        }

        if isFreshInput {
            display = digit
            isFreshInput = false
        } else if display == "0" {
            display = digit
        } else {
            display += digit
        }
    }

    private func inputDecimal() {
        if display == "Error" {
            display = "0."
            isFreshInput = false
            return
        }

        if isFreshInput {
            display = "0."
            isFreshInput = false
        } else if !display.contains(".") {
            display += "."
        }
    }

    private func clear() {
        display = "0"
        storedValue = nil
        pendingOperation = nil
        isFreshInput = true
    }

    private func setOperation(_ operation: Operation) {
        if display == "Error" {
            clear()
            return
        }

        if let stored = storedValue, let pending = pendingOperation, !isFreshInput {
            guard let result = pending.apply(stored, currentValue) else {
                display = "Error"
                storedValue = nil
                pendingOperation = nil
                isFreshInput = true
                return
            }
            display = format(result)
            storedValue = result
        } else {
            storedValue = currentValue
        }

        pendingOperation = operation
        isFreshInput = true
    }

    private func calculate() {
        guard display != "Error",
              let stored = storedValue,
              let operation = pendingOperation else { return }

        guard let result = operation.apply(stored, currentValue) else {
            display = "Error"
            storedValue = nil
            pendingOperation = nil
            isFreshInput = true
            return
        }

        display = format(result)
        storedValue = nil
        pendingOperation = nil
        isFreshInput = true
    }

    private func format(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(value)
    }
}

private struct CalculatorButton: View {
    enum Style {
        case digit, function, operation, equals
    }

    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(backgroundColor)
                .clipShape(Capsule())
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .digit: return Color(white: 0.2)
        case .function: return Color(white: 0.35)
        case .operation, .equals: return .orange
        }
    }
}

#Preview {
    CalculatorView()
        .environment(StoredValuesStore())
}
