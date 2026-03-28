import Foundation

// MARK: - 借金・リボ払い情報
struct Debt: Codable, Identifiable {
    var id: UUID
    var lenderName: String               // 借入先（例: 消費者金融A、カードリボ）
    var remainingBalance: Int            // 残高
    var monthlyPayment: Int             // 毎月の返済額
    var interestRate: Double?           // 金利（年率 %, 任意）
    var debtType: DebtType              // 借金の種類
    var paymentDay: Int                 // 返済日（1〜31）
    var memo: String                    // メモ

    init(
        id: UUID = UUID(),
        lenderName: String,
        remainingBalance: Int,
        monthlyPayment: Int,
        interestRate: Double? = nil,
        debtType: DebtType = .other,
        paymentDay: Int = 27,
        memo: String = ""
    ) {
        self.id = id
        self.lenderName = lenderName
        self.remainingBalance = remainingBalance
        self.monthlyPayment = monthlyPayment
        self.interestRate = interestRate
        self.debtType = debtType
        self.paymentDay = paymentDay
        self.memo = memo
    }

    /// 完済予定月数（概算）
    var estimatedMonthsToPayoff: Int? {
        guard monthlyPayment > 0 else { return nil }
        if let rate = interestRate, rate > 0 {
            // 金利を考慮した簡易計算
            let monthlyRate = rate / 100 / 12
            let months = log(1 - (Double(remainingBalance) * monthlyRate / Double(monthlyPayment)))
                       / log(1 + monthlyRate)
            let m = Int(ceil(-months))
            return m > 0 ? m : nil
        }
        // 金利なしシンプル計算
        return Int(ceil(Double(remainingBalance) / Double(monthlyPayment)))
    }

    /// 優先度スコア（高いほど先に返すべき）
    var priorityScore: Double {
        let rate = interestRate ?? estimatedRate
        return rate
    }

    /// 金利不明時の推定金利（返済額と残高から推算）
    private var estimatedRate: Double {
        guard remainingBalance > 0, monthlyPayment > 0 else { return 15.0 }
        let ratio = Double(monthlyPayment) / Double(remainingBalance)
        if ratio > 0.05 { return 5.0 }
        else if ratio > 0.03 { return 10.0 }
        else { return 18.0 }
    }

    /// リボ払いかどうか
    var isRevolving: Bool {
        debtType == .revolving
    }

    /// 危険レベル
    var dangerLevel: DebtDangerLevel {
        let rate = interestRate ?? estimatedRate
        if rate >= 15.0 || isRevolving { return .high }
        if rate >= 8.0 { return .medium }
        return .low
    }
}

// MARK: - 借金の種類
enum DebtType: String, Codable, CaseIterable {
    case personalLoan = "personalLoan"   // 消費者金融・カードローン
    case revolving = "revolving"         // リボ払い
    case creditCard = "creditCard"       // クレジットカード分割
    case mortgageOrCar = "mortgageOrCar" // 住宅・車ローン
    case familyFriend = "familyFriend"   // 家族・友人からの借入
    case other = "other"                 // その他

    var displayText: String {
        switch self {
        case .personalLoan: return "消費者金融・カードローン"
        case .revolving: return "リボ払い"
        case .creditCard: return "クレジット分割払い"
        case .mortgageOrCar: return "住宅・車ローン"
        case .familyFriend: return "家族・友人から"
        case .other: return "その他"
        }
    }

    var emoji: String {
        switch self {
        case .personalLoan: return "🏦"
        case .revolving: return "🔄"
        case .creditCard: return "💳"
        case .mortgageOrCar: return "🏠"
        case .familyFriend: return "👥"
        case .other: return "📝"
        }
    }

    var warningMessage: String? {
        switch self {
        case .revolving:
            return "リボ払いは金利が高くなりがちです。残高が増えやすいので注意しましょう。"
        case .personalLoan:
            return "消費者金融の金利は高めです。返済計画を立てましょう。"
        default:
            return nil
        }
    }
}

// MARK: - 危険レベル
enum DebtDangerLevel {
    case low, medium, high

    var displayText: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        }
    }

    var color: String {
        switch self {
        case .low: return "safe"
        case .medium: return "caution"
        case .high: return "danger"
        }
    }
}

// MARK: - ダミーデータ
extension Debt {
    static let sampleData: [Debt] = [
        Debt(
            lenderName: "カードリボ払い",
            remainingBalance: 480000,
            monthlyPayment: 10000,
            interestRate: 15.0,
            debtType: .revolving,
            paymentDay: 27
        ),
        Debt(
            lenderName: "消費者金融",
            remainingBalance: 200000,
            monthlyPayment: 15000,
            interestRate: 18.0,
            debtType: .personalLoan,
            paymentDay: 10
        )
    ]
}
