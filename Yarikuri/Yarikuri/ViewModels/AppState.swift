import Foundation
import SwiftUI
import Combine

// MARK: - 部屋カスタマイズ設定
struct RoomConfig: Codable, Equatable {
    var wallStyle: Int = 0     // 0=クリーム, 1=そら(水色), 2=もり(薄緑), 3=すみれ(薄紫)
    var floorStyle: Int = 0    // 0=木目, 1=大理石
    var activeItems: [String] = ["plant", "coffee"]  // アイテムID

    init(wallStyle: Int = 0, floorStyle: Int = 0, activeItems: [String] = ["plant", "coffee"]) {
        self.wallStyle = wallStyle
        self.floorStyle = floorStyle
        self.activeItems = activeItems
    }
}

// MARK: - 通知設定
struct NotificationPrefs: Codable {
    var payday: Bool = true
    var debit: Bool = true
    var subscription: Bool = true
    var repayment: Bool = true
    var deadline: Bool = true
    var dailyTask: Bool = true
}

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
    @Published var completedTaskIds: Set<String> = []       // 累計カウント用（リレーション段階・レベル計算に使用）
    @Published var dailyCompletedKeys: Set<String> = []     // 今日の完了キー（日次リセット）
    @Published var cardActions: [CardAction] = [] {
        didSet { dataStore.saveCardActions(cardActions) }
    }
    @Published var incomeHistory: [IncomeRecord] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(incomeHistory) {
                UserDefaults.standard.set(data, forKey: "incomeHistory")
            }
        }
    }
    @Published var fixedExpenseHistory: [FixedExpenseMonthRecord] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(fixedExpenseHistory) {
                UserDefaults.standard.set(data, forKey: "fixedExpenseHistory")
            }
        }
    }
    @Published var scheduledPaymentHistory: [ScheduledPaymentMonthRecord] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(scheduledPaymentHistory) {
                UserDefaults.standard.set(data, forKey: "scheduledPaymentHistory")
            }
        }
    }

    // MARK: - UI状態
    @Published var selectedTab: Int = 0
    @Published var showingWeeklyReport = false
    @Published var showingMonthlyReport = false
    @Published var currentPraise: PraiseItem? = nil

    // MARK: - 部屋進化用カウント（累計・永続）
    @Published var protectActionsTotal: Int = UserDefaults.standard.integer(forKey: "protectActionsTotal")
    @Published var growActionsTotal: Int    = UserDefaults.standard.integer(forKey: "growActionsTotal")
    @Published var consecutiveLoginDays: Int = UserDefaults.standard.integer(forKey: "consecutiveLoginDays")
    @Published var inputXpCount: Int = UserDefaults.standard.integer(forKey: "inputXpCount") {
        didSet { UserDefaults.standard.set(inputXpCount, forKey: "inputXpCount") }
    }

    // MARK: - やりくりん統一レベル（全タブ共通）
    var yarikurinTotalXp: Int { inputXpCount + completedTaskIds.count }
    var yarikurinLevel: Int {
        switch yarikurinTotalXp {
        case 0..<3:   return 1
        case 3..<7:   return 2
        case 7..<13:  return 3
        case 13..<21: return 4
        default:      return 5
        }
    }

    // MARK: - レイアウトカスタマイズ（支出を減らす・収入を増やす）
    @Published var protectCardOrder: [String] = UserDefaults.standard.stringArray(forKey: "protectCardOrder")
        ?? ["fixedExpense", "variablePayment", "debtNavi", "support", "howTo", "secret"] {
        didSet { UserDefaults.standard.set(protectCardOrder, forKey: "protectCardOrder") }
    }
    @Published var protectHiddenCards: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "protectHiddenCards") ?? []) {
        didSet { UserDefaults.standard.set(Array(protectHiddenCards), forKey: "protectHiddenCards") }
    }
    @Published var growCardOrder: [String] = UserDefaults.standard.stringArray(forKey: "growCardOrder")
        ?? ["income", "fukugyou", "nisa", "setsuzei", "career", "master"] {
        didSet { UserDefaults.standard.set(growCardOrder, forKey: "growCardOrder") }
    }
    @Published var growHiddenCards: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "growHiddenCards") ?? []) {
        didSet { UserDefaults.standard.set(Array(growHiddenCards), forKey: "growHiddenCards") }
    }

    // ログイン日履歴（"yyyy-MM-dd" 形式の文字列セット）
    @Published var loginDateHistory: Set<String> = {
        let arr = UserDefaults.standard.stringArray(forKey: "loginDateHistory") ?? []
        return Set(arr)
    }()

    @Published var protectRoom: RoomConfig = {
        if let data = UserDefaults.standard.data(forKey: "protectRoom"),
           let config = try? JSONDecoder().decode(RoomConfig.self, from: data) { return config }
        return RoomConfig(activeItems: ["plant", "coffee"])
    }() {
        didSet {
            if let data = try? JSONEncoder().encode(protectRoom) {
                UserDefaults.standard.set(data, forKey: "protectRoom")
            }
        }
    }
    @Published var growRoom: RoomConfig = {
        if let data = UserDefaults.standard.data(forKey: "growRoom"),
           let config = try? JSONDecoder().decode(RoomConfig.self, from: data) { return config }
        return RoomConfig(activeItems: ["plant", "dining"])
    }() {
        didSet {
            if let data = try? JSONEncoder().encode(growRoom) {
                UserDefaults.standard.set(data, forKey: "growRoom")
            }
        }
    }
    @Published var notificationPrefs: NotificationPrefs = {
        if let data = UserDefaults.standard.data(forKey: "notificationPrefs"),
           let prefs = try? JSONDecoder().decode(NotificationPrefs.self, from: data) { return prefs }
        return NotificationPrefs()
    }() {
        didSet {
            if let data = try? JSONEncoder().encode(notificationPrefs) {
                UserDefaults.standard.set(data, forKey: "notificationPrefs")
            }
        }
    }
    @Published var customMonthlyBudget: Int? = {
        let v = UserDefaults.standard.integer(forKey: "customMonthlyBudget")
        return v > 0 ? v : nil
    }() {
        didSet {
            UserDefaults.standard.set(customMonthlyBudget ?? 0, forKey: "customMonthlyBudget")
        }
    }

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
        cardActions = dataStore.loadCardActions()
        if let data = UserDefaults.standard.data(forKey: "incomeHistory"),
           let records = try? JSONDecoder().decode([IncomeRecord].self, from: data) {
            incomeHistory = records
        }
        if let data = UserDefaults.standard.data(forKey: "fixedExpenseHistory"),
           let records = try? JSONDecoder().decode([FixedExpenseMonthRecord].self, from: data) {
            fixedExpenseHistory = records
        }
        if let data = UserDefaults.standard.data(forKey: "scheduledPaymentHistory"),
           let records = try? JSONDecoder().decode([ScheduledPaymentMonthRecord].self, from: data) {
            scheduledPaymentHistory = records
        }
        resetDailyTasksIfNeeded()
    }

    // MARK: - ダミーデータでデモ起動
    func loadDemoData() {
        let demoQuiz = FinancialQuizAnswers(
            mainConcern: .noMoneyLeft,
            monthlySlack: .alittle,
            existingPayments: .cardLoan,
            emergencyFund: .lessThanMonth,
            lifeStyle: .alone,
            investmentExp: .interestedNotStarted
        )
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
            createdAt: Date(),
            quizAnswers: demoQuiz
        )
        userProfile = profile
        fixedExpenses = FixedExpense.sampleData
        debts = Debt.sampleData
        scheduledPayments = ScheduledPayment.sampleData

        // デモ用：都道府県設定
        userProfile?.prefecture = "東京都"

        // デモ用：部屋・マスコットをLv5に、ログインボーナス全解放
        protectActionsTotal = 25
        growActionsTotal = 25
        consecutiveLoginDays = 20
        UserDefaults.standard.set(25, forKey: "protectActionsTotal")
        UserDefaults.standard.set(25, forKey: "growActionsTotal")
        UserDefaults.standard.set(20, forKey: "consecutiveLoginDays")
        // デモ用：過去20日分のログイン日履歴を生成
        let demoFormatter = DateFormatter()
        demoFormatter.dateFormat = "yyyy-MM-dd"
        let demoCalendar = Calendar.current
        var demoDates: Set<String> = []
        for i in 0..<20 {
            if let d = demoCalendar.date(byAdding: .day, value: -i, to: Date()) {
                demoDates.insert(demoFormatter.string(from: d))
            }
        }
        loginDateHistory = demoDates
        UserDefaults.standard.set(Array(demoDates), forKey: "loginDateHistory")
        completedTaskIds = Set((0..<25).map { "demo-task-\($0)" })
        dataStore.saveCompletedTaskIds(Array(completedTaskIds))

        // デモ用：過去13ヶ月の固定費履歴
        fixedExpenseHistory = [
            FixedExpenseMonthRecord(year: 2025, month:  1, totalAmount: 98_200),
            FixedExpenseMonthRecord(year: 2025, month:  2, totalAmount: 97_500),
            FixedExpenseMonthRecord(year: 2025, month:  3, totalAmount: 96_400),
            FixedExpenseMonthRecord(year: 2025, month:  4, totalAmount: 95_800),
            FixedExpenseMonthRecord(year: 2025, month:  5, totalAmount: 95_800),
            FixedExpenseMonthRecord(year: 2025, month:  6, totalAmount: 94_200),
            FixedExpenseMonthRecord(year: 2025, month:  7, totalAmount: 94_200),
            FixedExpenseMonthRecord(year: 2025, month:  8, totalAmount: 93_500),
            FixedExpenseMonthRecord(year: 2025, month:  9, totalAmount: 93_500),
            FixedExpenseMonthRecord(year: 2025, month: 10, totalAmount: 92_900),
            FixedExpenseMonthRecord(year: 2025, month: 11, totalAmount: 92_900),
            FixedExpenseMonthRecord(year: 2025, month: 12, totalAmount: 92_190),
            FixedExpenseMonthRecord(year: 2026, month:  1, totalAmount: 92_190),
            FixedExpenseMonthRecord(year: 2026, month:  2, totalAmount: 92_190),
            FixedExpenseMonthRecord(year: 2026, month:  3, totalAmount: 92_190),
        ]
        if let data = try? JSONEncoder().encode(fixedExpenseHistory) {
            UserDefaults.standard.set(data, forKey: "fixedExpenseHistory")
        }

        // デモ用：過去13ヶ月の今月の支払い履歴
        scheduledPaymentHistory = [
            ScheduledPaymentMonthRecord(year: 2025, month:  1, totalAmount: 31_000, payments: [
                ScheduledPaymentSnapshot(name: "自動車税", amount: 18_000),
                ScheduledPaymentSnapshot(name: "歯医者", amount: 8_000),
                ScheduledPaymentSnapshot(name: "書籍代", amount: 5_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2025, month:  2, totalAmount: 24_500, payments: [
                ScheduledPaymentSnapshot(name: "友達の誕生日プレゼント", amount: 5_000),
                ScheduledPaymentSnapshot(name: "クリーニング代", amount: 4_500),
                ScheduledPaymentSnapshot(name: "習い事発表会", amount: 15_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2025, month:  3, totalAmount: 42_000, payments: [
                ScheduledPaymentSnapshot(name: "卒業式の衣装", amount: 22_000),
                ScheduledPaymentSnapshot(name: "引越し関連費用", amount: 12_000),
                ScheduledPaymentSnapshot(name: "区役所手数料", amount: 8_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2025, month:  4, totalAmount: 18_500, payments: [
                ScheduledPaymentSnapshot(name: "健康診断", amount: 8_500),
                ScheduledPaymentSnapshot(name: "書籍・文具", amount: 10_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2025, month:  5, totalAmount: 34_000, payments: [
                ScheduledPaymentSnapshot(name: "自動車税", amount: 34_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2025, month:  6, totalAmount: 12_000, payments: [
                ScheduledPaymentSnapshot(name: "梅雨対策グッズ", amount: 4_000),
                ScheduledPaymentSnapshot(name: "父の日プレゼント", amount: 8_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2025, month:  7, totalAmount: 56_000, payments: [
                ScheduledPaymentSnapshot(name: "夏旅行（交通費）", amount: 28_000),
                ScheduledPaymentSnapshot(name: "夏旅行（宿泊費）", amount: 18_000),
                ScheduledPaymentSnapshot(name: "海水浴用品", amount: 10_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2025, month:  8, totalAmount: 28_000, payments: [
                ScheduledPaymentSnapshot(name: "帰省交通費", amount: 18_000),
                ScheduledPaymentSnapshot(name: "お盆のお土産", amount: 10_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2025, month:  9, totalAmount: 15_000, payments: [
                ScheduledPaymentSnapshot(name: "衣替え（秋物購入）", amount: 15_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2025, month: 10, totalAmount: 38_000, payments: [
                ScheduledPaymentSnapshot(name: "友達の結婚式ご祝儀", amount: 30_000),
                ScheduledPaymentSnapshot(name: "二次会費", amount: 8_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2025, month: 11, totalAmount: 22_000, payments: [
                ScheduledPaymentSnapshot(name: "冬物コート", amount: 14_000),
                ScheduledPaymentSnapshot(name: "タイヤ交換", amount: 8_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2025, month: 12, totalAmount: 68_000, payments: [
                ScheduledPaymentSnapshot(name: "クリスマスプレゼント", amount: 15_000),
                ScheduledPaymentSnapshot(name: "年末帰省交通費", amount: 22_000),
                ScheduledPaymentSnapshot(name: "忘年会費", amount: 8_000),
                ScheduledPaymentSnapshot(name: "家電（電子レンジ）", amount: 18_000),
                ScheduledPaymentSnapshot(name: "年賀状・カード代", amount: 5_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2026, month:  1, totalAmount: 25_000, payments: [
                ScheduledPaymentSnapshot(name: "お年玉", amount: 10_000),
                ScheduledPaymentSnapshot(name: "初詣・お参り", amount: 5_000),
                ScheduledPaymentSnapshot(name: "成人式関連", amount: 10_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2026, month:  2, totalAmount: 19_000, payments: [
                ScheduledPaymentSnapshot(name: "バレンタインギフト", amount: 4_000),
                ScheduledPaymentSnapshot(name: "確定申告関連", amount: 15_000),
            ]),
            ScheduledPaymentMonthRecord(year: 2026, month:  3, totalAmount: 31_500, payments: [
                ScheduledPaymentSnapshot(name: "歯医者の治療費", amount: 8_000),
                ScheduledPaymentSnapshot(name: "友達の結婚式ご祝儀", amount: 20_000),
                ScheduledPaymentSnapshot(name: "書類代", amount: 3_500),
            ]),
        ]
        if let data = try? JSONEncoder().encode(scheduledPaymentHistory) {
            UserDefaults.standard.set(data, forKey: "scheduledPaymentHistory")
        }

        // デモ用：過去13ヶ月の収入履歴
        incomeHistory = [
            IncomeRecord(year: 2025, month:  1, amount: 215_000),
            IncomeRecord(year: 2025, month:  2, amount: 216_500),
            IncomeRecord(year: 2025, month:  3, amount: 218_000),
            IncomeRecord(year: 2025, month:  4, amount: 221_000),
            IncomeRecord(year: 2025, month:  5, amount: 219_500),
            IncomeRecord(year: 2025, month:  6, amount: 224_000),
            IncomeRecord(year: 2025, month:  7, amount: 220_000),
            IncomeRecord(year: 2025, month:  8, amount: 217_000),
            IncomeRecord(year: 2025, month:  9, amount: 222_500),
            IncomeRecord(year: 2025, month: 10, amount: 220_000),
            IncomeRecord(year: 2025, month: 11, amount: 226_000),
            IncomeRecord(year: 2025, month: 12, amount: 231_000, note: "賞与あり"),
            IncomeRecord(year: 2026, month:  1, amount: 220_000),
            IncomeRecord(year: 2026, month:  2, amount: 219_000),
            IncomeRecord(year: 2026, month:  3, amount: 222_000),
        ]
        if let data = try? JSONEncoder().encode(incomeHistory) {
            UserDefaults.standard.set(data, forKey: "incomeHistory")
        }
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

    /// 今月の支払い予定合計（未払いのみ・予算計算用）
    var totalScheduledPayments: Int {
        scheduledPaymentsThisMonth.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    /// 全支払い予定の未払い合計（一覧画面表示用）
    var totalAllUnpaidPayments: Int {
        scheduledPayments.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    /// 毎月の借金返済合計
    var totalMonthlyDebtPayments: Int {
        debts.reduce(0) { $0 + $1.monthlyPayment }
    }

    /// 今月の仮の使える額
    var remainingBudget: Int {
        let budget = customMonthlyBudget ?? monthlyIncome
        return max(0, budget - totalFixedExpenses - totalScheduledPayments - totalMonthlyDebtPayments)
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

    // MARK: - 直近3件の支払い予定（変動費のみ、後方互換用）
    var upcomingPayments: [ScheduledPayment] {
        scheduledPayments
            .filter { !$0.isPaid && $0.dueDate >= Date().startOfDay }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(3)
            .map { $0 }
    }

    // MARK: - 固定費＋変動費を合わせた直近支払い一覧
    var upcomingCombinedPayments: [UpcomingPaymentItem] {
        var items: [UpcomingPaymentItem] = []

        // 変動費
        let variable = scheduledPayments
            .filter { !$0.isPaid && $0.dueDate >= Date().startOfDay }
            .map { UpcomingPaymentItem(id: $0.id, name: $0.name, amount: $0.amount, dueDate: $0.dueDate, emoji: $0.category.emoji, kind: .variable) }
        items.append(contentsOf: variable)

        // 固定費（billingDayがある場合のみ）
        let calendar = Calendar.current
        let today = Date()
        let currentDay = calendar.component(.day, from: today)

        for fe in fixedExpenses {
            guard let billingDay = fe.billingDay else { continue }
            // 今月の引き落とし日がまだなら今月、過ぎていれば来月
            let base = billingDay >= currentDay ? today
                     : (calendar.date(byAdding: .month, value: 1, to: today) ?? today)
            var comps = calendar.dateComponents([.year, .month], from: base)
            let maxDay = calendar.range(of: .day, in: .month, for: base)?.count ?? billingDay
            comps.day = min(billingDay, maxDay)
            guard let dueDate = calendar.date(from: comps) else { continue }
            items.append(UpcomingPaymentItem(id: fe.id, name: fe.name, amount: fe.amount, dueDate: dueDate, emoji: fe.category.emoji, kind: .fixed))
        }

        return items.sorted { $0.dueDate < $1.dueDate }.prefix(3).map { $0 }
    }

    // MARK: - 今日やること（優先順位順）
    var todayTask: DailyTask? {
        let tasks = generateTasks()
        return tasks.first(where: { !dailyCompletedKeys.contains($0.stableKey) })
    }

    // MARK: - 日次リセット
    func resetDailyTasksIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastReset = dataStore.loadLastTaskResetDate()
        guard let last = lastReset, Calendar.current.isDate(last, inSameDayAs: today) else {
            dailyCompletedKeys = []
            dataStore.saveDailyCompletedKeys([])
            dataStore.saveLastTaskResetDate(today)
            return
        }
    }

    // MARK: - タスク生成ロジック
    func generateTasks() -> [DailyTask] {
        var tasks: [DailyTask] = []

        // 1. 支払い直前（3日以内）
        for payment in upcomingPayments where payment.daysUntilDue <= 3 {
            tasks.append(DailyTask(
                stableKey: "paymentDue-\(payment.id.uuidString)",
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
                stableKey: "debtSetup",
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
                stableKey: "fixedExpenseReview",
                title: "固定費を見直せるかもしれません",
                description: "\(reviewCandidates.count)件の固定費が見直しできそうです。月\(reviewCandidates.reduce(0){$0+$1.amount}.yen)の節約候補があります。",
                taskType: .fixedExpenseReview,
                priority: 3,
                actionLabel: "見直す"
            ))
        }

        // 4. 制度未確認
        tasks.append(DailyTask(
            stableKey: "systemCheck",
            title: "使える制度を確認してみましょう",
            description: "あなたの状況に合った給付金や支援制度があるかもしれません。",
            taskType: .systemCheck,
            priority: 4,
            actionLabel: "確認する"
        ))

        // 5. 副収入候補
        tasks.append(DailyTask(
            stableKey: "sideIncomeCheck",
            title: "副収入のアイデアを見てみませんか",
            description: "スキルや時間を活かして、少し収入を増やせるかもしれません。",
            taskType: .sideIncomeCheck,
            priority: 5,
            actionLabel: "アイデアを見る"
        ))

        // 6. レポート確認
        tasks.append(DailyTask(
            stableKey: "reportCheck",
            title: "今週のレポートをチェック",
            description: "今週の使い方を振り返ってみましょう。",
            taskType: .reportCheck,
            priority: 6,
            actionLabel: "レポートを見る"
        ))

        return tasks.sorted { $0.priority < $1.priority }
    }

    // MARK: - ニックネーム（アプリ内表示用）
    var nickname: String {
        let n = userProfile?.nickname ?? ""
        return n.isEmpty ? "あなた" : n
    }

    func updateNickname(_ name: String) {
        userProfile?.nickname = name
    }

    // MARK: - コミュニティ用匿名ニックネーム（一度生成して固定）
    var communityNickname: String {
        let key = "yarikuri.communityNickname"
        if let saved = UserDefaults.standard.string(forKey: key) { return saved }
        let number = Int.random(in: 1000...9999)
        let generated = "やりくりん#\(number)"
        UserDefaults.standard.set(generated, forKey: key)
        return generated
    }

    // MARK: - 都道府県
    var prefecture: String {
        userProfile?.prefecture ?? ""
    }

    func updatePrefecture(_ pref: String) {
        userProfile?.prefecture = pref
    }

    // MARK: - 関係性ステージ（褒め言葉・ひとことの深みが変わる）
    var relationshipStage: Int {
        switch completedTaskIds.count {
        case 0..<3:   return 1
        case 3..<7:   return 2
        case 7..<13:  return 3
        case 13..<21: return 4
        default:      return 5
        }
    }

    /// マスコットカードに表示する「やりくりんのひとこと」
    var mascotComment: String {
        let n = nickname
        // 連続ログインを優先
        switch consecutiveLoginDays {
        case 30...: return "\(n)さん、毎日ありがとうりん。ずっと一緒にいるよりん"
        case 14...: return "2週間連続！\(n)さん、もうすっかり習慣だりん"
        case 7...:  return "1週間連続！\(n)さん、すごいよりん！"
        case 3...:  return "\(consecutiveLoginDays)日連続！いい調子だよりん"
        default: break
        }
        // 夢が設定されていれば、タスク完了数に応じて夢参照コメントを挟む
        if let dream = userProfile?.dreamText, !dream.isEmpty, completedTaskIds.count % 3 == 0 {
            return "\(n)さん、\(dream)のために今日も一歩りん！"
        }
        // 関係性ステージで変化
        switch relationshipStage {
        case 1: return "はじめましてりん！一緒にやっていこうりん"
        case 2: return "少しずつ変わってきてるの、わかるよりん"
        case 3: return "\(n)さん、前よりずっと頼もしくなったりん"
        case 4: return "もうすっかりやりくり上手だよりん"
        default: return "長い付き合いだりん。ずっと一緒にいるよりん"
        }
    }

    // MARK: - 褒めシステム（関係性ステージ別）
    @Published var pendingStreakMilestone: Int = 0

    private func praisePool(stage: Int) -> [(text: String, emotion: CoronEmotion)] {
        switch stage {
        case 1:
            return [
                ("さすが{name}さん！！", .celebrate),
                ("{name}さん、すごい！！", .happy),
                ("一緒にがんばろうね{name}さん！", .cheer),
                ("{name}さん、最初の一歩！！", .celebrate),
                ("何でも一緒にやろう！{name}さん！", .cheer),
            ]
        case 2:
            return [
                ("最近の{name}さん、いい感じ！！", .happy),
                ("続けてるね{name}さん！嬉しいな！", .celebrate),
                ("{name}さん、だんだん上手くなってる！", .happy),
                ("{name}さんのこと、応援してるよ！！", .cheer),
                ("その調子！{name}さん！！", .celebrate),
            ]
        case 3:
            return [
                ("やっぱり{name}さんはすごい！！", .celebrate),
                ("{name}さん、前よりずっと変わってきたよ", .happy),
                ("一緒にいると元気もらえる！{name}さん！", .celebrate),
                ("{name}さんって本当にえらい！！", .celebrate),
                ("着実に積み上げてるね{name}さん！", .cheer),
            ]
        case 4:
            return [
                ("{name}さん、ずっと応援してきてよかった！", .celebrate),
                ("もうすっかり頼もしくなったよ{name}さん！", .happy),
                ("この調子なら絶対大丈夫！{name}さん！！", .celebrate),
                ("{name}さんのこと、誇りに思う！！", .celebrate),
                ("{name}さんは本物のやりくり上手だ！", .happy),
            ]
        default: // 5
            return [
                ("長い付き合いだけど{name}さんって本当にすごい", .celebrate),
                ("昔の{name}さんに教えてあげたい、こんなに変わったって", .happy),
                ("{name}さんと一緒にいられて本当によかった！", .celebrate),
                ("もう{name}さんのことなんでもわかる気がする", .happy),
                ("{name}さん、いつもありがとうね", .cheer),
            ]
        }
    }

    func triggerPraise() {
        // ストリークマイルストーンを優先表示（その日1回だけ）
        if pendingStreakMilestone > 0 {
            let days = pendingStreakMilestone
            pendingStreakMilestone = 0
            let text: String
            switch days {
            case 3:  text = "\(nickname)さん、3日連続！調子いいよ！！"
            case 7:  text = "1週間連続！\(nickname)さんすごすぎる！！"
            case 14: text = "2週間連続！\(nickname)さん本物だ！！"
            default: text = "なんと1ヶ月連続！\(nickname)さん最高すぎる！！🎉"
            }
            showPraise(PraiseItem(text: text, emotion: .celebrate))
            return
        }
        // 夢参照メッセージ（30%の確率、夢が設定されている場合のみ）
        if let dream = userProfile?.dreamText, !dream.isEmpty, Int.random(in: 0..<10) < 3 {
            let dreamPhrases: [(text: String, emotion: CoronEmotion)] = [
                ("\(dream)のために、今日も一歩！\(nickname)さん！", .celebrate),
                ("\(nickname)さんの\(dream)、応援してるよ！", .happy),
                ("\(dream)、絶対叶えよう！\(nickname)さん！！", .celebrate),
                ("\(dream)に近づいてる！\(nickname)さんすごい！", .cheer),
                ("\(dream)を思い浮かべながら、進もう！\(nickname)さん！", .happy),
            ]
            if let item = dreamPhrases.randomElement() {
                showPraise(PraiseItem(text: item.text, emotion: item.emotion))
                return
            }
        }
        // 関係性ステージに応じたメッセージ
        let pool = praisePool(stage: relationshipStage)
        guard let template = pool.randomElement() else { return }
        let text = template.text.replacingOccurrences(of: "{name}", with: nickname)
        showPraise(PraiseItem(text: text, emotion: template.emotion))
    }

    private func showPraise(_ praise: PraiseItem) {
        currentPraise = praise
    }

    // MARK: - タスク完了
    func completeTask(_ task: DailyTask) {
        // 今日の完了セットに追加（翌日リセット）
        dailyCompletedKeys.insert(task.stableKey)
        dataStore.saveDailyCompletedKeys(Array(dailyCompletedKeys))

        // 累計カウント用（リレーション段階・レベル計算に使用）
        let lifetimeKey = "\(task.stableKey)-\(Int(Date().timeIntervalSince1970))"
        completedTaskIds.insert(lifetimeKey)
        dataStore.saveCompletedTaskIds(Array(completedTaskIds))

        checkLoginStreak()
        triggerPraise()
    }

    // MARK: - 支払い完了
    func markPaymentAsPaid(_ payment: ScheduledPayment) {
        if let index = scheduledPayments.firstIndex(where: { $0.id == payment.id }) {
            scheduledPayments[index].isPaid = true
        }
    }

    // MARK: - 支払い完了取消
    func unmarkPaymentAsPaid(_ payment: ScheduledPayment) {
        if let index = scheduledPayments.firstIndex(where: { $0.id == payment.id }) {
            scheduledPayments[index].isPaid = false
        }
    }

    // MARK: - 今日のおすすめ（パーソナライズ）
    var todayRecommendation: TodayRecommendation {
        guard let fp = userProfile?.financialProfile else {
            return TodayRecommendation(
                title: "使っていないサブスクを確認する",
                description: "毎月少しずつ節約を積み重ねましょう。",
                emoji: "📱", actionLabel: "確認する"
            )
        }
        if fp.emergencyFundNeed > 0.7 {
            return TodayRecommendation(
                title: "急な出費への備えを確認する",
                description: "もしものときのお金を少しずつ積み上げましょう。",
                emoji: "🛡️", actionLabel: "備えを考える"
            )
        }
        if fp.debtCareNeed > 0.7 {
            return TodayRecommendation(
                title: "リボ払いの残高を確認する",
                description: "金利の高い借入から返済すると、長期的にお得です。",
                emoji: "💳", actionLabel: "確認する"
            )
        }
        if fp.spendingControlNeed > 0.7 {
            return TodayRecommendation(
                title: "固定費を1つ見直してみる",
                description: "使っていないサービスが隠れているかもしれません。",
                emoji: "📋", actionLabel: "見直す"
            )
        }
        if fp.investmentConfidence < 0.3 && fp.growReadiness > 0.4 {
            return TodayRecommendation(
                title: "NISAの最初の1歩を見てみる",
                description: "月1,000円からでも始められます。まずは知るところから。",
                emoji: "🌱", actionLabel: "見てみる"
            )
        }
        if fp.investmentConfidence >= 0.3 && fp.investmentConfidence < 0.7 {
            return TodayRecommendation(
                title: "積立の金額を見直してみる",
                description: "少し増やすだけで、将来の差が大きく変わります。",
                emoji: "📈", actionLabel: "確認する"
            )
        }
        if fp.investmentConfidence >= 0.7 {
            return TodayRecommendation(
                title: "ポートフォリオを整理してみる",
                description: "定期的な見直しで、より効率的な運用を目指しましょう。",
                emoji: "📊", actionLabel: "整理する"
            )
        }
        return TodayRecommendation(
            title: "使っていないサブスクを確認する",
            description: "毎月少しずつ節約を積み重ねましょう。",
            emoji: "📱", actionLabel: "確認する"
        )
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
                greeting: "今日もお疲れさまりん",
                message: "今月は予算に余裕があるりん。\nこの調子で続けていこうりん！",
                emoji: "✨",
                mood: .positive
            )
        case .caution:
            return TodayMessage(
                greeting: "今日もがんばろうりん",
                message: "予算は残り少なめりん。\n小さな節約を積み重ねていこうりん。",
                emoji: "🌱",
                mood: .neutral
            )
        case .danger:
            return TodayMessage(
                greeting: "一緒に乗り切ろうりん",
                message: "今月はちょっと厳しめりん。\n支出を確認してみようりん。",
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
        return Int(Double(baseAmount) * 0.2)
    }

    // MARK: - 今月守れたお金（残予算）
    var monthlyProtectedAmount: Int { remainingBudget }

    // MARK: - 今月の支出（固定費 + 借金返済 + 今月の支払い予定）
    var monthlyTotalExpenses: Int {
        totalFixedExpenses + totalMonthlyDebtPayments + totalScheduledPayments
    }

    // MARK: - 今月の収入
    var currentMonthlyIncome: Int { monthlyIncome }

    // MARK: - 先月の収入（incomeHistoryから取得）
    var lastMonthIncome: Int {
        let cal = Calendar.current
        let now = Date()
        let lastMonth = cal.date(byAdding: .month, value: -1, to: now)!
        let y = cal.component(.year, from: lastMonth)
        let m = cal.component(.month, from: lastMonth)
        return incomeHistory.first { $0.year == y && $0.month == m }?.amount
            ?? monthlyIncome
    }

    // MARK: - 先々月比（収入）
    var incomeComparedToPreviousMonth: Int {
        let cal = Calendar.current
        let now = Date()
        let lastMonth     = cal.date(byAdding: .month, value: -1, to: now)!
        let prevMonth     = cal.date(byAdding: .month, value: -2, to: now)!
        let ly = cal.component(.year, from: lastMonth); let lm = cal.component(.month, from: lastMonth)
        let py = cal.component(.year, from: prevMonth); let pm = cal.component(.month, from: prevMonth)
        let last = incomeHistory.first { $0.year == ly && $0.month == lm }?.amount
        let prev = incomeHistory.first { $0.year == py && $0.month == pm }?.amount
        guard let l = last, let p = prev else { return 0 }
        return l - p
    }

    // MARK: - 先月比（支出）
    var expensesComparedToLastMonth: Int {
        // シンプルな推定: 固定費±3%のランダム変動として 3500 円差を返す
        monthlyReport.previousMonthComparison
    }

    // MARK: - 先月比（収入）※後方互換
    var incomeComparedToLastMonth: Int { incomeComparedToPreviousMonth }

    // MARK: - 今月増やせたお金（週次節約額 × 4週）
    var monthlyGrownAmount: Int { weeklyProtectedAmount * 4 }

    // MARK: - 今月の節約ポテンシャル（固定費見直し候補合計）
    var monthlyPotentialSavings: Int {
        fixedExpenses.filter { $0.isReviewCandidate }.reduce(0) { $0 + $1.amount }
    }

    // MARK: - ログインストリーク（タスク完了時にカウント）
    func checkLoginStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let last = UserDefaults.standard.object(forKey: "lastLoginDate") as? Date {
            let lastDay = calendar.startOfDay(for: last)
            guard !calendar.isDate(today, inSameDayAs: lastDay) else { return }
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            consecutiveLoginDays = diff == 1 ? consecutiveLoginDays + 1 : 1
        } else {
            consecutiveLoginDays = 1
        }
        UserDefaults.standard.set(consecutiveLoginDays, forKey: "consecutiveLoginDays")
        UserDefaults.standard.set(today, forKey: "lastLoginDate")
        // ログイン日履歴に追加
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: today)
        loginDateHistory.insert(dateStr)
        UserDefaults.standard.set(Array(loginDateHistory), forKey: "loginDateHistory")
        // マイルストーン達成時はトースト表示フラグを立てる
        if [3, 7, 14, 30].contains(consecutiveLoginDays) {
            pendingStreakMilestone = consecutiveLoginDays
        }
    }

    // MARK: - カードアクション記録
    func recordCardView(emoji: String, title: String, category: CardCategory) {
        // 同じカードを連続で重複登録しない（直前と同じなら無視）
        if let last = cardActions.first, last.emoji == emoji && last.title == title { return }
        let action = CardAction(emoji: emoji, title: title, category: category, date: Date())
        cardActions = Array(([action] + cardActions).prefix(50))
        switch category {
        case .protect:
            protectActionsTotal += 1
            UserDefaults.standard.set(protectActionsTotal, forKey: "protectActionsTotal")
        case .grow:
            growActionsTotal += 1
            UserDefaults.standard.set(growActionsTotal, forKey: "growActionsTotal")
        }
        // triggerPraise は「学んだ」ボタン押下時のみ（InfoDetailSheet から呼ばれる）
    }

    // 今月の守るアクション
    var monthlyProtectActions: [CardAction] {
        let start = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
        return cardActions.filter { $0.category == .protect && $0.date >= start }
    }

    // 今月の増やすアクション
    var monthlyGrowActions: [CardAction] {
        let start = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
        return cardActions.filter { $0.category == .grow && $0.date >= start }
    }

    // MARK: - コミュニティ投稿
    @Published var communityPosts: [CommunityPost] = CommunityPost.sampleData
    @Published var followedNicknames: Set<String> = []
    @Published var postComments: [UUID: [PostComment]] = [:]

    func addComment(postId: UUID, text: String) {
        let comment = PostComment(text: text)
        if postComments[postId] == nil {
            postComments[postId] = [comment]
        } else {
            postComments[postId]?.append(comment)
        }
    }

    func toggleCommentLike(postId: UUID, commentId: UUID) {
        guard let idx = postComments[postId]?.firstIndex(where: { $0.id == commentId }) else { return }
        postComments[postId]?[idx].isLikedByMe.toggle()
        if postComments[postId]?[idx].isLikedByMe == true {
            postComments[postId]?[idx].likeCount += 1
        } else {
            postComments[postId]?[idx].likeCount -= 1
        }
    }

    func commentCount(for postId: UUID) -> Int {
        postComments[postId]?.count ?? 0
    }

    func deleteComment(postId: UUID, commentId: UUID) {
        postComments[postId]?.removeAll { $0.id == commentId }
    }

    func editComment(postId: UUID, commentId: UUID, newText: String) {
        guard let idx = postComments[postId]?.firstIndex(where: { $0.id == commentId }) else { return }
        postComments[postId]?[idx].text = newText
    }

    func toggleCheer(postId: UUID) {
        guard let index = communityPosts.firstIndex(where: { $0.id == postId }) else { return }
        if communityPosts[index].isLikedByMe {
            communityPosts[index].cheerCount -= 1
            communityPosts[index].isLikedByMe = false
        } else {
            communityPosts[index].cheerCount += 1
            communityPosts[index].isLikedByMe = true
        }
    }

    func toggleFollow(nickname: String) {
        if followedNicknames.contains(nickname) {
            followedNicknames.remove(nickname)
        } else {
            followedNicknames.insert(nickname)
        }
    }

    func isFollowing(_ nickname: String) -> Bool {
        followedNicknames.contains(nickname)
    }

    /// おすすめフィード（全体公開の投稿 + 自分の投稿）
    var recommendedPosts: [CommunityPost] {
        communityPosts.filter { $0.visibility == .everyone || $0.isMyPost }
    }

    /// フォロー中フィード（フォロー中ユーザーが見られる投稿 + 自分の投稿）
    var followingPosts: [CommunityPost] {
        communityPosts.filter { post in
            post.isMyPost || followedNicknames.contains(post.nickname)
        }
    }

    /// 自分の投稿一覧（新しい順）
    var myPosts: [CommunityPost] {
        communityPosts.filter { $0.isMyPost }.sorted { $0.date > $1.date }
    }

    func addMyPost(emoji: String, actionText: String, category: PostCategory, visibility: PostVisibility = .everyone) {
        let myLevel: Int = {
            let c = completedTaskIds.count
            if c < 3 { return 1 }
            if c < 7 { return 2 }
            if c < 13 { return 3 }
            if c < 21 { return 4 }
            return 5
        }()
        let post = CommunityPost(
            nickname: communityNickname,
            level: myLevel,
            emoji: emoji,
            actionText: actionText,
            category: category,
            date: Date(),
            cheerCount: 0,
            isLikedByMe: false,
            isMyPost: true,
            badge: nil,
            visibility: visibility,
            consecutiveLoginDays: consecutiveLoginDays
        )
        communityPosts.insert(post, at: 0)
    }

    // MARK: - データリセット（設定から）
    func resetAllData() {
        dataStore.clearAll()
        userProfile = nil
        fixedExpenses = []
        debts = []
        scheduledPayments = []
        completedTaskIds = []
        dailyCompletedKeys = []
        cardActions = []
        communityPosts = CommunityPost.sampleData
        protectActionsTotal = 0
        growActionsTotal = 0
        consecutiveLoginDays = 0
        UserDefaults.standard.removeObject(forKey: "protectActionsTotal")
        UserDefaults.standard.removeObject(forKey: "growActionsTotal")
        UserDefaults.standard.removeObject(forKey: "consecutiveLoginDays")
        UserDefaults.standard.removeObject(forKey: "lastLoginDate")
        UserDefaults.standard.removeObject(forKey: "yarikuri.communityNickname")
    }
}

// MARK: - カードアクション
enum CardCategory: String, Codable { case protect, grow }

struct CardAction: Identifiable, Codable {
    let id: UUID
    let emoji: String
    let title: String
    let category: CardCategory
    let date: Date

    init(emoji: String, title: String, category: CardCategory, date: Date = Date()) {
        self.id = UUID()
        self.emoji = emoji
        self.title = title
        self.category = category
        self.date = date
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

// MARK: - 今日のおすすめ
struct TodayRecommendation {
    var title: String
    var description: String
    var emoji: String
    var actionLabel: String
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

// MARK: - 投稿の公開範囲
enum PostVisibility {
    case everyone      // 全体公開
    case followersOnly // フォロワーのみ

    var label: String {
        switch self {
        case .everyone:      return "全体公開"
        case .followersOnly: return "フォロワーのみ"
        }
    }
    var icon: String {
        switch self {
        case .everyone:      return "globe"
        case .followersOnly: return "lock"
        }
    }
}

// MARK: - コミュニティ投稿カテゴリ
enum PostCategory: String, CaseIterable {
    case protect = "守る"
    case grow    = "増やす"
    case habit   = "習慣"

    var emoji: String {
        switch self {
        case .protect: return "🛡️"
        case .grow:    return "📈"
        case .habit:   return "✅"
        }
    }

    var color: Color {
        switch self {
        case .protect: return Color(red: 0.45, green: 0.32, blue: 0.82)
        case .grow:    return Color(red: 0.18, green: 0.62, blue: 0.35)
        case .habit:   return Color(red: 0.20, green: 0.55, blue: 0.85)
        }
    }
}

// MARK: - コメントモデル
struct PostComment: Identifiable {
    let id: UUID
    var text: String
    let date: Date
    var likeCount: Int
    var isLikedByMe: Bool
    var isMyComment: Bool

    init(text: String, isMyComment: Bool = true) {
        self.id = UUID()
        self.text = text
        self.date = Date()
        self.likeCount = 0
        self.isLikedByMe = false
        self.isMyComment = isMyComment
    }
}

// MARK: - コミュニティ投稿モデル
struct CommunityPost: Identifiable {
    let id: UUID
    let nickname: String
    let level: Int
    let emoji: String
    let actionText: String
    let category: PostCategory
    let date: Date
    var cheerCount: Int
    var isLikedByMe: Bool
    var isMyPost: Bool
    var badge: String?
    var visibility: PostVisibility
    var consecutiveLoginDays: Int   // 連続ログイン日数

    init(nickname: String, level: Int, emoji: String, actionText: String,
         category: PostCategory, date: Date = Date(), cheerCount: Int = 0,
         isLikedByMe: Bool = false, isMyPost: Bool = false, badge: String? = nil,
         visibility: PostVisibility = .everyone, consecutiveLoginDays: Int = 1) {
        self.id         = UUID()
        self.nickname   = nickname
        self.level      = level
        self.emoji      = emoji
        self.actionText = actionText
        self.category   = category
        self.date       = date
        self.cheerCount = cheerCount
        self.isLikedByMe = isLikedByMe
        self.isMyPost   = isMyPost
        self.badge      = badge
        self.visibility = visibility
        self.consecutiveLoginDays = consecutiveLoginDays
    }

    static var sampleData: [CommunityPost] {
        let now = Date()
        func ago(_ m: Double) -> Date { now.addingTimeInterval(-m * 60) }
        return [
            // ── 直近（数分〜数時間前）────────────────────────────
            CommunityPost(nickname: "かなえ", level: 5, emoji: "🏆",
                          actionText: "借金を完全に完済した！夢だったマイホーム計画を始めます",
                          category: .protect, date: ago(8), cheerCount: 142),
            CommunityPost(nickname: "ゆきんこ", level: 3, emoji: "✂️",
                          actionText: "使っていないサブスクを2つ解約した",
                          category: .protect, date: ago(20), cheerCount: 14, consecutiveLoginDays: 22),
            CommunityPost(nickname: "まるこ", level: 2, emoji: "🌱",
                          actionText: "NISAの積立設定をはじめてした",
                          category: .grow, date: ago(60), cheerCount: 28),
            CommunityPost(nickname: "そうた", level: 5, emoji: "📈",
                          actionText: "資産が初めて500万円を突破した。3年前はゼロだったのに",
                          category: .grow, date: ago(90), cheerCount: 98),
            CommunityPost(nickname: "きたじ", level: 4, emoji: "📋",
                          actionText: "固定費を全部書き出して月2万円削減できた",
                          category: .protect, date: ago(120), cheerCount: 9, consecutiveLoginDays: 45),
            CommunityPost(nickname: "ひまわり", level: 1, emoji: "💰",
                          actionText: "先取り貯蓄の自動設定をした。毎月1万円からスタート",
                          category: .habit, date: ago(240), cheerCount: 21),
            // ── 数時間前 ────────────────────────────────────────
            CommunityPost(nickname: "はるひ", level: 5, emoji: "🌍",
                          actionText: "オルカンの積立を3年続けて+42%になった。長期投資の力を実感",
                          category: .grow, date: ago(180), cheerCount: 77),
            CommunityPost(nickname: "たかし", level: 3, emoji: "🎁",
                          actionText: "ふるさと納税の申し込みを完了した。今年はお米10kgをチョイス",
                          category: .grow, date: ago(360), cheerCount: 7, consecutiveLoginDays: 18),
            CommunityPost(nickname: "なつき", level: 2, emoji: "🏥",
                          actionText: "医療費控除の申請方法を調べた。去年10万超えてた",
                          category: .protect, date: ago(480), cheerCount: 33, consecutiveLoginDays: 9),
            CommunityPost(nickname: "みおと", level: 1, emoji: "🏃",
                          actionText: "毎日の家計記録を1週間続けられた！",
                          category: .habit, date: ago(1080), cheerCount: 45),
            CommunityPost(nickname: "こうき", level: 3, emoji: "📱",
                          actionText: "格安SIMに乗り換えた。月4,500円→1,200円に",
                          category: .protect, date: ago(1440), cheerCount: 11, consecutiveLoginDays: 30),
            CommunityPost(nickname: "りか", level: 5, emoji: "💴",
                          actionText: "円安対策で全資産の30%を外貨建てインデックスに移した",
                          category: .grow, date: ago(1800), cheerCount: 54),
            // ── 1日前 ─────────────────────────────────────────
            CommunityPost(nickname: "あやか", level: 2, emoji: "☕",
                          actionText: "コンビニコーヒーをマイボトルに変えた。月3,000円節約",
                          category: .habit, date: ago(1800), cheerCount: 19, consecutiveLoginDays: 11),
            CommunityPost(nickname: "れんじ", level: 4, emoji: "🏯",
                          actionText: "iDeCoの掛け金を上限まで増額した",
                          category: .grow, date: ago(2160), cheerCount: 8, consecutiveLoginDays: 52),
            CommunityPost(nickname: "もとき", level: 3, emoji: "🤖",
                          actionText: "AIを使った副業で今月初めて5万円稼いだ",
                          category: .grow, date: ago(2520), cheerCount: 62),
            CommunityPost(nickname: "はるか", level: 2, emoji: "🛒",
                          actionText: "週1回のまとめ買いを1ヶ月続けた",
                          category: .habit, date: ago(2880), cheerCount: 22, consecutiveLoginDays: 14),
            CommunityPost(nickname: "けんた", level: 3, emoji: "💡",
                          actionText: "電力会社をエネチェンジで比較して乗り換えた",
                          category: .protect, date: ago(3600), cheerCount: 16, consecutiveLoginDays: 33),
            CommunityPost(nickname: "ともこ", level: 5, emoji: "🥂",
                          actionText: "副業収入が本業を超えた月がついに来た。継続は力なり",
                          category: .grow, date: ago(4320), cheerCount: 189),
            // ── 2〜3日前 ──────────────────────────────────────
            CommunityPost(nickname: "さくら", level: 2, emoji: "📊",
                          actionText: "資産状況を書き出して整理した",
                          category: .habit, date: ago(4320), cheerCount: 13),
            CommunityPost(nickname: "ゆうと", level: 4, emoji: "🏠",
                          actionText: "住宅ローン控除の2年目申請を年末調整で完了した",
                          category: .protect, date: ago(5040), cheerCount: 24, consecutiveLoginDays: 41),
            CommunityPost(nickname: "まひろ", level: 1, emoji: "✅",
                          actionText: "今日から家計簿アプリを始めた。ゼロからのスタート",
                          category: .habit, date: ago(6480), cheerCount: 38),
            CommunityPost(nickname: "しんご", level: 3, emoji: "🎬",
                          actionText: "動画編集の副業で初案件を受注できた",
                          category: .grow, date: ago(7200), cheerCount: 47, consecutiveLoginDays: 19),
            CommunityPost(nickname: "なみ", level: 4, emoji: "🛡️",
                          actionText: "生命保険を見直して月1万円削減。FP無料相談が神だった",
                          category: .protect, date: ago(8640), cheerCount: 35, consecutiveLoginDays: 60),
            // ── 4〜7日前 ──────────────────────────────────────
            CommunityPost(nickname: "りょう", level: 2, emoji: "🍱",
                          actionText: "お弁当持参を3週間続けた。月8,000円節約できた計算",
                          category: .habit, date: ago(10080), cheerCount: 29, consecutiveLoginDays: 21),
            CommunityPost(nickname: "ちはる", level: 5, emoji: "🌟",
                          actionText: "高配当株ポートフォリオからの配当金が月3万円を超えた",
                          category: .grow, date: ago(11520), cheerCount: 103),
            CommunityPost(nickname: "あきら", level: 3, emoji: "📚",
                          actionText: "FP2級に合格した。お金の知識が確実に増えてる",
                          category: .grow, date: ago(12960), cheerCount: 68),
            CommunityPost(nickname: "はな", level: 1, emoji: "💳",
                          actionText: "リボ払いを止めて一括払いに切り替えた",
                          category: .protect, date: ago(14400), cheerCount: 51),
            CommunityPost(nickname: "のぞみ", level: 2, emoji: "🔄",
                          actionText: "毎月の自動積立を5,000円→10,000円に増額した",
                          category: .habit, date: ago(15840), cheerCount: 17, consecutiveLoginDays: 13),
            CommunityPost(nickname: "だいき", level: 4, emoji: "🏗️",
                          actionText: "副業が軌道に乗り個人事業主として開業届を出した",
                          category: .grow, date: ago(17280), cheerCount: 82),
            CommunityPost(nickname: "ふみか", level: 3, emoji: "♻️",
                          actionText: "メルカリで不用品を売って今月2万円になった",
                          category: .habit, date: ago(20160), cheerCount: 25, consecutiveLoginDays: 16),
            // ── 1〜2週間前 ────────────────────────────────────
            CommunityPost(nickname: "いずみ", level: 2, emoji: "🧾",
                          actionText: "ずっと後回しにしていた確定申告を終わらせた。還付金3万円！",
                          category: .protect, date: ago(21600), cheerCount: 58, consecutiveLoginDays: 7),
            CommunityPost(nickname: "たつや", level: 4, emoji: "🎯",
                          actionText: "投資信託の積立を毎月3万円に増やした。老後が楽しみになってきた",
                          category: .grow, date: ago(23040), cheerCount: 41),
            CommunityPost(nickname: "みさき", level: 1, emoji: "📝",
                          actionText: "はじめて固定費を全部書き出してみた。思ったより多くてびっくり",
                          category: .habit, date: ago(25200), cheerCount: 32, consecutiveLoginDays: 3),
            CommunityPost(nickname: "こうへい", level: 3, emoji: "🚲",
                          actionText: "車を手放して自転車通勤に切り替えた。維持費が月3万円浮いた",
                          category: .protect, date: ago(27360), cheerCount: 71),
            CommunityPost(nickname: "あかり", level: 5, emoji: "💎",
                          actionText: "資産1000万円達成。5年かかったけどやっと到達できた",
                          category: .grow, date: ago(28800), cheerCount: 215),
            CommunityPost(nickname: "けいすけ", level: 2, emoji: "🍳",
                          actionText: "外食を週1回に減らして自炊を始めた。食費が半分になった",
                          category: .habit, date: ago(30240), cheerCount: 18, consecutiveLoginDays: 8),
            CommunityPost(nickname: "ゆり", level: 3, emoji: "🏦",
                          actionText: "ネット銀行に乗り換えて金利が100倍になった。小さいけど嬉しい",
                          category: .protect, date: ago(32400), cheerCount: 12, consecutiveLoginDays: 25),
            CommunityPost(nickname: "しょうた", level: 4, emoji: "💻",
                          actionText: "プログラミング副業で今月8万円達成。スキルが武器になってる",
                          category: .grow, date: ago(34560), cheerCount: 94, consecutiveLoginDays: 37),
            CommunityPost(nickname: "まなみ", level: 1, emoji: "🌸",
                          actionText: "ポイ活を始めた。先月だけで3,200円分のポイントが貯まった",
                          category: .habit, date: ago(36720), cheerCount: 27, consecutiveLoginDays: 5),
            CommunityPost(nickname: "りくと", level: 3, emoji: "📡",
                          actionText: "スマホを格安SIMに変更+プランを最適化。月7,000円の節約",
                          category: .protect, date: ago(38880), cheerCount: 33, consecutiveLoginDays: 20),
            CommunityPost(nickname: "のり", level: 5, emoji: "🏝️",
                          actionText: "FIRE達成。毎月の配当収入が生活費を上回った",
                          category: .grow, date: ago(41040), cheerCount: 312),
            CommunityPost(nickname: "さえこ", level: 2, emoji: "🧊",
                          actionText: "冷蔵庫の食材を使い切る「在庫一掃週」を実践。食費ゼロの週があった",
                          category: .habit, date: ago(43200), cheerCount: 44, consecutiveLoginDays: 10),
            CommunityPost(nickname: "ひろし", level: 4, emoji: "📉",
                          actionText: "住宅ローンを繰上返済した。利息が80万円以上減った計算",
                          category: .protect, date: ago(46080), cheerCount: 86),
            CommunityPost(nickname: "かほ", level: 2, emoji: "🌿",
                          actionText: "節電を意識したら電気代が先月より2,000円下がった",
                          category: .habit, date: ago(48960), cheerCount: 15, consecutiveLoginDays: 12),
            CommunityPost(nickname: "ともひろ", level: 3, emoji: "🎤",
                          actionText: "ライター副業を開始。初月から月2万円の収入が得られた",
                          category: .grow, date: ago(50400), cheerCount: 39, consecutiveLoginDays: 28),
            CommunityPost(nickname: "ゆか", level: 1, emoji: "🛍️",
                          actionText: "衝動買いをやめるために48時間ルールを始めた",
                          category: .habit, date: ago(52560), cheerCount: 22, consecutiveLoginDays: 6),
            CommunityPost(nickname: "まさき", level: 4, emoji: "⚡",
                          actionText: "太陽光パネルを設置して電気代がほぼゼロになった",
                          category: .protect, date: ago(55440), cheerCount: 67),
            CommunityPost(nickname: "えりか", level: 3, emoji: "🎨",
                          actionText: "イラスト販売を始めて今月初めて1万円を突破した",
                          category: .grow, date: ago(58320), cheerCount: 53, consecutiveLoginDays: 31),
            CommunityPost(nickname: "だいち", level: 2, emoji: "🧮",
                          actionText: "家計簿を3ヶ月続けたら支出パターンが見えてきた",
                          category: .habit, date: ago(60480), cheerCount: 36, consecutiveLoginDays: 90),
            CommunityPost(nickname: "ひなた", level: 5, emoji: "🚀",
                          actionText: "株の配当+副業+給料で3本柱の収入源を作れた",
                          category: .grow, date: ago(63360), cheerCount: 127),
        ]
    }
}
