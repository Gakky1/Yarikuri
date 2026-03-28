import Foundation
import SwiftUI
import Combine

// MARK: - アプリ全体の状態管理
// このクラスがアプリのデータとロジックの中心です
// EnvironmentObjectとして全画面に渡されます

final class AppState: ObservableObject {

    // MARK: - 永続化データ
    @Published var userProfile: UserProfile? {
        didSet { if let p = userProfile { dataStore.saveUserProfile(p) } }
    }
    @Published var fixedExpenses: [FixedExpense] = [] {
        didSet { dataStore.saveFixedExpenses(fixedExpenses) }
    }
    @Published var debts: [Debt] = [] {
        didSet { dataStore.saveDebts(debts) }
    }
    @Published var scheduledPayments: [ScheduledPayment] = [] {
        didSet { dataStore.saveScheduledPayments(scheduledPayments) }
    }
    @Published var completedTaskIds: Set<String> = []

    // MARK: - UI状態
    @Published var selectedTab: Int = 0
    @Published var showingWeeklyReport = false
    @Published var showingMonthlyReport = false

    private let dataStore = LocalDataStore.shared

    // MARK: - 初期化
    init() {
        loadData()
    }

    // MARK: - データ読み込み
    func loadData() {
        userProfile = dataStore.loadUserProfile()
        fixedExpenses = dataStore.loadFixedExpenses()
        debts = dataStore.loadDebts()
        scheduledPayments = dataStore.loadScheduledPayments()
        completedTaskIds = Set(dataStore.loadCompletedTaskIds())
    }

    // MARK: - ダミーデータでデモ起動
    func loadDemoData() {
        let profile = UserProfile(
            paydayDay: 25,
            incomeRange: .range200to250k,
            customIncomeAmount: 220000,
            totalFixedExpenses: 92190,
            hasDebt: true,
            concerns: [.debt, .fixedExpenses, .savings],
            hasDependents: false,
            hasChildren: false,
            hasRent: true,
            occupation: .employee,
            isOnboardingCompleted: true,
            createdAt: Date()
        )
        userProfile = profile
        fixedExpenses = FixedExpense.sampleData
        debts = Debt.sampleData
        scheduledPayments = ScheduledPayment.sampleData
    }

    // MARK: - オンボーディング完了処理
    func completeOnboarding(with profile: UserProfile, expenses: [FixedExpense], debts: [Debt], payments: [ScheduledPayment]) {
        var completedProfile = profile
        completedProfile.isOnboardingCompleted = true
        self.userProfile = completedProfile
        self.fixedExpenses = expenses
        self.debts = debts
        self.scheduledPayments = payments

        // 通知スケジュールを設定
        NotificationManager.shared.scheduleAll(for: completedProfile, payments: payments, debts: debts)
    }

    // MARK: - 計算プロパティ

    /// 月の手取り
    var monthlyIncome: Int {
        userProfile?.incomeAmount ?? 0
    }

    /// 固定費合計
    var totalFixedExpenses: Int {
        fixedExpenses.reduce(0) { $0 + $1.amount }
    }

    /// 今月の支払い予定合計（未払いのみ）
    var totalScheduledPayments: Int {
        scheduledPaymentsThisMonth.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    /// 今月の仮の使える額
    var remainingBudget: Int {
        max(0, monthlyIncome - totalFixedExpenses - totalScheduledPayments)
    }

    /// 給料日まで何日か
    var daysToPayday: Int {
        guard let profile = userProfile else { return 0 }
        return max(0, Date().daysUntil(Date.nextDate(day: profile.paydayDay)))
    }

    /// 給料日
    var nextPayday: Date? {
        guard let profile = userProfile else { return nil }
        return Date.nextDate(day: profile.paydayDay)
    }

    /// 1日あたり使える目安
    var dailyBudget: Int {
        let days = daysToPayday
        guard days > 0 else { return remainingBudget }
        return remainingBudget / days
    }

    /// 安全度（0.0〜1.0）
    var safetyRatio: Double {
        guard monthlyIncome > 0 else { return 0 }
        return Double(remainingBudget) / Double(monthlyIncome)
    }

    /// 安全度レベル
    var safetyLevel: SafetyLevel {
        if safetyRatio > 0.4 { return .safe }
        if safetyRatio > 0.15 { return .caution }
        return .danger
    }

    // MARK: - 今月の支払い予定一覧
    var scheduledPaymentsThisMonth: [ScheduledPayment] {
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            return []
        }
        return scheduledPayments.filter { $0.dueDate >= monthStart && $0.dueDate < monthEnd }
    }

    // MARK: - 直近3件の支払い予定
    var upcomingPayments: [ScheduledPayment] {
        scheduledPayments
            .filter { !$0.isPaid && $0.dueDate >= Date().startOfDay }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(3)
            .map { $0 }
    }

    // MARK: - 今日やること（優先順位順）
    var todayTask: DailyTask? {
        let tasks = generateTasks()
        return tasks.first(where: { !completedTaskIds.contains($0.id.uuidString) })
    }

