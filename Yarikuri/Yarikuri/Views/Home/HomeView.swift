import SwiftUI

// MARK: - ホーム画面
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPaymentDetail = false
    @State private var showTaskDetail    = false
    @State private var showBudgetBreakdown = false
    @State private var showPaydaySettings  = false
    @State private var showDailyBudgetDetail = false
    @State private var showSettings = false
    @State private var showLoginCalendar = false
    @State private var selectedCommunityTab: FeedTab = .recommend
    @State private var activeCommunitySheet: CommunityActiveSheet? = nil
    @State private var showCommunityTimeline = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // 大見出し
                    HStack {
                        Text("ホーム")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
                        // 連続ログイン日数（タップでカレンダー表示）
                        Button(action: { showLoginCalendar = true }) {
                            HStack(spacing: 3) {
                                Text("🔥")
                                    .font(.system(size: 14))
                                Text("\(appState.consecutiveLoginDays)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.12))
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 22))
                                .foregroundColor(AppColor.textSecondary)
                        }
                        .padding(.leading, 6)
                    }
                    .padding(.top, 8)

                    // やりくりん
                    MascotCard()

                    // 残予算・給料日まで・1日の目安
                    quickStatsRow

                    // 今日やること
                    TodayTaskCard(onTap: { showTaskDetail = true })

                    // 次の支払い
                    NextPaymentsCard(onDetailTap: { showPaymentDetail = true })

                    // みんなの行動
                    communitySection

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .sheet(isPresented: $showCommunityTimeline) { CommunityTimelineSheet(initialTab: selectedCommunityTab).environmentObject(appState) }
        .sheet(isPresented: $showLoginCalendar)    { LoginCalendarView().environmentObject(appState) }
        .sheet(isPresented: $showPaymentDetail)    { UpcomingPaymentsListView().environmentObject(appState) }
        .sheet(isPresented: $showTaskDetail)       { TodayTaskDetailView() }
        .sheet(isPresented: $showBudgetBreakdown)  {
            BudgetBreakdownSheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showPaydaySettings) {
            PaydaySettingsSheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showDailyBudgetDetail) {
            DailyBudgetDetailSheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showSettings) {
            MyPageView()
                .environmentObject(appState)
        }
        .sheet(item: $activeCommunitySheet) { sheet in
            switch sheet {
            case .comment(let post):
                CommentSheet(post: post).environmentObject(appState)
            case .compose:
                PostComposerSheet().environmentObject(appState)
            }
        }
    }

    // MARK: - みんなの行動セクション
    private var communitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("みんなの行動")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                Button(action: { activeCommunitySheet = .compose }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18))
                        .foregroundColor(AppColor.primary)
                }
            }

            FeedTabBar(selected: $selectedCommunityTab)

            let allPosts: [CommunityPost] = {
                switch selectedCommunityTab {
                case .recommend: return appState.recommendedPosts
                case .following: return appState.followingPosts
                case .mine:      return appState.myPosts
                }
            }()
            let posts = Array(allPosts.prefix(5))

            if posts.isEmpty {
                VStack(spacing: 10) {
                    Text(selectedCommunityTab == .following ? "👤" : "📭")
                        .font(.system(size: 36))
                    Text(selectedCommunityTab == .following
                         ? "まだフォロー中のユーザーがいません"
                         : "投稿がありません")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(AppColor.cardBackground)
                .cornerRadius(16)
                .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
            } else {
                ForEach(posts) { post in
                    CommunityPostCard(post: post,
                                     onCommentTap: { activeCommunitySheet = .comment(post) })
                }

                // 詳細を見るボタン
                Button(action: { showCommunityTimeline = true }) {
                    HStack {
                        Text("詳細を見る")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColor.primary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColor.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColor.primaryLight)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - クイック数字 3列
    private var quickStatsRow: some View {
        HStack(spacing: 10) {
            Button(action: { showBudgetBreakdown = true }) {
                QuickStatCard(
                    emoji: "💰",
                    label: "残予算",
                    value: appState.remainingBudget.yen,
                    color: Color.safetyColor(ratio: appState.safetyRatio)
                )
            }
            .buttonStyle(.plain)
            Button(action: { showPaydaySettings = true }) {
                QuickStatCard(
                    emoji: "📅",
                    label: "給料日まで",
                    value: "あと\(appState.daysToPayday)日",
                    color: appState.daysToPayday <= 5 ? AppColor.caution : AppColor.textPrimary
                )
            }
            .buttonStyle(.plain)
            Button(action: { showDailyBudgetDetail = true }) {
                QuickStatCard(
                    emoji: "🐷",
                    label: "1日の目安",
                    value: appState.dailyBudget.yen,
                    color: appState.dailyBudget <= 0 ? AppColor.danger : AppColor.secondary
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - クイック数字カード
private struct QuickStatCard: View {
    let emoji: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(emoji).font(.system(size: 28))
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
    }
}

// MARK: - コロン（育てるキャラクター）
struct MascotCard: View {
    @EnvironmentObject var appState: AppState
    @State private var glowPulse = false
    @State private var tapBounce: CGFloat = 0
    @State private var showLevelSheet = false

    private var completedCount: Int { appState.completedTaskIds.count }

    private var level: Int {
        switch completedCount {
        case 0..<3:   return 1
        case 3..<7:   return 2
        case 7..<13:  return 3
        case 13..<21: return 4
        default:      return 5
        }
    }

    private var nextLevelAt: Int {
        switch level {
        case 1: return 3
        case 2: return 7
        case 3: return 13
        case 4: return 21
        default: return 21
        }
    }

    private var prevLevelAt: Int {
        switch level {
        case 1: return 0
        case 2: return 3
        case 3: return 7
        case 4: return 13
        default: return 21
        }
    }

    private var coronEmotion: CoronEmotion {
        switch level {
        case 5: return .celebrate
        case 4: return .happy
        default: return .normal
        }
    }

    private var progressRatio: Double {
        guard level < 5 else { return 1.0 }
        let span = Double(nextLevelAt - prevLevelAt)
        let progress = Double(completedCount - prevLevelAt)
        return min(1.0, max(0.0, progress / span))
    }

    var body: some View {
        ZStack {
            // 背景グラデーション
            RoundedRectangle(cornerRadius: 22)
                .fill(LinearGradient(
                    colors: [AppColor.primaryLight, AppColor.accentLight],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))

            // 光彩
            Circle()
                .fill(AppColor.primary.opacity(0.12))
                .frame(width: 100, height: 100)
                .scaleEffect(glowPulse ? 1.3 : 0.85)
                .blur(radius: 18)

            HStack(spacing: 12) {
                // コロンキャラクター
                CoronView(size: 72, emotion: coronEmotion, animate: true, level: level)
                    .frame(width: 108, height: 100)
                    .offset(y: tapBounce)
                    .onTapGesture {
                        tapBounce = 0
                        withAnimation(.spring(response: 0.18, dampingFraction: 0.4)) {
                            tapBounce = -22
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.45)) {
                                tapBounce = 0
                            }
                        }
                    }

                VStack(alignment: .leading, spacing: 8) {
                    // 名前 + レベルバッジ
                    HStack(spacing: 8) {
                        Text("やりくりん")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Button(action: { showLevelSheet = true }) {
                            Text("Lv.\(level)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppColor.primary)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }

                    // プログレスバー
                    if level < 5 {
                        VStack(alignment: .leading, spacing: 4) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppColor.primary.opacity(0.15))
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [AppColor.primary, AppColor.accent],
                                                startPoint: .leading, endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * progressRatio, height: 8)
                                        .animation(.spring(response: 0.6), value: progressRatio)
                                }
                            }
                            .frame(height: 8)
                            Text("次まであと \(max(0, nextLevelAt - completedCount)) タスク")
                                .font(.system(size: 11))
                                .foregroundColor(AppColor.textSecondary)
                        }
                    } else {
                        Text("🏆 やりくりマスター！")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColor.primary)
                    }

                    // やりくりんのひとこと（関係性ステージ・連続日数で変化）
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 9))
                            .foregroundColor(AppColor.primary.opacity(0.6))
                        Text(appState.mascotComment)
                            .font(.system(size: 11))
                            .foregroundColor(AppColor.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                    // 夢タグ（設定済みの場合のみ表示）
                    if let profile = appState.userProfile, !profile.dreamText.isEmpty {
                        HStack(spacing: 3) {
                            Text(profile.dreamEmoji)
                                .font(.system(size: 10))
                            Text(profile.dreamText)
                                .font(.system(size: 10))
                                .foregroundColor(AppColor.textSecondary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(AppColor.accentLight)
                        .cornerRadius(6)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .frame(height: 145)
        .shadow(color: AppColor.shadowColor, radius: 6, x: 0, y: 3)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { glowPulse = true }
        }
        .sheet(isPresented: $showLevelSheet) {
            YarikurinLevelSheet(currentLevel: level)
        }
    }
}

// MARK: - 連続ログインストリークバナー
struct LoginStreakBanner: View {
    @EnvironmentObject var appState: AppState
    @State private var flamePulse = false

    private var days: Int { appState.consecutiveLoginDays }

    // マイルストーン: 3, 7, 14, 30日
    private let milestones = [3, 7, 14, 30]

    private var nextMilestone: Int? {
        milestones.first { $0 > days }
    }

    private var daysToNext: Int? {
        nextMilestone.map { $0 - days }
    }

    var body: some View {
        HStack(spacing: 16) {
            // 炎アイコン + 日数
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.25), Color.red.opacity(0.12)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .scaleEffect(flamePulse ? 1.08 : 0.95)
                VStack(spacing: 0) {
                    Text("🔥")
                        .font(.system(size: 26))
                    Text("\(days)")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.orange)
                }
            }

            // テキスト情報
            VStack(alignment: .leading, spacing: 4) {
                Text("連続\(days)日ログイン中！")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color.orange)

                if let remaining = daysToNext, let next = nextMilestone {
                    Text("次の目標（\(next)日）まであと\(remaining)日")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                } else {
                    Text("すごい！30日以上継続中りん🎉")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                }

                // マイルストーンドット
                HStack(spacing: 6) {
                    ForEach(milestones, id: \.self) { m in
                        Circle()
                            .fill(days >= m ? Color.orange : AppColor.primary.opacity(0.15))
                            .frame(width: 8, height: 8)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.12), Color.yellow.opacity(0.07)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.orange.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.orange.opacity(0.12), radius: 6, x: 0, y: 2)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                flamePulse = true
            }
        }
    }
}

// MARK: - 残予算内訳シート
struct BudgetBreakdownSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var budgetText: String = ""
    @FocusState private var focused: Bool

    private var displayBudget: Int {
        Int(budgetText) ?? appState.customMonthlyBudget ?? appState.monthlyIncome
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // 今月の収入(参考)と今月の予算の入力
                        VStack(alignment: .leading, spacing: 12) {
                            // 先月の収入(参考)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("先月の収入(参考)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppColor.textSecondary)
                                HStack {
                                    Text("¥")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppColor.textTertiary)
                                    Text("\(appState.monthlyIncome)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(AppColor.textSecondary)
                                    Spacer()
                                    Text("お給料(参考)")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppColor.textTertiary)
                                }
                                .padding(12)
                                .background(AppColor.sectionBackground)
                                .cornerRadius(12)
                            }

                            // 今月の予算(計算に使う)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("今月の予算")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppColor.textSecondary)
                                HStack {
                                    Text("¥")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppColor.textPrimary)
                                    TextField("予算を入力", text: $budgetText)
                                        .focused($focused)
                                        .keyboardType(.numberPad)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(AppColor.textPrimary)
                                }
                                .padding(14)
                                .background(AppColor.cardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focused ? AppColor.primary : Color.clear, lineWidth: 1.5)
                                )
                                Text("残りのお金はここから計算されます")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColor.textTertiary)
                            }
                        }
                        .cardStyle()

                        // 計算式内訳
                        VStack(alignment: .center, spacing: 14) {
                            Text("💡 どうやって計算するの？")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)

                            BreakdownRow(label: "📊 先月の収入(参考)", value: appState.monthlyIncome, color: AppColor.textSecondary, prefix: "")
                            BreakdownRow(label: "💰 今月の予算", value: displayBudget, color: AppColor.textPrimary, prefix: "")
                            BreakdownRow(label: "📋 毎月の固定費", value: appState.totalFixedExpenses, color: AppColor.caution, prefix: "−")
                            BreakdownRow(label: "📅 今月の支払い", value: appState.totalScheduledPayments, color: AppColor.caution, prefix: "−")
                            BreakdownRow(label: "💸 借金の返済", value: appState.totalMonthlyDebtPayments, color: AppColor.danger, prefix: "−")

                            Divider()

                            let result = displayBudget - appState.totalFixedExpenses - appState.totalScheduledPayments - appState.totalMonthlyDebtPayments
                            HStack {
                                Text("🐷 残りのお金")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppColor.textPrimary)
                                Spacer()
                                Text(max(0, result).yen)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(result >= 0 ? AppColor.primary : AppColor.danger)
                            }
                        }
                        .cardStyle()

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("残予算の計算方法")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        appState.customMonthlyBudget = Int(budgetText)
                        dismiss()
                    }
                    .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
        .onAppear {
            if let custom = appState.customMonthlyBudget {
                budgetText = "\(custom)"
            }
        }
    }
}

