import SwiftUI
import AVFoundation

// MARK: - メインタブビュー（スワイプ対応 + カスタムタブバー）
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { HomeView() }
                .tag(0)
            NavigationStack { ProtectScreenView() }
                .tag(1)
            NavigationStack { GrowScreenView() }
                .tag(2)
            NavigationStack { MyPageView() }
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(AppColor.background)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CustomTabBar(selectedTab: $selectedTab)
        }
        .overlay {
            if let praise = appState.currentPraise {
                YarikurinPraiseView(item: praise)
                    .transition(.opacity)
                    .id(praise.id)
            }
        }
        .animation(.none, value: appState.currentPraise)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToTab"))) { notification in
            if let tab = notification.object as? Int {
                withAnimation { selectedTab = tab }
            }
        }
        .onAppear {
            BackgroundMusicPlayer.shared.start()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            BackgroundMusicPlayer.shared.stop()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            BackgroundMusicPlayer.shared.start()
        }
    }
}

// MARK: - カスタムタブバー
private struct CustomTabBar: View {
    @Binding var selectedTab: Int

    private struct TabItemData {
        let icon: String
        let selectedIcon: String
        let label: String
    }

    private let items: [TabItemData] = [
        .init(icon: "house",                    selectedIcon: "house.fill",    label: "ホーム"),
        .init(icon: "shield",                   selectedIcon: "shield.fill",   label: "守る"),
        .init(icon: "chart.line.uptrend.xyaxis",selectedIcon: "chart.line.uptrend.xyaxis", label: "増やす"),
        .init(icon: "person",                   selectedIcon: "person.fill",   label: "マイページ"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                let isSelected = selectedTab == index
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index } }) {
                    VStack(spacing: 3) {
                        Image(systemName: isSelected ? item.selectedIcon : item.icon)
                            .font(.system(size: 21))
                            .foregroundColor(isSelected ? AppColor.primary : .black.opacity(0.45))
                        Text(item.label)
                            .font(.system(size: 10))
                            .foregroundColor(isSelected ? AppColor.primary : .black.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(
            Color.white
                .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray.opacity(0.2)),
            alignment: .top
        )
    }
}

// MARK: - 守る画面
struct ProtectScreenView: View {
    @EnvironmentObject var appState: AppState
    @State private var showReport        = false
    @State private var showFixedExpense  = false
    @State private var showDebtNavi      = false
    @State private var showSupport       = false
    @State private var showHowTo         = false
    @State private var showSecret        = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    HStack {
                        Text("守る")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
                        Button(action: { showReport = true }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppColor.primary)
                        }
                    }
                    .padding(.top, 8)

                    ProtectSummaryCard()
                    ProtectAnimationView()

                    // アイコングリッド（2 × 2 + ロックカード）
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ProtectNavCard(
                            emoji: "📋",
                            title: "固定費・\nサブスク整理",
                            subtitle: "\(appState.fixedExpenses.count)件 / \(appState.totalFixedExpenses.yen)",
                            color: AppColor.primary,
                            action: { showFixedExpense = true }
                        )
                        ProtectNavCard(
                            emoji: "💳",
                            title: "借金返済\nナビ",
                            subtitle: appState.debts.isEmpty ? "借入なし" : "\(appState.debts.count)件の借入",
                            color: AppColor.danger,
                            action: { showDebtNavi = true }
                        )
                        ProtectNavCard(
                            emoji: "🤝",
                            title: "使える制度・\n給付・支援",
                            subtitle: "補助金・公的支援を確認",
                            color: Color(red: 0.18, green: 0.62, blue: 0.35),
                            action: { showSupport = true }
                        )
                        ProtectNavCard(
                            emoji: "🛡️",
                            title: "守り方",
                            subtitle: "節約・支出削減の知識",
                            color: AppColor.secondary,
                            action: { showHowTo = true }
                        )
                        LockedNavCard(
                            unlockedEmoji: "🔑",
                            unlockedTitle: "節約\n裏ワザ集",
                            unlockedSubtitle: "知らないと損する節約術",
                            unlockedColor: Color(red: 0.85, green: 0.55, blue: 0.10),
                            currentDays: appState.consecutiveLoginDays,
                            action: { showSecret = true }
                        )
                        .gridCellColumns(2)
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
            }
        }
        .sheet(isPresented: $showReport)       { MonthlyReportView() }
        .sheet(isPresented: $showFixedExpense) { FixedExpenseView() }
        .sheet(isPresented: $showDebtNavi)     { DebtNaviView() }
        .sheet(isPresented: $showSupport)      { SupportSystemView() }
        .sheet(isPresented: $showHowTo)        { ProtectHowToSheet() }
        .sheet(isPresented: $showSecret)       { ProtectSecretSheet() }
    }
}

