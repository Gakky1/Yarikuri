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
struct IncomeRecord: Identifiable, Encodable {
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

// 旧データ（day/name/category なし）との互換デコード
extension IncomeRecord: Decodable {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id       = (try? c.decodeIfPresent(UUID.self,           forKey: .id))      ?? UUID()
        year     = try c.decode(Int.self,                        forKey: .year)
        month    = try c.decode(Int.self,                        forKey: .month)
        day      = (try? c.decodeIfPresent(Int.self,            forKey: .day))     ?? 1
        amount   = try c.decode(Int.self,                        forKey: .amount)
        name     = (try? c.decodeIfPresent(String.self,         forKey: .name))    ?? ""
        category = (try? c.decodeIfPresent(IncomeCategory.self, forKey: .category)) ?? .salary
        note     = (try? c.decodeIfPresent(String.self,         forKey: .note))    ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case id, year, month, day, amount, name, category, note
    }
}