private struct BreakdownRow: View {
    let label: String
    let value: Int
    let color: Color
    let prefix: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(AppColor.textSecondary)
            Spacer()
            Text("\(prefix)\(value.yen)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// MARK: - 給料日設定シート
struct PaydaySettingsSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedDay: Int = 25

    var body: some View {
        NavigationStack {
            Form {
                Section("給料日") {
                    Stepper("毎月 \(selectedDay) 日", value: $selectedDay, in: 1...31)
                }
            }
            .navigationTitle("給料日の設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        appState.userProfile?.paydayDay = selectedDay
                        dismiss()
                    }
                    .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { dismiss() }
                }
            }
            .onAppear {
                selectedDay = appState.userProfile?.paydayDay ?? 25
            }
        }
    }
}

// MARK: - 1日の目安 計算詳細シート
struct DailyBudgetDetailSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // 残予算の内訳
                        VStack(alignment: .leading, spacing: 14) {
                            Text("📋 残予算の計算内訳")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)

                            let budget = appState.customMonthlyBudget ?? appState.monthlyIncome
                            BreakdownRow(label: "💰 今月の予算", value: budget, color: AppColor.textPrimary, prefix: "")
                            BreakdownRow(label: "📋 毎月の固定費", value: appState.totalFixedExpenses, color: AppColor.caution, prefix: "−")
                            BreakdownRow(label: "📅 今月の支払い", value: appState.totalScheduledPayments, color: AppColor.caution, prefix: "−")
                            BreakdownRow(label: "💸 借金の返済", value: appState.totalMonthlyDebtPayments, color: AppColor.danger, prefix: "−")

                            Divider()

                            HStack {
                                Text("🐷 残予算")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppColor.textPrimary)
                                Spacer()
                                Text(appState.remainingBudget.yen)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color.safetyColor(ratio: appState.safetyRatio))
                            }
                        }
                        .cardStyle()

                        // 1日の目安の計算
                        VStack(alignment: .leading, spacing: 14) {
                            Text("💡 どうやって計算するの？")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)

                            BreakdownRow(label: "🐷 残予算", value: appState.remainingBudget, color: AppColor.textPrimary, prefix: "")

                            HStack {
                                Text("📅 給料日まで")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColor.textSecondary)
                                Spacer()
                                Text("÷ \(appState.daysToPayday)日")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColor.textPrimary)
                            }

                            Divider()

                            HStack {
                                Text("🐷 1日の目安")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppColor.textPrimary)
                                Spacer()
                                Text(appState.dailyBudget.yen)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(appState.dailyBudget <= 0 ? AppColor.danger : AppColor.secondary)
                            }
                        }
                        .cardStyle()

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("1日の目安の計算方法")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }
}