// MARK: - 守るナビカード（大アイコン）
private struct ProtectNavCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Text(emoji)
                    .font(.system(size: 32))
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(AppColor.cardBackground)
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(0.25), lineWidth: 1.5))
            .shadow(color: AppColor.shadowColor, radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 守り方シート（節約・支出削減の知識カード）
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

// MARK: - 増やす画面
struct GrowScreenView: View {
    @EnvironmentObject var appState: AppState
    @State private var showReport      = false
    @State private var showFukugyou    = false
    @State private var showCareer      = false
    @State private var showSetsuzei    = false
    @State private var showNisa        = false
    @State private var showChiritsumo  = false
    @State private var showMaster      = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    HStack {
                        Text("増やす")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
                        Button(action: { showReport = true }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppColor.primary)
                        }
                    }
                    .padding(.top, 8)

                    GrowSummaryCard()
                    GrowAnimationView()

                    // カテゴリアイコングリッド（2列 + ロックカード）
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        GrowNavCard(emoji: "🎥", title: "副業で\n稼ぐ",
                                    subtitle: "YouTube・クラウド等9種",
                                    color: Color.red.opacity(0.75),
                                    action: { showFukugyou = true })
                        GrowNavCard(emoji: "🏢", title: "キャリア・\n転職",
                                    subtitle: "転職・資格・独立",
                                    color: Color.indigo.opacity(0.8),
                                    action: { showCareer = true })
                        GrowNavCard(emoji: "🏯", title: "節税",
                                    subtitle: "ふるさと納税・iDeCo等",
                                    color: Color.orange.opacity(0.85),
                                    action: { showSetsuzei = true })
                        GrowNavCard(emoji: "🌱", title: "NISA・投資",
                                    subtitle: "積立・成長投資枠等",
                                    color: Color(red: 0.18, green: 0.62, blue: 0.35),
                                    action: { showNisa = true })
                        GrowNavCard(emoji: "☕", title: "ちりつも作戦",
                                    subtitle: "ポイ活・節約習慣等",
                                    color: AppColor.secondary,
                                    action: { showChiritsumo = true })
                        LockedNavCard(
                            unlockedEmoji: "👑",
                            unlockedTitle: "マネー\nマスター術",
                            unlockedSubtitle: "上級者向けのお金の増やし方",
                            unlockedColor: Color(red: 0.55, green: 0.30, blue: 0.90),
                            currentDays: appState.consecutiveLoginDays,
                            action: { showMaster = true }
                        )
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
            }
        }
        .sheet(isPresented: $showReport)     { MonthlyReportView() }
        .sheet(isPresented: $showFukugyou)   { GrowFukugyouSheet() }
        .sheet(isPresented: $showCareer)     { GrowCareerSheet() }
        .sheet(isPresented: $showSetsuzei)   { GrowSetsuzeiSheet() }
        .sheet(isPresented: $showNisa)       { GrowNisaSheet() }
        .sheet(isPresented: $showChiritsumo) { GrowChiritsumoSheet() }
        .sheet(isPresented: $showMaster)     { GrowMasterSheet() }
    }
}

// MARK: - 増やすナビカード（大アイコン）
private struct GrowNavCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Text(emoji)
                    .font(.system(size: 32))
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
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
        HStack(spacing: 0) {
            // 今月守れたお金
            VStack(spacing: 2) {
                Text("💰").font(.system(size: 18))
                Text(appState.monthlyProtectedAmount.yen)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColor.primary)
                    .minimumScaleFactor(0.7).lineLimit(1)
                Text("今月守れたお金")
                    .font(.system(size: 9))
                    .foregroundColor(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 32)

            // 今月確認したこと
            VStack(spacing: 2) {
                Text("📚").font(.system(size: 18))
                Text("\(appState.monthlyProtectActions.count)件")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColor.secondary)
                Text("今月確認したこと")
                    .font(.system(size: 9))
                    .foregroundColor(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 32)

            // 詳細ボタン
            Button(action: { showDetail = true }) {
                VStack(spacing: 2) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppColor.primary.opacity(0.7))
                    Text("詳細")
                        .font(.system(size: 9))
                        .foregroundColor(AppColor.textSecondary)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 56)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            LinearGradient(
                colors: [Color(red: 0.93, green: 0.91, blue: 1.0), AppColor.primaryLight],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showDetail) {
            MonthlyActionsDetailSheet(
                title: "今月の守り実績",
                amountLabel: "今月守れたお金",
                amountValue: appState.monthlyProtectedAmount.yen,
                actions: appState.monthlyProtectActions
            )
        }
    }
}

