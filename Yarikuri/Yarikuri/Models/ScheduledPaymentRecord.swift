import Foundation

// MARK: - 今月の支払いの月次履歴レコード
struct ScheduledPaymentMonthRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var year: Int
    var month: Int
    var totalAmount: Int

    var displayLabel: String { "\(year % 100)/\(month)" }
}
