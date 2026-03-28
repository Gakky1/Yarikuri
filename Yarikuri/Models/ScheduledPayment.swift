import Foundation

// MARK: - 支払い予定
struct ScheduledPayment: Codable, Identifiable {
    var id: UUID
    var name: String                     // 名称（例: 車の税金、習い事発表会）
    var amount: Int                      // 金額
    var dueDate: Date                    // 支払い予定日
    var isPaid: Bool                     // 支払い済みかどうか
    var isRecurring: Bool               // 毎月繰り返すかどうか
    var category: PaymentCategory        // カテゴリ
    var memo: String                     // メモ

    init(
        id: UUID = UUID(),
        name: String,
        amount: Int,
        dueDate: Date,
        isPaid: Bool = false,
        isRecurring: Bool = false,
        category: PaymentCategory = .other,
        memo: String = ""
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.dueDate = dueDate
        self.isPaid = isPaid
        self.isRecurring = isRecurring
        self.category = category
        self.memo = memo
    }

    /// 支払い期限まで何日か
    var daysUntilDue: Int {
        Date().daysUntil(dueDate)
    }

    /// 緊急度（支払いが近い順）
    var urgencyLevel: UrgencyLevel {
        let days = daysUntilDue
        if days < 0 { return .overdue }
        if days <= 3 { return .urgent }
        if days <= 7 { return .soon }
        return .normal
    }
}

// MARK: - 支払いカテゴリ
enum PaymentCategory: String, Codable, CaseIterable {
    case tax = "tax"             // 税金
    case insurance = "insurance" // 保険・一時払い
    case medical = "medical"     // 医療費
    case education = "education" // 教育・習い事
    case event = "event"         // イベント・お祝い
    case travel = "travel"       // 旅行
    case appliance = "appliance" // 家電・家具
    case clothing = "clothing"   // 服・美容
    case other = "other"         // その他

    var displayText: String {
        switch self {
        case .tax: return "税金"
        case .insurance: return "保険"
        case .medical: return "医療費"
        case .education: return "教育・習い事"
        case .event: return "イベント・お祝い"
        case .travel: return "旅行"
        case .appliance: return "家電・家具"
        case .clothing: return "服・美容"
        case .other: return "その他"
        }
    }

    var emoji: String {
        switch self {
        case .tax: return "📑"
        case .insurance: return "🛡️"
        case .medical: return "🏥"
        case .education: return "📚"
        case .event: return "🎉"
        case .travel: return "✈️"
        case .appliance: return "🏠"
        case .clothing: return "👗"
        case .other: return "📌"
        }
    }
}

// MARK: - 緊急度
enum UrgencyLevel {
    case overdue, urgent, soon, normal

    var label: String {
        switch self {
        case .overdue: return "期限超過"
        case .urgent: return "まもなく"
        case .soon: return "今週中"
        case .normal: return "予定"
        }
    }

    var badgeColor: String {
        switch self {
        case .overdue: return "danger"
        case .urgent: return "danger"
        case .soon: return "caution"
        case .normal: return "secondary"
        }
    }
}

// MARK: - ダミーデータ
extension ScheduledPayment {
    static var sampleData: [ScheduledPayment] {
        let calendar = Calendar.current
        let today = Date()

        func daysFromNow(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: days, to: today) ?? today
        }

        return [
            ScheduledPayment(
                name: "自動車税",
                amount: 34500,
                dueDate: daysFromNow(12),
                category: .tax
            ),
            ScheduledPayment(
                name: "歯医者の治療費",
                amount: 8000,
                dueDate: daysFromNow(3),
                category: .medical
            ),
            ScheduledPayment(
                name: "友達の結婚式ご祝儀",
                amount: 30000,
                dueDate: daysFromNow(20),
                category: .event
            ),
        ]
    }
}
