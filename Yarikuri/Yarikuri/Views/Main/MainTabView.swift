import SwiftUI
import AVFoundation
import UIKit
import Charts

// MARK: - メインタブビュー（スワイプ対応）
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { HomeView() }
                .tag(0)
                .tabItem { Image(systemName: "house") }
            InputTabView()
                .tag(1)
                .tabItem { Image(systemName: "pencil") }
            NavigationStack { ProtectScreenView() }
                .tag(2)
                .tabItem { Image(systemName: "chart.line.downtrend.xyaxis") }
            NavigationStack { GrowScreenView() }
                .tag(3)
                .tabItem { Image(systemName: "chart.line.uptrend.xyaxis") }
        }
        .background(AppColor.background)
        .overlay {
            if let praise = appState.currentPraise {
                YarikurinPraiseView(item: praise)
                    .transition(.opacity)
                    .id(praise.id)
            }
        }
        .animation(.none, value: appState.currentPraise)
        .simultaneousGesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .local)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = abs(value.translation.height)
                    // 横方向が縦の2倍以上の場合のみタブ切り替え（誤タップ防止）
                    guard abs(horizontal) > vertical * 2 else { return }
                    if horizontal < 0 {
                        selectedTab = min(selectedTab + 1, 3)
                    } else {
                        selectedTab = max(selectedTab - 1, 0)
                    }
                }
        )
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToTab"))) { notification in
            if let tab = notification.object as? Int {
                selectedTab = tab
            }
        }
        .onAppear {
            BackgroundMusicPlayer.shared.start()
            UITabBarItem.appearance().imageInsets = UIEdgeInsets(top: -14, left: 0, bottom: 14, right: 0)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            BackgroundMusicPlayer.shared.stop()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            BackgroundMusicPlayer.shared.start()
        }
    }
}