// MARK: - 増やすサマリーカード
struct GrowSummaryCard: View {
    @EnvironmentObject var appState: AppState
    @State private var showDetail = false

    private var grownValueText: String {
        appState.monthlyGrownAmount > 0 ? "+\(appState.monthlyGrownAmount.yen)" : "+¥0"
    }

    var body: some View {
        HStack(spacing: 0) {
            // 今月増やせたお金
            VStack(spacing: 2) {
                Text("💹").font(.system(size: 18))
                Text(grownValueText)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                    .minimumScaleFactor(0.7).lineLimit(1)
                Text("今月増やせたお金")
                    .font(.system(size: 9))
                    .foregroundColor(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 32)

            // 今月学んだこと
            VStack(spacing: 2) {
                Text("📚").font(.system(size: 18))
                Text("\(appState.monthlyGrowActions.count)件")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColor.primary)
                Text("今月学んだこと")
                    .font(.system(size: 9))
                    .foregroundColor(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 32)

            // 詳細ボタン
            Button(action: { showDetail = true }) {
                VStack(spacing: 2) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.18, green: 0.62, blue: 0.35).opacity(0.7))
                    Text("詳細")
                        .font(.system(size: 9))
                        .foregroundColor(AppColor.textSecondary)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 56)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            LinearGradient(
                colors: [Color(red: 0.90, green: 0.98, blue: 0.91), Color(red: 0.99, green: 0.98, blue: 0.85)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showDetail) {
            MonthlyActionsDetailSheet(
                title: "今月の増やし実績",
                amountLabel: "今月増やせたお金",
                amountValue: grownValueText,
                actions: appState.monthlyGrowActions
            )
        }
    }
}

// MARK: - 月間アクション詳細シート
struct MonthlyActionsDetailSheet: View {
    let title: String
    let amountLabel: String
    let amountValue: String
    let actions: [CardAction]

