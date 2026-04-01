import Foundation

// MARK: - 固定費の月次履歴レコード
struct FixedExpenseMonthRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var year: Int
    var month: Int
    var totalAmount: Int

    var displayLabel: String { "\(year % 100)/\(month)" }
}
