import SwiftUI

// MARK: - ホーム画面
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPaymentDetail = false
    @State private var showTaskDetail    = false
    @State private var showBudgetBreakdown = false
    @State private var showPaydaySettings  = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // 大見出し
                    HStack {
                        Text("ホーム")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
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

                    // みんなの行動（コミュニティフィード）
                    CommunityFeedSection()

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .sheet(isPresented: $showPaymentDetail)    { PaymentDetailView() }
        .sheet(isPresented: $showTaskDetail)       { TodayTaskDetailView() }
        .sheet(isPresented: $showBudgetBreakdown)  {
            BudgetBreakdownSheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showPaydaySettings) {
            PaydaySettingsSheet()
                .environmentObject(appState)
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
                    value: "\(appState.daysToPayday)日",
                    color: appState.daysToPayday <= 5 ? AppColor.caution : AppColor.textPrimary
                )
            }
            .buttonStyle(.plain)
            QuickStatCard(
                emoji: "🐷",
                label: "1日の目安",
                value: appState.dailyBudget.yen,
                color: appState.dailyBudget <= 0 ? AppColor.danger : AppColor.secondary
            )
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
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 10))
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

                VStack(alignment: .leading, spacing: 8) {
                    // 名前 + レベルバッジ
                    HStack(spacing: 8) {
                        Text("やりくりん")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Text("Lv.\(level)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppColor.primary)
                            .cornerRadius(10)
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
                        // 今月の予算入力
                        VStack(alignment: .leading, spacing: 8) {
                            Text("今月の予算")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)
                            HStack {
                                Text("¥")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppColor.textPrimary)
                                TextField("手取り金額", text: $budgetText)
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
                            Text("入れなければ、お給料の金額を使います")
                                .font(.system(size: 11))
                                .foregroundColor(AppColor.textTertiary)
                        }
                        .cardStyle()

                        // 計算式内訳
                        VStack(alignment: .leading, spacing: 14) {
                            Text("💡 どうやって計算するの？")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)

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
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        appState.customMonthlyBudget = Int(budgetText)
                        dismiss()
                    }
                    .foregroundColor(AppColor.primary)
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
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        appState.userProfile?.paydayDay = selectedDay
                        dismiss()
                    }
                    .foregroundColor(AppColor.primary)
                }
            }
            .onAppear {
                selectedDay = appState.userProfile?.paydayDay ?? 25
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