    @Environment(\.dismiss) private var dismiss

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "M/d HH:mm"
        return f
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                if actions.isEmpty {
                    VStack(spacing: 16) {
                        Text("📋")
                            .font(.system(size: 56))
                        Text("まだ記録がありません")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColor.textSecondary)
                        Text("カードをタップすると\n行動が記録されます")
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            // 金額サマリー
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(amountLabel)
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColor.textSecondary)
                                    Text(amountValue)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(AppColor.primary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("行動数")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColor.textSecondary)
                                    Text("\(actions.count)件")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(AppColor.secondary)
                                }
                            }
                            .padding(16)
                            .background(AppColor.cardBackground)
                            .cornerRadius(16)
                            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)

                            // 行動リスト
                            VStack(spacing: 0) {
                                ForEach(Array(actions.reversed().enumerated()), id: \.element.id) { idx, action in
                                    HStack(spacing: 12) {
                                        Text(action.emoji)
                                            .font(.system(size: 26))
                                            .frame(width: 36)
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(action.title)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(AppColor.textPrimary)
                                            Text(dateFormatter.string(from: action.date))
                                                .font(.system(size: 11))
                                                .foregroundColor(AppColor.textTertiary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 11)
                                    if idx < actions.count - 1 {
                                        Divider().padding(.leading, 64)
                                    }
                                }
                            }
                            .background(AppColor.cardBackground)
                            .cornerRadius(16)
                            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)

                            Spacer().frame(height: 20)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
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
                    // 解放済みレイアウト
                    VStack(spacing: 7) {
                        Text(unlockedEmoji)
                            .font(.system(size: 32))
                        Text(unlockedTitle)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        Text(unlockedSubtitle)
                            .font(.system(size: 10))
                            .foregroundColor(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 8)
                    .background(
                        LinearGradient(
                            colors: [unlockedColor.opacity(0.12), unlockedColor.opacity(0.05)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(unlockedColor.opacity(0.4), lineWidth: 2))
                    .shadow(color: unlockedColor.opacity(0.15), radius: 8, x: 0, y: 3)
                } else {
                    // ロック中レイアウト
                    VStack(spacing: 8) {
                        ZStack {
                            // ✨ 浮遊パーティクル
                            ForEach(0..<5, id: \.self) { i in
                                Text("✨")
                                    .font(.system(size: 11))
                                    .offset(
                                        x: CGFloat([-28, 28, -18, 22, 0][i]),
                                        y: CGFloat([-22, -18, 16, 14, -30][i])
                                    )
                                    .scaleEffect(sparkleScale)
                                    .opacity(sparkleOpacity * [0.9, 0.7, 1.0, 0.8, 0.6][i])
                                    .animation(
                                        .easeInOut(duration: 1.2 + Double(i) * 0.3)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(i) * 0.25),
                                        value: sparkleScale
                                    )
                            }
                            // ❓ アイコン（脈動）
                            Text("❓")
                                .font(.system(size: 32))
                                .scaleEffect(sparkleScale * 0.95 + 0.05)
                                .animation(
                                    .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                                    value: sparkleScale
                                )
                        }
                        .frame(height: 56)

                        Text("7日連続ログインで解放")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.0))

                        // 進捗バー
                        VStack(spacing: 4) {
                            HStack {
                                Text("現在 \(currentDays)日")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("目標 7日")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.gray.opacity(0.2)).frame(height: 6)
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.yellow, Color.orange],
                                                startPoint: .leading, endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * min(CGFloat(currentDays) / 7.0, 1.0), height: 6)
                                        // シマーオーバーレイ
                                        .overlay(
                                            GeometryReader { bar in
                                                Rectangle()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [.clear, .white.opacity(0.6), .clear],
                                                            startPoint: .leading, endPoint: .trailing
                                                        )
                                                    )
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
                    .padding(.vertical, 20)
                    .padding(.horizontal, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.97, blue: 0.82), Color(red: 1.0, green: 0.93, blue: 0.70)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.yellow.opacity(0.7), Color.orange.opacity(0.5)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.orange.opacity(0.15), radius: 6, x: 0, y: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            guard !isUnlocked else { return }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                sparkleScale = 1.08
                sparkleOpacity = 1.0
            }
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.5
            }
        }
    }
}

// MARK: - 節約裏ワザ集シート（守る・7日解放）
struct ProtectSecretSheet: View {
    @Environment(\.dismiss) private var dismiss

    private struct SecretTip: Identifiable {
        let id = UUID()
        let emoji: String
        let title: String
        let detail: String
    }

    private let tips: [SecretTip] = [
        .init(emoji: "🎁", title: "誕生日クーポン収集術",
              detail: "スタバ・スシロー・ガスト等、誕生日月に無料クーポンを発行するチェーンは50社超。今すぐ会員登録しておくと誕生日月に数千円お得に。"),
        .init(emoji: "💊", title: "ジェネリック切替で薬代を半分に",
              detail: "先発薬からジェネリック（後発薬）に切り替えると薬代が最大50〜80%削減。次の受診時に「ジェネリックにしてください」と一言伝えるだけ。"),
        .init(emoji: "📱", title: "格安SIM乗り換えで月5,000円削減",
              detail: "大手キャリアから格安SIMへの乗り換えで月5,000〜8,000円の節約が可能。乗り換え時の違約金ゼロ化・端末補助制度も活用できる。"),
        .init(emoji: "🛒", title: "値引きシール時間を狙え",
              detail: "スーパーの値引きシールは閉店2〜3時間前が狙い目。惣菜・肉・魚が20〜50%引きに。冷凍可能なものをまとめ買いすると月3,000円以上の節約に。"),
        .init(emoji: "🏦", title: "預金先の金利を比較する",
              detail: "都市銀行の普通預金金利0.001%に対し、ネット銀行は最大0.3%以上。100万円預けると年間差額3,000円。定期預金ならさらに高金利も。"),
        .init(emoji: "🔄", title: "自動引き落とし先を見直す",
              detail: "クレジットカードを1枚に集約しポイント還元率を最大化。年会費無料で還元率1.5〜2%のカードに乗り換えると月の支出5万円なら年間9,000〜12,000円のポイント獲得。"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        // ヘッダーバナー
                        HStack(spacing: 12) {
                            Text("🔑")
                                .font(.system(size: 36))
                            VStack(alignment: .leading, spacing: 3) {
                                Text("7日ログインで解放された！")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(red: 0.7, green: 0.4, blue: 0.0))
                                Text("知らないと損する節約裏ワザを紹介します")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColor.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.95, blue: 0.75), Color(red: 1.0, green: 0.88, blue: 0.55)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)

                        ForEach(tips) { tip in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    Text(tip.emoji)
                                        .font(.system(size: 28))
                                    Text(tip.title)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(AppColor.textPrimary)
                                    Spacer()
                                }
                                Text(tip.detail)
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColor.textSecondary)
                                    .lineSpacing(3)
                            }
                            .padding(14)
                            .background(AppColor.cardBackground)
                            .cornerRadius(14)
                            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("節約裏ワザ集")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