    // MARK: - タスク生成ロジック
    func generateTasks() -> [DailyTask] {
        var tasks: [DailyTask] = []

        // 1. 支払い直前（3日以内）
        for payment in upcomingPayments where payment.daysUntilDue <= 3 {
            tasks.append(DailyTask(
                title: "「\(payment.name)」の支払いが近いです",
                description: "\(payment.dueDate.monthDay)に\(payment.amount.yen)の支払いがあります。準備できていますか？",
                taskType: .paymentDue,
                relatedItemId: payment.id,
                priority: 1,
                actionLabel: "支払いを確認する"
            ))
        }

        // 2. 借金情報が未入力
        if userProfile?.hasDebt == true && debts.isEmpty {
            tasks.append(DailyTask(
                title: "借金情報を入力しましょう",
                description: "返済計画を立てると、毎月の不安が少し減ります。まずは残高だけでもOKです。",
                taskType: .debtSetup,
                priority: 2,
                actionLabel: "入力する"
            ))
        }

        // 3. 固定費の見直し候補がある
        let reviewCandidates = fixedExpenses.filter { $0.isReviewCandidate }
        if !reviewCandidates.isEmpty {
            tasks.append(DailyTask(
                title: "固定費を見直せるかもしれません",
                description: "\(reviewCandidates.count)件の固定費が見直しできそうです。月\(reviewCandidates.reduce(0){$0+$1.amount}.yen)の節約候補があります。",
                taskType: .fixedExpenseReview,
                priority: 3,
                actionLabel: "見直す"
            ))
        }

        // 4. 制度未確認
        tasks.append(DailyTask(
            title: "使える制度を確認してみましょう",
            description: "あなたの状況に合った給付金や支援制度があるかもしれません。",
            taskType: .systemCheck,
            priority: 4,
            actionLabel: "確認する"
        ))

        // 5. 副収入候補
        tasks.append(DailyTask(
            title: "副収入のアイデアを見てみませんか",
            description: "スキルや時間を活かして、少し収入を増やせるかもしれません。",
            taskType: .sideIncomeCheck,
            priority: 5,
            actionLabel: "アイデアを見る"
        ))

        // 6. レポート確認
        tasks.append(DailyTask(
            title: "今週のレポートをチェック",
            description: "今週の使い方を振り返ってみましょう。",
            taskType: .reportCheck,
            priority: 6,
            actionLabel: "レポートを見る"
        ))

        return tasks.sorted { $0.priority < $1.priority }
    }

    // MARK: - タスク完了
    func completeTask(_ task: DailyTask) {
        completedTaskIds.insert(task.id.uuidString)
        dataStore.saveCompletedTaskIds(Array(completedTaskIds))
    }

    // MARK: - 支払い完了
    func markPaymentAsPaid(_ payment: ScheduledPayment) {
        if let index = scheduledPayments.firstIndex(where: { $0.id == payment.id }) {
            scheduledPayments[index].isPaid = true
        }
    }

    // MARK: - 今日のひとこと
    var todayMessage: TodayMessage {
        generateTodayMessage()
    }

    private func generateTodayMessage() -> TodayMessage {
        let level = safetyLevel
        switch level {
        case .safe:
            return TodayMessage(
                greeting: "今日もお疲れさまです",
                message: "今月は予算に余裕があります。\nこの調子で続けましょう！",
                emoji: "✨",
                mood: .positive
            )
        case .caution:
            return TodayMessage(
                greeting: "今日もがんばりましょう",
                message: "予算は残り少なめです。\n小さな節約を積み重ねていきましょう。",
                emoji: "🌱",
                mood: .neutral
            )
        case .danger:
            return TodayMessage(
                greeting: "一緒に乗り切りましょう",
                message: "今月はちょっと厳しめですね。\n支出を確認してみましょう。",
                emoji: "🤝",
                mood: .careful
            )
        }
    }

    // MARK: - 週次レポート生成
    var weeklyReport: WeeklyReport {
        let weeklyBudget = dailyBudget * 7
        let spent = Int(Double(weeklyBudget) * 0.8) // ダミー計算
        return WeeklyReport(
            weekStartDate: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
            weekEndDate: Date(),
            totalSpent: spent,
            budgetForWeek: weeklyBudget,
            savedAmount: weeklyBudget - spent,
            completedTasks: 3,
            totalTasks: 5,
            highlights: ["固定費の見直し候補を見つけた", "今週は外食を減らせた"]
        )
    }

    // MARK: - 月次レポート生成
    var monthlyReport: MonthlyReport {
        MonthlyReport(
            month: Date(),
            totalIncome: monthlyIncome,
            totalFixedExpenses: totalFixedExpenses,
            totalVariableExpenses: remainingBudget / 2,
            totalPayments: totalScheduledPayments,
            remainingAtEnd: remainingBudget / 2,
            previousMonthComparison: 3500,
            highlights: ["固定費が先月より3,500円減った"],
            improvementSuggestions: ["リボ払いの返済を増やすと金利負担が減ります"]
        )
    }

    // MARK: - 今週守れたお金（ダミー計算）
    var weeklyProtectedAmount: Int {
        let baseAmount = dailyBudget * 7
        return Int(Double(baseAmount) * 0.2) // 20%節約できたと仮定
    }

    // MARK: - データリセット（設定から）
    func resetAllData() {
        dataStore.clearAll()
        userProfile = nil
        fixedExpenses = []
        debts = []
        scheduledPayments = []
        completedTaskIds = []
    }
}

// MARK: - 安全度レベル
enum SafetyLevel {
    case safe, caution, danger

    var label: String {
        switch self {
        case .safe: return "安心"
        case .caution: return "注意"
        case .danger: return "要確認"
        }
    }

    var emoji: String {
        switch self {
        case .safe: return "😊"
        case .caution: return "😐"
        case .danger: return "😟"
        }
    }

    var colorName: String {
        switch self {
        case .safe: return "safe"
        case .caution: return "caution"
        case .danger: return "danger"
        }
    }
}

// MARK: - 今日のひとこと
struct TodayMessage {
    var greeting: String
    var message: String
    var emoji: String
    var mood: Mood

    enum Mood {
        case positive, neutral, careful
    }
}
