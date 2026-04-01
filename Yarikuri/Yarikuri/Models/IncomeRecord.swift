import Foundation

// MARK: - 収入記録
struct IncomeRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var year: Int
    var month: Int
    var amount: Int
    var note: String = ""

    var displayLabel: String {
        "\(year)年\(month)月"
    }
}