// MARK: - マネーマスター術シート（増やす・7日解放）
struct GrowMasterSheet: View {
    @Environment(\.dismiss) private var dismiss

    private struct MasterTip: Identifiable {
        let id = UUID()
        let emoji: String
        let title: String
        let detail: String
        let tag: String
    }

    private let tips: [MasterTip] = [
        .init(emoji: "📊", title: "コア・サテライト戦略",
              detail: "資産の70〜80%を低コストインデックスファンド（コア）に、残り20〜30%を個別株や高リターン狙いの商品（サテライト）に配分。リスク分散しながら超過リターンを狙う上級者向け手法。",
              tag: "投資"),
        .init(emoji: "🏢", title: "不動産クラウドファンディング",
              detail: "1万円から不動産投資に参加できる仕組み。COZUCHI・Rimpleなど複数サービスがあり、年利3〜8%の配当を受け取れる。現物不動産と異なり管理不要。",
              tag: "不動産"),
        .init(emoji: "💹", title: "ドルコスト平均法の複利効果",
              detail: "毎月一定額を投資するだけで、高値掴みリスクを自動分散。20年間で元本500万円→試算1,200万円超（年率5%複利）。時間が最大の武器。",
              tag: "長期投資"),
        .init(emoji: "🌏", title: "外貨建て資産でリスクヘッジ",
              detail: "円だけで資産を持つと円安時に実質資産が目減りする。全世界株式インデックスや米国債ETFを組み合わせることで為替リスクを分散。資産の20〜30%を外貨建てに。",
              tag: "為替"),
        .init(emoji: "🎯", title: "副業×節税のダブル効果",
              detail: "副業収入が年20万円超で確定申告が必要になるが、同時に経費（通信費・書籍代・PC代等）を計上できる。青色申告承認申請書を提出すれば最大65万円の特別控除も。",
              tag: "節税"),
        .init(emoji: "🔮", title: "iDeCo+NISAの最適組み合わせ",
              detail: "iDeCoで老後資金（掛金全額所得控除）＋NISAで中期資産形成（運用益非課税）の二刀流が最強。会社員なら毎月iDeCo2.3万円+NISA積立3万円で年間控除・非課税効果は30万円超。",
              tag: "制度活用"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        // ヘッダーバナー
                        HStack(spacing: 12) {
                            Text("👑")
                                .font(.system(size: 36))
                            VStack(alignment: .leading, spacing: 3) {
                                Text("7日ログインで解放された！")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(red: 0.45, green: 0.20, blue: 0.80))
                                Text("上級者向けのお金の増やし方を紹介します")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColor.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.94, green: 0.88, blue: 1.0), Color(red: 0.85, green: 0.75, blue: 1.0)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)

                        ForEach(tips) { tip in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    Text(tip.emoji)
                                        .font(.system(size: 28))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(tip.title)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(AppColor.textPrimary)
                                        Text(tip.tag)
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(Color(red: 0.55, green: 0.30, blue: 0.90))
                                            .padding(.horizontal, 7).padding(.vertical, 2)
                                            .background(Color(red: 0.55, green: 0.30, blue: 0.90).opacity(0.10))
                                            .cornerRadius(6)
                                    }
                                    Spacer()
                                }
                                Text(tip.detail)
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColor.textSecondary)
                                    .lineSpacing(3)
                            }
                            .padding(14)
                            .background(AppColor.cardBackground)
                            .cornerRadius(14)
                            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("マネーマスター術")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
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
