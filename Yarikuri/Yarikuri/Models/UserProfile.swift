import Foundation

// MARK: - ユーザープロフィール
struct UserProfile: Codable {
    var paydayDay: Int                    // 給料日（1〜31日）
    var incomeRange: IncomeRange          // 月の手取り感
    var customIncomeAmount: Int?          // 自分で入力した場合の手取り額
    var totalFixedExpenses: Int           // 固定費合計（ざっくり入力用）
    var hasDebt: Bool                     // 借金の有無
    var concerns: [ConcernType]          // 困りごとタイプ
    var hasDependents: Bool              // 扶養家族の有無
    var hasChildren: Bool                // 子どもの有無
    var hasRent: Bool                    // 家賃の有無
    var occupation: OccupationType?      // 職業区分（任意）
    var isOnboardingCompleted: Bool      // オンボーディング完了フラグ
    var createdAt: Date
    var quizAnswers: FinancialQuizAnswers?  // 初回6問の回答
    var nickname: String = ""             // ニックネーム（褒め機能用）
    var dreamText: String = ""            // 夢・目標テキスト（例：ヨーロッパ旅行）
    var dreamEmoji: String = "✨"         // 夢の絵文字
    var prefecture: String = ""           // 都道府県（制度パーソナライズ用）
    var municipality: String = ""         // 市区町村（制度パーソナライズ用）
    var appIconStyle: Int = 0             // アプリアイコンスタイル（0〜4）
    var themeColorStyle: Int = 0          // テーマカラー（0〜4）
    var monthStartDay: Int = 1            // 月度開始日（1〜28）

    // 計算用：実際の手取り額
    var incomeAmount: Int {
        customIncomeAmount ?? incomeRange.midValue
    }

    // パーソナライズ用スコア（回答から計算）
    var financialProfile: UserFinancialProfile? {
        guard let answers = quizAnswers else { return nil }
        return UserFinancialProfile.from(answers: answers)
    }
}

// MARK: - 月の手取り感
enum IncomeRange: String, Codable, CaseIterable {
    case under150k = "under150k"
    case range150to200k = "range150to200k"
    case range200to250k = "range200to250k"
    case range250to300k = "range250to300k"
    case range300to400k = "range300to400k"
    case over400k = "over400k"

    var displayText: String {
        switch self {
        case .under150k: return "〜15万円くらい"
        case .range150to200k: return "15〜20万円くらい"
        case .range200to250k: return "20〜25万円くらい"
        case .range250to300k: return "25〜30万円くらい"
        case .range300to400k: return "30〜40万円くらい"
        case .over400k: return "40万円以上"
        }
    }

    var shortText: String {
        switch self {
        case .under150k: return "〜15万"
        case .range150to200k: return "15〜20万"
        case .range200to250k: return "20〜25万"
        case .range250to300k: return "25〜30万"
        case .range300to400k: return "30〜40万"
        case .over400k: return "40万〜"
        }
    }

    /// 計算用の中間値
    var midValue: Int {
        switch self {
        case .under150k: return 130000
        case .range150to200k: return 175000
        case .range200to250k: return 225000
        case .range250to300k: return 275000
        case .range300to400k: return 350000
        case .over400k: return 450000
        }
    }
}

// MARK: - 困りごとタイプ
enum ConcernType: String, Codable, CaseIterable {
    case dailyExpenses = "dailyExpenses"     // 毎日の生活費がきつい
    case fixedExpenses = "fixedExpenses"     // 固定費が多い
    case debt = "debt"                       // 借金・リボが心配
    case savings = "savings"                 // 貯金がほぼない
    case sideIncome = "sideIncome"           // 収入を増やしたい
    case systems = "systems"                 // 使える制度を知りたい
    case childcare = "childcare"             // 子育てのお金が不安
    case housing = "housing"                 // 家賃・住居費がつらい
    case insurance = "insurance"             // 保険の見直しをしたい
    case tax = "tax"                         // 税金・確定申告が不安

    var emoji: String {
        switch self {
        case .dailyExpenses: return "🛒"
        case .fixedExpenses: return "📋"
        case .debt: return "💳"
        case .savings: return "🐷"
        case .sideIncome: return "💼"
        case .systems: return "🏛️"
        case .childcare: return "👶"
        case .housing: return "🏠"
        case .insurance: return "🛡️"
        case .tax: return "📑"
        }
    }

    var displayText: String {
        switch self {
        case .dailyExpenses: return "毎日の生活費がきつい"
        case .fixedExpenses: return "固定費が多い"
        case .debt: return "借金・リボが心配"
        case .savings: return "貯金がほぼない"
        case .sideIncome: return "収入を増やしたい"
        case .systems: return "使える制度を知りたい"
        case .childcare: return "子育てのお金が不安"
        case .housing: return "家賃・住居費がつらい"
        case .insurance: return "保険の見直しをしたい"
        case .tax: return "税金・確定申告が不安"
        }
    }
}

// MARK: - 職業区分
enum OccupationType: String, Codable, CaseIterable {
    case employee = "employee"           // 会社員・公務員
    case partTime = "partTime"           // パート・アルバイト
    case selfEmployed = "selfEmployed"   // 自営業・フリーランス
    case student = "student"             // 学生
    case homemaker = "homemaker"         // 専業主婦・主夫
    case unemployed = "unemployed"       // 無職・求職中
    case other = "other"                 // その他

    var displayText: String {
        switch self {
        case .employee: return "会社員・公務員"
        case .partTime: return "パート・アルバイト"
        case .selfEmployed: return "自営業・フリーランス"
        case .student: return "学生"
        case .homemaker: return "専業主婦・主夫"
        case .unemployed: return "無職・求職中"
        case .other: return "その他"
        }
    }
}
