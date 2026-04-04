import Foundation

// MARK: - 収入カテゴリ
enum IncomeCategory: String, Codable, CaseIterable {
    case salary    = "salary"
    case bonus     = "bonus"
    case sideJob   = "sideJob"
    case investment = "investment"
    case other     = "other"

    var displayText: String {
        switch self {
        case .salary:     return "給与・手取り"
        case .bonus:      return "ボーナス"
        case .sideJob:    return "副業・フリーランス"
        case .investment: return "投資・配当"
        case .other:      return "その他"
        }
    }

    var emoji: String {
        switch self {
        case .salary:     return "💴"
        case .bonus:      return "🎁"
        case .sideJob:    return "💻"
        case .investment: return "📈"
        case .other:      return "💰"
        }
    }
}

// MARK: - 収入記録
struct IncomeRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var year: Int
    var month: Int
    var day: Int = 1
    var amount: Int
    var name: String = ""
    var category: IncomeCategory = .salary
    var note: String = ""

    var displayLabel: String {
        "\(year)年\(month)月"
    }
}
