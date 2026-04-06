import Foundation

// MARK: - 固定費・サブスク
struct FixedExpense: Codable, Identifiable {
    var id: UUID
    var name: String                      // 名称（例: Netflix、家賃）
    var amount: Int                       // 月額
    var billingDay: Int?                  // 引き落とし日（1〜31）
    var holidayShift: HolidayShift?      // 休日の場合の振替
    var category: FixedExpenseCategory   // カテゴリ
    var isSubscription: Bool             // サブスクかどうか
    var isReviewCandidate: Bool          // 見直し候補かどうか
    var memo: String                     // メモ

    init(
        id: UUID = UUID(),
        name: String,
        amount: Int,
        billingDay: Int? = nil,
        holidayShift: HolidayShift? = nil,
        category: FixedExpenseCategory,
        isSubscription: Bool = false,
        isReviewCandidate: Bool = false,
        memo: String = ""
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.billingDay = billingDay
        self.holidayShift = holidayShift
        self.category = category
        self.isSubscription = isSubscription
        self.isReviewCandidate = isReviewCandidate
        self.memo = memo
    }
}

// MARK: - 休日振替
enum HolidayShift: String, Codable, CaseIterable {
    case previous = "previous"   // 休日の前の平日
    case none     = "none"       // 変更なし
    case next     = "next"       // 休日の後の平日

    var displayText: String {
        switch self {
        case .previous: return "休日の前の平日"
        case .none:     return "変更なし"
        case .next:     return "休日の後の平日"
        }
    }
}

// MARK: - 固定費カテゴリ
enum FixedExpenseCategory: String, Codable, CaseIterable {
    case rent = "rent"               // 家賃・住居費
    case utilities = "utilities"     // 光熱費（電気・ガス・水道）
    case phone = "phone"             // 携帯・通信費
    case insurance = "insurance"     // 保険
    case subscription = "subscription" // サブスク（動画・音楽など）
    case loan = "loan"               // ローン・クレジット返済
    case gym = "gym"                 // ジム・習い事
    case transport = "transport"     // 定期券・交通費
    case other = "other"             // その他

    var displayText: String {
        switch self {
        case .rent: return "家賃・住居費"
        case .utilities: return "光熱費"
        case .phone: return "通信費"
        case .insurance: return "保険"
        case .subscription: return "サブスク"
        case .loan: return "ローン返済"
        case .gym: return "ジム・習い事"
        case .transport: return "交通費"
        case .other: return "その他"
        }
    }

    var emoji: String {
        switch self {
        case .rent: return "🏠"
        case .utilities: return "💡"
        case .phone: return "📱"
        case .insurance: return "🛡️"
        case .subscription: return "📺"
        case .loan: return "💳"
        case .gym: return "💪"
        case .transport: return "🚃"
        case .other: return "📌"
        }
    }
}

// MARK: - ダミーデータ（プレビュー・初期表示用）
extension FixedExpense {
    static let sampleData: [FixedExpense] = [
        FixedExpense(name: "家賃", amount: 65000, billingDay: 27, category: .rent),
        FixedExpense(name: "電気・ガス", amount: 8000, billingDay: 15, category: .utilities),
        FixedExpense(name: "スマホ代", amount: 4500, billingDay: 20, category: .phone),
        FixedExpense(name: "生命保険", amount: 6000, billingDay: 10, category: .insurance),
        FixedExpense(name: "Netflix", amount: 1490, billingDay: 5, category: .subscription, isSubscription: true, isReviewCandidate: true),
        FixedExpense(name: "Amazon Prime", amount: 600, billingDay: 12, category: .subscription, isSubscription: true),
        FixedExpense(name: "ジム", amount: 6600, billingDay: 25, category: .gym, isReviewCandidate: true),
    ]

    static var sampleTotal: Int {
        sampleData.reduce(0) { $0 + $1.amount }
    }
}