// MARK: - 今日のおすすめカード（シンプル版）
struct TodayRecommendationCard: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        let rec = appState.todayRecommendation
        HStack(spacing: 14) {
            Text(rec.emoji).font(.system(size: 36))
            Text(rec.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColor.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColor.textTertiary)
        }
        .padding(14)
        .background(AppColor.accentLight)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
    }
}

// MARK: - やりくりんレベル一覧シート
private struct YarikurinLevelSheet: View {
    @Environment(\.dismiss) private var dismiss
    let currentLevel: Int

    private let levels: [(Int, String, String)] = [
        (1, "たまご期", "0〜2タスク達成"),
        (2, "めばえ期", "3〜6タスク達成"),
        (3, "せいちょう期", "7〜12タスク達成"),
        (4, "かがやき期", "13〜20タスク達成"),
        (5, "マスター期", "21タスク以上達成"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Text("タスクをこなしてやりくりんを育てよう！")
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)

                        ForEach(levels, id: \.0) { (lv, name, requirement) in
                            levelCard(lv: lv, name: name, requirement: requirement)
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("やりくりんの成長")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }

    @ViewBuilder
    private func levelCard(lv: Int, name: String, requirement: String) -> some View {
        let isAchieved = lv <= currentLevel
        let isCurrent  = lv == currentLevel

        HStack(spacing: 16) {
            ZStack {
                if isAchieved {
                    CoronView(size: 60, emotion: lv == 5 ? .celebrate : lv == 4 ? .happy : .normal,
                              animate: false, level: lv)
                        .frame(width: 72, height: 68)
                } else {
                    // シルエット表示
                    CoronView(size: 60, emotion: .normal, animate: false, level: lv)
                        .frame(width: 72, height: 68)
                        .grayscale(1.0)
                        .opacity(0.35)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColor.textTertiary)
                        .offset(y: 20)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text("Lv.\(lv)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(isAchieved ? AppColor.primary : AppColor.textTertiary)
                        .cornerRadius(8)
                    Text(name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isAchieved ? AppColor.textPrimary : AppColor.textTertiary)
                    if isCurrent {
                        Text("NOW")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppColor.primary)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(AppColor.primaryLight)
                            .cornerRadius(4)
                    }
                }
                Text(requirement)
                    .font(.system(size: 12))
                    .foregroundColor(isAchieved ? AppColor.textSecondary : AppColor.textTertiary)
            }

            Spacer()

            if isAchieved {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppColor.primary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isCurrent ? AppColor.primaryLight : AppColor.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCurrent ? AppColor.primary.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject({
        let s = AppState()
        s.loadDemoData()
        return s
    }())
}
