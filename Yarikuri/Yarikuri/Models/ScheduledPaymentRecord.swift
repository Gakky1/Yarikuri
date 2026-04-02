import Foundation

// MARK: - 支払い明細スナップショット
struct ScheduledPaymentSnapshot: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var amount: Int
}

// MARK: - 今月の支払いの月次履歴レコード
struct ScheduledPaymentMonthRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var year: Int
    var month: Int
    var totalAmount: Int
    var payments: [ScheduledPaymentSnapshot] = []

    var displayLabel: String { "\(year % 100)/\(month)" }
}
