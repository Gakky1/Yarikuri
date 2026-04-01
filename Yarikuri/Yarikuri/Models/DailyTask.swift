import Foundation

// MARK: - 今日やること
struct DailyTask: Identifiable {
    var id: UUID
    var stableKey: String               // 型＋関連IDベースの固定キー（完了追跡用）
    var title: String                    // タスクのタイトル
    var description: String             // 詳しい説明
    var taskType: TaskType              // タスクの種類
    var isCompleted: Bool               // 完了済みかどうか
    var relatedItemId: UUID?           // 関連アイテムのID（支払いや借金など）
    var priority: Int                   // 優先度（低いほど高優先）
    var actionLabel: String             // アクションボタンのテキスト

    init(
        id: UUID = UUID(),
        stableKey: String,
        title: String,
        description: String,
        taskType: TaskType,
        isCompleted: Bool = false,
        relatedItemId: UUID? = nil,
        priority: Int = 5,
        actionLabel: String = "確認する"
    ) {
        self.id = id
        self.stableKey = stableKey
        self.title = title
        self.description = description
        self.taskType = taskType
        self.isCompleted = isCompleted
        self.relatedItemId = relatedItemId
        self.priority = priority
        self.actionLabel = actionLabel
    }
}

// MARK: - タスクの種類
enum TaskType: String, CaseIterable {
    case paymentDue = "paymentDue"           // 支払い期限が近い
    case debtSetup = "debtSetup"             // 借金情報の入力
    case fixedExpenseReview = "fixedExpenseReview" // 固定費の見直し
    case systemCheck = "systemCheck"         // 使える制度の確認
    case sideIncomeCheck = "sideIncomeCheck" // 副収入候補のチェック
    case reportCheck = "reportCheck"         // レポートの確認
    case budgetAlert = "budgetAlert"         // 予算アラート

    var emoji: String {
        switch self {
        case .paymentDue: return "📅"
        case .debtSetup: return "💳"
        case .fixedExpenseReview: return "✂️"
        case .systemCheck: return "🏛️"
        case .sideIncomeCheck: return "💼"
        case .reportCheck: return "📊"
        case .budgetAlert: return "⚠️"
        }
    }

    var tabDestination: TabDestination {
        switch self {
        case .paymentDue: return .protect
        case .debtSetup: return .protect
        case .fixedExpenseReview: return .protect
        case .systemCheck: return .recover
        case .sideIncomeCheck: return .recover
        case .reportCheck: return .home
        case .budgetAlert: return .home
        }
    }
}

// MARK: - タブの行き先
enum TabDestination {
    case home, protect, recover, myPage
}

// MARK: - 週次・月次レポート
struct WeeklyReport: Identifiable {
    var id: UUID = UUID()
    var weekStartDate: Date
    var weekEndDate: Date
    var totalSpent: Int
    var budgetForWeek: Int
    var savedAmount: Int              // 節約できた額（プラスなら節約、マイナスなら使いすぎ）
    var completedTasks: Int
    var totalTasks: Int
    var highlights: [String]          // 良かったこと・気づき

    var isGoodWeek: Bool { savedAmount >= 0 }
    var savingsRate: Double {
        guard budgetForWeek > 0 else { return 0 }
        return Double(savedAmount) / Double(budgetForWeek)
    }
}

struct MonthlyReport: Identifiable {
    var id: UUID = UUID()
    var month: Date                   // 対象月（月初の日付）
    var totalIncome: Int
    var totalFixedExpenses: Int
    var totalVariableExpenses: Int
    var totalPayments: Int
    var remainingAtEnd: Int           // 月末残り
    var previousMonthComparison: Int  // 先月比（プラスなら節約）
    var highlights: [String]
    var improvementSuggestions: [String]

    var totalExpenses: Int { totalFixedExpenses + totalVariableExpenses + totalPayments }
    var savingsRate: Double {
        guard totalIncome > 0 else { return 0 }
        return Double(remainingAtEnd) / Double(totalIncome)
    }
}