// MARK: - みんなの行動画面
struct CommunityScreenView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: FeedTab = .recommend
    @State private var activeSheet: CommunityActiveSheet? = nil

    private var posts: [CommunityPost] {
        switch selectedTab {
        case .recommend: return appState.recommendedPosts
        case .following: return appState.followingPosts
        case .mine:      return appState.myPosts
        }
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            ScrollView(showsIndicators: true) {
                VStack(spacing: 16) {
                    HStack {
                        Text("みんなの行動")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
                        Button(action: { activeSheet = .compose }) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 20))
                                .foregroundColor(AppColor.primary)
                        }
                    }
                    .padding(.top, 8)

                    FeedTabBar(selected: $selectedTab)

                    if posts.isEmpty {
                        emptyView
                    } else {
                        ForEach(posts) { post in
                            CommunityPostCard(post: post,
                                             onCommentTap: { activeSheet = .comment(post) })
                        }
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        // シートを1つに統合してSwiftUIの多重sheet競合を回避
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .comment(let post):
                CommentSheet(post: post)
                    .environmentObject(appState)
            case .compose:
                PostComposerSheet()
                    .environmentObject(appState)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Text(selectedTab == .following ? "👤" : "📭")
                .font(.system(size: 40))
            Text(selectedTab == .following
                 ? "まだフォロー中のユーザーがいません"
                 : "投稿がありません")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColor.textSecondary)
            if selectedTab == .following {
                Text("おすすめタブから気になる人を\nフォローしてみましょう")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// シート種別（1つのsheet(item:)で管理するため）
enum CommunityActiveSheet: Identifiable {
    case comment(CommunityPost)
    case compose

    var id: String {
        switch self {
        case .comment(let p): return "comment-\(p.id)"
        case .compose: return "compose"
        }
    }
}

// MARK: - 支出を減らす画面
struct ProtectScreenView: View {
    @EnvironmentObject var appState: AppState
    @State private var showReport        = false
    @State private var showFixedExpense  = false
    @State private var showDebtNavi      = false
    @State private var showPayment       = false
    @State private var showSupport       = false
    @State private var showHowTo         = false
    @State private var showSecret        = false
    @State private var showLayoutEdit    = false

    private var visibleProtectCards: [String] {
        appState.protectCardOrder.filter { !appState.protectHiddenCards.contains($0) }
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    HStack {
                        Text("支出を減らす")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
                        Button(action: { showLayoutEdit = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18))
                                .foregroundColor(AppColor.primary)
                        }
                        Button(action: { showReport = true }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppColor.primary)
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.top, 8)

                    if !appState.protectHiddenCards.contains("summaryCard") {
                        ProtectSummaryCard()
                    }
                    if !appState.protectHiddenCards.contains("animationRoom") {
                        ProtectAnimationView()
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(visibleProtectCards, id: \.self) { cardId in
                            protectNavCardView(for: cardId)
                        }
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .sheet(isPresented: $showReport)       { MonthlyReportView() }
        .sheet(isPresented: $showFixedExpense) { FixedExpenseView() }
        .sheet(isPresented: $showDebtNavi)     { DebtNaviView() }
        .sheet(isPresented: $showPayment)      { PaymentDetailView() }
        .sheet(isPresented: $showSupport)      { SupportSystemView() }
        .sheet(isPresented: $showHowTo)        { ProtectHowToSheet() }
        .sheet(isPresented: $showSecret)       { ProtectSecretSheet() }
        .sheet(isPresented: $showLayoutEdit)   { ProtectLayoutEditSheet().environmentObject(appState) }
    }

    @ViewBuilder
    private func protectNavCardView(for id: String) -> some View {
        switch id {
        case "fixedExpense":
            ProtectNavCard(
                emoji: "📋", title: "固定費",
                subtitle: appState.fixedExpenses.isEmpty ? "未登録" : appState.totalFixedExpenses.yen,
                color: AppColor.primary,
                action: { showFixedExpense = true }
            )
        case "variablePayment":
            ProtectNavCard(
                emoji: "📅", title: "今月の変動費",
                subtitle: appState.scheduledPaymentsThisMonth.isEmpty ? "支払いなし" : appState.totalScheduledPayments.yen,
                color: AppColor.caution,
                action: { showPayment = true }
            )
        case "debtNavi":
            ProtectNavCard(
                emoji: "💳", title: "借金返済ナビ",
                subtitle: appState.debts.isEmpty ? "借入なし" : "月返済額 \(appState.debts.reduce(0){ $0 + $1.monthlyPayment }.yen)",
                color: AppColor.danger,
                action: { showDebtNavi = true }
            )
        case "support":
            ProtectNavCard(
                emoji: "🤝", title: "使える制度・給付",
                subtitle: "補助金・公的支援を確認",
                color: Color(red: 0.18, green: 0.62, blue: 0.35),
                action: { showSupport = true }
            )
        case "howTo":
            ProtectNavCard(
                emoji: "🛡️", title: "支出の減らし方",
                subtitle: "節約・支出削減の知識",
                color: AppColor.secondary,
                action: { showHowTo = true }
            )
        case "secret":
            LockedNavCard(
                unlockedEmoji: "🔑",
                unlockedTitle: "節約裏ワザ集",
                unlockedSubtitle: "知らないと損する節約術",
                unlockedColor: Color(red: 0.85, green: 0.55, blue: 0.10),
                currentDays: appState.consecutiveLoginDays,
                action: { showSecret = true }
            )
            .gridCellColumns(2)
        default:
            EmptyView()
        }
    }
}

// MARK: - 守るナビカード
private struct ProtectNavCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 9) {
                Text(emoji)
                    .font(.system(size: 36))
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                Text(subtitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .padding(.horizontal, 8)
            .background(AppColor.cardBackground)
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(0.25), lineWidth: 1.5))
            .shadow(color: AppColor.shadowColor, radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 守り方シート
struct ProtectHowToSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ProtectTabContent()
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("守り方")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 収入を増やす画面
struct GrowScreenView: View {
    @EnvironmentObject var appState: AppState
    @State private var showReport      = false
    @State private var showIncome      = false
    @State private var showFukugyou    = false
    @State private var showCareer      = false
    @State private var showSetsuzei    = false
    @State private var showNisa        = false
    @State private var showMaster      = false
    @State private var showLayoutEdit  = false

    private var visibleGrowCards: [String] {
        appState.growCardOrder.filter { !appState.growHiddenCards.contains($0) }
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    HStack {
                        Text("収入を増やす")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
                        Button(action: { showLayoutEdit = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18))
                                .foregroundColor(AppColor.primary)
                        }
                        Button(action: { showReport = true }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppColor.primary)
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.top, 8)

                    if !appState.growHiddenCards.contains("summaryCard") {
                        GrowSummaryCard()
                    }
                    if !appState.growHiddenCards.contains("animationRoom") {
                        GrowAnimationView()
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(visibleGrowCards, id: \.self) { cardId in
                            growNavCardView(for: cardId)
                        }
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .sheet(isPresented: $showReport)       { MonthlyReportView() }
        .sheet(isPresented: $showIncome)       { IncomeTrackerSheet() }
        .sheet(isPresented: $showFukugyou)     { GrowFukugyouSheet() }
        .sheet(isPresented: $showCareer)       { GrowCareerSheet() }
        .sheet(isPresented: $showSetsuzei)     { GrowSetsuzeiSheet() }
        .sheet(isPresented: $showNisa)         { GrowNisaSheet() }
        .sheet(isPresented: $showMaster)       { GrowMasterSheet() }
        .sheet(isPresented: $showLayoutEdit)   { GrowLayoutEditSheet().environmentObject(appState) }
    }

    @ViewBuilder
    private func growNavCardView(for id: String) -> some View {
        switch id {
        case "income":
            GrowNavCard(emoji: "💴", title: "収入",
                        subtitle: incomeSubtitle,
                        color: Color.green.opacity(0.8),
                        action: { showIncome = true })
        case "fukugyou":
            GrowNavCard(emoji: "🎥", title: "副業で稼ぐ",
                        subtitle: "YouTube・クラウド等9種",
                        color: Color.red.opacity(0.75),
                        action: { showFukugyou = true })
        case "nisa":
            GrowNavCard(emoji: "🌱", title: "NISA・投資",
                        subtitle: "積立・成長投資枠等",
                        color: Color(red: 0.18, green: 0.62, blue: 0.35),
                        action: { showNisa = true })
        case "setsuzei":
            GrowNavCard(emoji: "🏯", title: "節税",
                        subtitle: "ふるさと納税・iDeCo等",
                        color: Color.orange.opacity(0.85),
                        action: { showSetsuzei = true })
        case "career":
            GrowNavCard(emoji: "🏢", title: "キャリア・転職",
                        subtitle: "転職・資格・独立",
                        color: Color.indigo.opacity(0.8),
                        action: { showCareer = true })
        case "master":
            LockedNavCard(
                unlockedEmoji: "👑",
                unlockedTitle: "マネーマスター術",
                unlockedSubtitle: "上級者向けのお金の増やし方",
                unlockedColor: Color(red: 0.55, green: 0.30, blue: 0.90),
                currentDays: appState.consecutiveLoginDays,
                action: { showMaster = true }
            )
        default:
            EmptyView()
        }
    }

    private var incomeSubtitle: String {
        guard let latest = appState.incomeHistory.sorted(by: {
            if $0.year != $1.year { return $0.year > $1.year }
            return $0.month > $1.month
        }).first else { return "収入を記録する" }
        return "\(latest.displayLabel): ¥\(latest.amount / 10000)万"
    }
}

// MARK: - 増やすナビカード
private struct GrowNavCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 9) {
                Text(emoji)
                    .font(.system(size: 36))
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(subtitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .padding(.horizontal, 8)
            .background(AppColor.cardBackground)
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(0.25), lineWidth: 1.5))
            .shadow(color: AppColor.shadowColor, radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 守るサマリーカード
struct ProtectSummaryCard: View {
    @EnvironmentObject var appState: AppState
    @State private var showDetail = false

    var body: some View {
        VStack(spacing: 0) {
            // 上段：2指標横並び
            HStack(spacing: 0) {
                // 今月の支出
                VStack(alignment: .leading, spacing: 3) {
                    Text("💰 今月の支出")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textSecondary)
                    Text(appState.monthlyTotalExpenses.yen)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColor.primary)
                        .minimumScaleFactor(0.7).lineLimit(1)
                    let diff = appState.expensesComparedToLastMonth
                    HStack(spacing: 3) {
                        Image(systemName: diff > 0 ? "arrow.up" : diff < 0 ? "arrow.down" : "minus")
                            .font(.system(size: 9, weight: .bold))
                        Text("先月比\(diff > 0 ? "+" : "")\(diff.yen)")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(diff > 0 ? AppColor.danger : diff < 0 ? AppColor.secondary : AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider().frame(height: 48).padding(.horizontal, 8)

                // 残予算
                VStack(alignment: .leading, spacing: 3) {
                    Text("💳 残予算")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textSecondary)
                    Text(appState.remainingBudget.yen)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(appState.remainingBudget >= 0 ? AppColor.safe : AppColor.danger)
                        .minimumScaleFactor(0.7).lineLimit(1)
                    Text("手取りから計算")
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)

            Divider().padding(.horizontal, 12)

            // 下段：詳細ボタン（全幅）
            Button(action: { showDetail = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 13))
                    Text("グラフで詳細を見る")
                        .font(.system(size: 13, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(AppColor.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.93, green: 0.91, blue: 1.0), AppColor.primaryLight],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showDetail) {
            ExpenseChartSheet()
        }
    }
}

// MARK: - 増やすサマリーカード
struct GrowSummaryCard: View {
    @EnvironmentObject var appState: AppState
    @State private var showDetail = false

    private let incomeGreen = Color(red: 0.2, green: 0.6, blue: 0.3)

    var body: some View {
        VStack(spacing: 0) {
            // 上段：2指標横並び
            HStack(spacing: 0) {
                // 先月の収入
                VStack(alignment: .leading, spacing: 3) {
                    Text("💹 先月の収入")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textSecondary)
                    Text(appState.lastMonthIncome.yen)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(incomeGreen)
                        .minimumScaleFactor(0.7).lineLimit(1)
                    let diff = appState.incomeComparedToPreviousMonth
                    HStack(spacing: 3) {
                        Image(systemName: diff > 0 ? "arrow.up" : diff < 0 ? "arrow.down" : "minus")
                            .font(.system(size: 9, weight: .bold))
                        Text("先々月比\(diff > 0 ? "+" : "")\(diff.yen)")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(diff > 0 ? AppColor.tertiary : diff < 0 ? AppColor.danger : AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider().frame(height: 48).padding(.horizontal, 8)

                // 今月の手取り目安
                VStack(alignment: .leading, spacing: 3) {
                    Text("💴 今月の手取り")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textSecondary)
                    Text(appState.monthlyIncome.yen)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColor.textPrimary)
                        .minimumScaleFactor(0.7).lineLimit(1)
                    Text("目安ベース")
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)

            Divider().padding(.horizontal, 12)

            // 下段：詳細ボタン（全幅）
            Button(action: { showDetail = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 13))
                    Text("グラフで詳細を見る")
                        .font(.system(size: 13, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(incomeGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.90, green: 0.98, blue: 0.91), Color(red: 0.99, green: 0.98, blue: 0.85)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showDetail) {
            IncomeChartSheet()
        }
    }
}

// MARK: - 支出グラフシート
struct ExpenseChartSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // 積み上げ棒グラフ用データ
    private struct StackItem: Identifiable {
        let id = UUID()
        let monthKey: Int    // yyyyMM（軸の順序づけ用）
        let monthLabel: String
        let category: String
        let amount: Int
    }

    private let categoryOrder = ["固定費", "変動費", "月返済額"]
    private let categoryColors: [String: Color] = [
        "固定費":   AppColor.primary,
        "変動費":   AppColor.caution,
        "月返済額": AppColor.danger,
    ]

    private var stackItems: [StackItem] {
        let cal = Calendar.current
        let now = Date()
        var result: [StackItem] = []
        for offset in stride(from: -11, through: 0, by: 1) {
            guard let date = cal.date(byAdding: .month, value: offset, to: now) else { continue }
            let y = cal.component(.year, from: date)
            let m = cal.component(.month, from: date)
            let key = y * 100 + m
            let label = "\(m)月"
            let fixed: Int
            let variable: Int
            if offset == 0 {
                fixed    = appState.totalFixedExpenses
                variable = appState.totalScheduledPayments
            } else {
                guard let f = appState.fixedExpenseHistory.first(where: { $0.year == y && $0.month == m })?.totalAmount else { continue }
                fixed    = f
                variable = appState.scheduledPaymentHistory.first(where: { $0.year == y && $0.month == m })?.totalAmount ?? 0
            }
            let debt = appState.totalMonthlyDebtPayments
            result.append(StackItem(monthKey: key, monthLabel: label, category: "固定費",   amount: fixed))
            result.append(StackItem(monthKey: key, monthLabel: label, category: "変動費",   amount: variable))
            result.append(StackItem(monthKey: key, monthLabel: label, category: "月返済額", amount: debt))
        }
        return result
    }

    // 表示用月キー（重複なし・昇順）
    private var sortedMonthKeys: [Int] {
        Array(Set(stackItems.map(\.monthKey))).sorted()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        summaryCard
                        stackedChartCard
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("支出の推移")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }

    // MARK: サマリー
    private var summaryCard: some View {
        let diff = appState.expensesComparedToLastMonth
        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("今月の支出合計")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
                Text(appState.monthlyTotalExpenses.yen)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColor.primary)
                Text("先月比 \(diff > 0 ? "+" : "")\(diff.yen)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(diff > 0 ? AppColor.danger : diff < 0 ? AppColor.secondary : AppColor.textSecondary)
            }
            Divider()
            HStack(spacing: 0) {
                summaryItem(label: "固定費",   amount: appState.totalFixedExpenses,         color: AppColor.primary)
                Divider().frame(height: 36)
                summaryItem(label: "変動費",   amount: appState.totalScheduledPayments,     color: AppColor.caution)
                Divider().frame(height: 36)
                summaryItem(label: "月返済額", amount: appState.totalMonthlyDebtPayments,   color: AppColor.danger)
            }
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
    }

    private func summaryItem(label: String, amount: Int, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppColor.textSecondary)
            Text(amount.yen)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
                .minimumScaleFactor(0.7).lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: 積み上げ棒グラフ
    private var stackedChartCard: some View {
        let items = stackItems
        let keys = sortedMonthKeys
        return VStack(alignment: .leading, spacing: 14) {
            Text("月別支出内訳（過去1年）")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            if items.isEmpty {
                Text("データがありません")
                    .foregroundColor(AppColor.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                Chart(items) { item in
                    BarMark(
                        x: .value("月", item.monthKey),
                        y: .value("金額", item.amount)
                    )
                    .foregroundStyle(categoryColors[item.category] ?? .gray)
                }
                .chartXAxis {
                    AxisMarks(values: keys) { val in
                        AxisValueLabel {
                            if let key = val.as(Int.self),
                               let item = items.first(where: { $0.monthKey == key }) {
                                Text(item.monthLabel)
                                    .font(.system(size: 9))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { val in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = val.as(Int.self) {
                                Text("\(v / 10000)万")
                                    .font(.system(size: 9))
                            }
                        }
                    }
                }
                .chartLegend(.hidden)
                .frame(height: 220)

                // 凡例
                HStack(spacing: 16) {
                    ForEach(categoryOrder, id: \.self) { cat in
                        HStack(spacing: 5) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(categoryColors[cat] ?? .gray)
                                .frame(width: 12, height: 12)
                            Text(cat)
                                .font(.system(size: 11))
                                .foregroundColor(AppColor.textSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
    }
}

// MARK: - 収入グラフシート
struct IncomeChartSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let incomeGreen = Color(red: 0.2, green: 0.6, blue: 0.3)

    private struct BarData: Identifiable {
        let id = UUID()
        let label: String
        let value: Int
        let isLatest: Bool
    }

    private var chartData: [BarData] {
        let cal = Calendar.current
        let now = Date()
        var result: [BarData] = []
        // 直近6ヶ月分を探す（先月〜6ヶ月前）
        for offset in stride(from: -5, through: -1, by: 1) {
            guard let date = cal.date(byAdding: .month, value: offset, to: now) else { continue }
            let y = cal.component(.year, from: date)
            let m = cal.component(.month, from: date)
            guard let record = appState.incomeHistory.first(where: { $0.year == y && $0.month == m }) else { continue }
            result.append(BarData(label: "\(m)月", value: record.amount, isLatest: offset == -1))
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        summaryCard
                        barChartCard
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("収入の推移")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(incomeGreen)
                }
            }
        }
    }

    private var summaryCard: some View {
        let diff = appState.incomeComparedToPreviousMonth
        return HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("先月の収入")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
                Text(appState.lastMonthIncome.yen)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(incomeGreen)
                Text("先々月比 \(diff > 0 ? "+" : "")\(diff.yen)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(diff > 0 ? AppColor.tertiary : diff < 0 ? AppColor.danger : AppColor.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
    }

    private var barChartCard: some View {
        let data = chartData
        let maxVal = data.map(\.value).max() ?? 1
        return VStack(alignment: .leading, spacing: 16) {
            Text("月別収入（直近6ヶ月）")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)
            if data.isEmpty {
                Text("データがありません")
                    .foregroundColor(AppColor.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(data) { bar in
                        let ratio = maxVal > 0 ? CGFloat(bar.value) / CGFloat(maxVal) : 0
                        VStack(spacing: 4) {
                            Text(bar.value >= 10000 ? "\(bar.value / 10000)万" : "\(bar.value / 1000)千")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(bar.isLatest ? incomeGreen : AppColor.textTertiary)
                                .lineLimit(1)
                            RoundedRectangle(cornerRadius: 5)
                                .fill(bar.isLatest ? incomeGreen : incomeGreen.opacity(0.35))
                                .frame(height: max(4, 160 * ratio))
                            Text(bar.label)
                                .font(.system(size: 10))
                                .foregroundColor(bar.isLatest ? incomeGreen : AppColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
    }
}

// MARK: - ロック付きナビカード（7日連続ログインで解放）
private struct LockedNavCard: View {
    let unlockedEmoji: String
    let unlockedTitle: String
    let unlockedSubtitle: String
    let unlockedColor: Color
    let currentDays: Int
    let action: () -> Void

    private var isUnlocked: Bool { currentDays >= 7 }

    @State private var shimmerPhase: CGFloat = -1.0
    @State private var sparkleScale: CGFloat = 1.0
    @State private var sparkleOpacity: Double = 0.6

    var body: some View {
        Button(action: { if isUnlocked { action() } }) {
            ZStack {
                if isUnlocked {
                    VStack(spacing: 9) {
                        Text(unlockedEmoji).font(.system(size: 36))
                        Text(unlockedTitle)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                            .multilineTextAlignment(.center).lineLimit(1)
                        Text(unlockedSubtitle)
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSecondary)
                            .multilineTextAlignment(.center).lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14).padding(.horizontal, 8)
                    .background(LinearGradient(colors: [unlockedColor.opacity(0.12), unlockedColor.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(unlockedColor.opacity(0.4), lineWidth: 2))
                    .shadow(color: unlockedColor.opacity(0.15), radius: 8, x: 0, y: 3)
                } else {
                    VStack(spacing: 8) {
                        ZStack {
                            ForEach(0..<5, id: \.self) { i in
                                Text("✨").font(.system(size: 11))
                                    .offset(x: CGFloat([-28, 28, -18, 22, 0][i]), y: CGFloat([-22, -18, 16, 14, -30][i]))
                                    .scaleEffect(sparkleScale)
                                    .opacity(sparkleOpacity * [0.9, 0.7, 1.0, 0.8, 0.6][i])
                                    .animation(.easeInOut(duration: 1.2 + Double(i) * 0.3).repeatForever(autoreverses: true).delay(Double(i) * 0.25), value: sparkleScale)
                            }
                            Text("❓").font(.system(size: 32))
                                .scaleEffect(sparkleScale * 0.95 + 0.05)
                                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: sparkleScale)
                        }
                        .frame(height: 56)

                        Text("7日連続ログインで解放")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.0))

                        VStack(spacing: 4) {
                            HStack {
                                Text("現在 \(currentDays)日").font(.system(size: 10)).foregroundColor(.gray)
                                Spacer()
                                Text("目標 7日").font(.system(size: 10)).foregroundColor(.gray)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.gray.opacity(0.2)).frame(height: 6)
                                    Capsule()
                                        .fill(LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * min(CGFloat(currentDays) / 7.0, 1.0), height: 6)
                                        .overlay(
                                            GeometryReader { bar in
                                                Rectangle()
                                                    .fill(LinearGradient(colors: [.clear, .white.opacity(0.6), .clear], startPoint: .leading, endPoint: .trailing))
                                                    .frame(width: bar.size.width * 0.4)
                                                    .offset(x: bar.size.width * shimmerPhase)
                                                    .clipped()
                                            }
                                        )
                                        .clipShape(Capsule())
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20).padding(.horizontal, 12)
                    .background(LinearGradient(colors: [Color(red: 1.0, green: 0.97, blue: 0.82), Color(red: 1.0, green: 0.93, blue: 0.70)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(LinearGradient(colors: [Color.yellow.opacity(0.7), Color.orange.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5))
                    .shadow(color: Color.orange.opacity(0.15), radius: 6, x: 0, y: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            guard !isUnlocked else { return }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                sparkleScale = 1.08; sparkleOpacity = 1.0
            }
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.5
            }
        }
    }
}

// MARK: - 支出を減らすタブ レイアウト編集シート
private struct ProtectLayoutEditSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var order: [String] = []
    @State private var hidden: Set<String> = []

    private let allCards: [(id: String, emoji: String, name: String, locked: Bool)] = [
        ("fixedExpense",    "📋", "固定費",          false),
        ("variablePayment", "📅", "今月の変動費",     false),
        ("debtNavi",        "💳", "借金返済ナビ",     false),
        ("support",         "🤝", "使える制度・給付", false),
        ("howTo",           "🛡️", "支出の減らし方",   false),
        ("secret",          "🔑", "節約裏ワザ集",     true),
    ]

    private let fixedItems: [(id: String, emoji: String, name: String)] = [
        ("summaryCard",   "📊", "サマリーカード"),
        ("animationRoom", "🏠", "やりくりんの部屋"),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(fixedItems, id: \.id) { item in
                        HStack(spacing: 14) {
                            Button { toggle(item.id) } label: {
                                Image(systemName: hidden.contains(item.id) ? "eye.slash" : "eye")
                                    .font(.system(size: 17))
                                    .foregroundColor(hidden.contains(item.id) ? AppColor.textTertiary : AppColor.primary)
                                    .frame(width: 28, height: 28)
                            }
                            .buttonStyle(.plain)

                            Text(item.emoji).font(.system(size: 20))

                            Text(item.name)
                                .font(.system(size: 15))
                                .foregroundColor(hidden.contains(item.id) ? AppColor.textTertiary : AppColor.textPrimary)

                            Spacer()
                        }
                    }
                } header: {
                    Text("👁 で表示/非表示を切り替え（固定）")
                        .font(.system(size: 12))
                }

                Section {
                    ForEach(order, id: \.self) { cardId in
                        if let card = allCards.first(where: { $0.id == cardId }) {
                            HStack(spacing: 14) {
                                Button { toggle(cardId) } label: {
                                    Image(systemName: hidden.contains(cardId) ? "eye.slash" : "eye")
                                        .font(.system(size: 17))
                                        .foregroundColor(hidden.contains(cardId) ? AppColor.textTertiary : AppColor.primary)
                                        .frame(width: 28, height: 28)
                                }
                                .buttonStyle(.plain)

                                Text(card.emoji).font(.system(size: 20))

                                Text(card.name)
                                    .font(.system(size: 15))
                                    .foregroundColor(hidden.contains(cardId) ? AppColor.textTertiary : AppColor.textPrimary)

                                Spacer()

                                if card.locked {
                                    Text("🔒").font(.system(size: 13))
                                }
                            }
                        }
                    }
                    .onMove { from, to in order.move(fromOffsets: from, toOffset: to) }
                } header: {
                    Text("≡ で並び替え・👁 で表示/非表示を切り替え")
                        .font(.system(size: 12))
                }
            }
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        appState.protectCardOrder = order
                        appState.protectHiddenCards = hidden
                        dismiss()
                    }
                    .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .principal) {
                    Text("レイアウトを編集")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { dismiss() }
                }
            }
            .onAppear {
                order = appState.protectCardOrder
                hidden = appState.protectHiddenCards
            }
        }
    }

    private func toggle(_ id: String) {
        if hidden.contains(id) { hidden.remove(id) } else { hidden.insert(id) }
    }
}

// MARK: - 収入を増やすタブ レイアウト編集シート
private struct GrowLayoutEditSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var order: [String] = []
    @State private var hidden: Set<String> = []

    private let fixedItems: [(id: String, emoji: String, name: String)] = [
        ("summaryCard",   "📊", "サマリーカード"),
        ("animationRoom", "🏠", "やりくりんの部屋"),
    ]

    private let allCards: [(id: String, emoji: String, name: String, locked: Bool)] = [
        ("income",    "💴", "収入",           false),
        ("fukugyou",  "🎥", "副業で稼ぐ",     false),
        ("nisa",      "🌱", "NISA・投資",     false),
        ("setsuzei",  "🏯", "節税",           false),
        ("career",    "🏢", "キャリア・転職", false),
        ("master",    "👑", "マネーマスター術", true),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(fixedItems, id: \.id) { item in
                        HStack(spacing: 14) {
                            Button { toggle(item.id) } label: {
                                Image(systemName: hidden.contains(item.id) ? "eye.slash" : "eye")
                                    .font(.system(size: 17))
                                    .foregroundColor(hidden.contains(item.id) ? AppColor.textTertiary : AppColor.primary)
                                    .frame(width: 28, height: 28)
                            }
                            .buttonStyle(.plain)

                            Text(item.emoji).font(.system(size: 20))

                            Text(item.name)
                                .font(.system(size: 15))
                                .foregroundColor(hidden.contains(item.id) ? AppColor.textTertiary : AppColor.textPrimary)

                            Spacer()
                        }
                    }
                } header: {
                    Text("👁 で表示/非表示を切り替え（固定）")
                        .font(.system(size: 12))
                }

                Section {
                    ForEach(order, id: \.self) { cardId in
                        if let card = allCards.first(where: { $0.id == cardId }) {
                            HStack(spacing: 14) {
                                Button { toggle(cardId) } label: {
                                    Image(systemName: hidden.contains(cardId) ? "eye.slash" : "eye")
                                        .font(.system(size: 17))
                                        .foregroundColor(hidden.contains(cardId) ? AppColor.textTertiary : AppColor.primary)
                                        .frame(width: 28, height: 28)
                                }
                                .buttonStyle(.plain)

                                Text(card.emoji).font(.system(size: 20))

                                Text(card.name)
                                    .font(.system(size: 15))
                                    .foregroundColor(hidden.contains(cardId) ? AppColor.textTertiary : AppColor.textPrimary)

                                Spacer()

                                if card.locked {
                                    Text("🔒").font(.system(size: 13))
                                }
                            }
                        }
                    }
                    .onMove { from, to in order.move(fromOffsets: from, toOffset: to) }
                } header: {
                    Text("≡ で並び替え・👁 で表示/非表示を切り替え")
                        .font(.system(size: 12))
                }
            }
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        appState.growCardOrder = order
                        appState.growHiddenCards = hidden
                        dismiss()
                    }
                    .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .principal) {
                    Text("レイアウトを編集")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { dismiss() }
                }
            }
            .onAppear {
                order = appState.growCardOrder
                hidden = appState.growHiddenCards
            }
        }
    }

    private func toggle(_ id: String) {
        if hidden.contains(id) { hidden.remove(id) } else { hidden.insert(id) }
    }
}

// MARK: - 節約裏ワザ集シート
struct ProtectSecretSheet: View {
    @Environment(\.dismiss) private var dismiss

    private struct SecretTip: Identifiable {
        let id = UUID(); let emoji: String; let title: String; let detail: String
    }
    private let tips: [SecretTip] = [
        .init(emoji: "🎁", title: "誕生日クーポン収集術", detail: "スタバ・スシロー・ガスト等、誕生日月に無料クーポンを発行するチェーンは50社超。今すぐ会員登録しておくと誕生日月に数千円お得に。"),
        .init(emoji: "💊", title: "ジェネリック切替で薬代を半分に", detail: "先発薬からジェネリック（後発薬）に切り替えると薬代が最大50〜80%削減。次の受診時に「ジェネリックにしてください」と一言伝えるだけ。"),
        .init(emoji: "📱", title: "格安SIM乗り換えで月5,000円削減", detail: "大手キャリアから格安SIMへの乗り換えで月5,000〜8,000円の節約が可能。乗り換え時の違約金ゼロ化・端末補助制度も活用できる。"),
        .init(emoji: "🛒", title: "値引きシール時間を狙え", detail: "スーパーの値引きシールは閉店2〜3時間前が狙い目。惣菜・肉・魚が20〜50%引きに。冷凍可能なものをまとめ買いすると月3,000円以上の節約に。"),
        .init(emoji: "🏦", title: "預金先の金利を比較する", detail: "都市銀行の普通預金金利0.001%に対し、ネット銀行は最大0.3%以上。100万円預けると年間差額3,000円。定期預金ならさらに高金利も。"),
        .init(emoji: "🔄", title: "自動引き落とし先を見直す", detail: "クレジットカードを1枚に集約しポイント還元率を最大化。年会費無料で還元率1.5〜2%のカードに乗り換えると月の支出5万円なら年間9,000〜12,000円のポイント獲得。"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        HStack(spacing: 12) {
                            Text("🔑").font(.system(size: 36))
                            VStack(alignment: .leading, spacing: 3) {
                                Text("7日ログインで解放された！").font(.system(size: 13, weight: .bold)).foregroundColor(Color(red: 0.7, green: 0.4, blue: 0.0))
                                Text("知らないと損する節約裏ワザを紹介します").font(.system(size: 11)).foregroundColor(AppColor.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(LinearGradient(colors: [Color(red: 1.0, green: 0.95, blue: 0.75), Color(red: 1.0, green: 0.88, blue: 0.55)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(16)

                        ForEach(tips) { tip in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    Text(tip.emoji).font(.system(size: 28))
                                    Text(tip.title).font(.system(size: 15, weight: .bold)).foregroundColor(AppColor.textPrimary)
                                    Spacer()
                                }
                                Text(tip.detail).font(.system(size: 13)).foregroundColor(AppColor.textSecondary).lineSpacing(3)
                            }
                            .padding(14).background(AppColor.cardBackground).cornerRadius(14)
                            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
                        }
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16).padding(.top, 8)
                }
            }
            .navigationTitle("節約裏ワザ集").navigationBarTitleDisplayMode(.large)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("閉じる") { dismiss() } } }
        }
    }
}

// MARK: - マネーマスター術シート
struct GrowMasterSheet: View {
    @Environment(\.dismiss) private var dismiss

    private struct MasterTip: Identifiable {
        let id = UUID(); let emoji: String; let title: String; let detail: String; let tag: String
    }
    private let tips: [MasterTip] = [
        .init(emoji: "📊", title: "コア・サテライト戦略", detail: "資産の70〜80%を低コストインデックスファンド（コア）に、残り20〜30%を個別株や高リターン狙いの商品（サテライト）に配分。リスク分散しながら超過リターンを狙う上級者向け手法。", tag: "投資"),
        .init(emoji: "🏢", title: "不動産クラウドファンディング", detail: "1万円から不動産投資に参加できる仕組み。COZUCHI・Rimpleなど複数サービスがあり、年利3〜8%の配当を受け取れる。現物不動産と異なり管理不要。", tag: "不動産"),
        .init(emoji: "💹", title: "ドルコスト平均法の複利効果", detail: "毎月一定額を投資するだけで、高値掴みリスクを自動分散。20年間で元本500万円→試算1,200万円超（年率5%複利）。時間が最大の武器。", tag: "長期投資"),
        .init(emoji: "🌏", title: "外貨建て資産でリスクヘッジ", detail: "円だけで資産を持つと円安時に実質資産が目減りする。全世界株式インデックスや米国債ETFを組み合わせることで為替リスクを分散。資産の20〜30%を外貨建てに。", tag: "為替"),
        .init(emoji: "🎯", title: "副業×節税のダブル効果", detail: "副業収入が年20万円超で確定申告が必要になるが、同時に経費（通信費・書籍代・PC代等）を計上できる。青色申告承認申請書を提出すれば最大65万円の特別控除も。", tag: "節税"),
        .init(emoji: "🔮", title: "iDeCo+NISAの最適組み合わせ", detail: "iDeCoで老後資金（掛金全額所得控除）＋NISAで中期資産形成（運用益非課税）の二刀流が最強。会社員なら毎月iDeCo2.3万円+NISA積立3万円で年間控除・非課税効果は30万円超。", tag: "制度活用"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        HStack(spacing: 12) {
                            Text("👑").font(.system(size: 36))
                            VStack(alignment: .leading, spacing: 3) {
                                Text("7日ログインで解放された！").font(.system(size: 13, weight: .bold)).foregroundColor(Color(red: 0.45, green: 0.20, blue: 0.80))
                                Text("上級者向けのお金の増やし方を紹介します").font(.system(size: 11)).foregroundColor(AppColor.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(LinearGradient(colors: [Color(red: 0.94, green: 0.88, blue: 1.0), Color(red: 0.85, green: 0.75, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(16)

                        ForEach(tips) { tip in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    Text(tip.emoji).font(.system(size: 28))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(tip.title).font(.system(size: 15, weight: .bold)).foregroundColor(AppColor.textPrimary)
                                        Text(tip.tag).font(.system(size: 10, weight: .medium)).foregroundColor(Color(red: 0.55, green: 0.30, blue: 0.90))
                                            .padding(.horizontal, 7).padding(.vertical, 2)
                                            .background(Color(red: 0.55, green: 0.30, blue: 0.90).opacity(0.10)).cornerRadius(6)
                                    }
                                    Spacer()
                                }
                                Text(tip.detail).font(.system(size: 13)).foregroundColor(AppColor.textSecondary).lineSpacing(3)
                            }
                            .padding(14).background(AppColor.cardBackground).cornerRadius(14)
                            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
                        }
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16).padding(.top, 8)
                }
            }
            .navigationTitle("マネーマスター術").navigationBarTitleDisplayMode(.large)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("閉じる") { dismiss() } } }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
