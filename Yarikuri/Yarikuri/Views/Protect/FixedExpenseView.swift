import SwiftUI
import Charts

private struct FixedExpChartPoint: Identifiable {
    let id = UUID()
    let month: Int
    let amount: Int
    let year: Int
}

// MARK: - 固定費・サブスク整理画面
struct FixedExpenseView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showAddForm = false
    @State private var showReport = false
    @State private var selectedReviewExpense: FixedExpense? = nil
    @State private var editingExpense: FixedExpense? = nil
    @State private var selectedChartMonth: Int? = nil
    @State private var newName = ""
    @State private var newAmountText = ""
    @State private var newCategory: FixedExpenseCategory = .other
    @State private var newIsSubscription = false
    @State private var newBillingDay: Int = 1
    @State private var newHolidayShift: HolidayShift = .none

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 合計サマリー
                        totalSummaryCard

                        // 固定費推移グラフ
                        fixedExpenseChartCard

                        // 見直し候補セクション
                        if !reviewCandidates.isEmpty {
                            reviewCandidatesCard
                        }

                        // 今月の固定費明細
                        allExpensesCard

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("固定費")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 14) {
                        Button(action: { showReport = true }) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(AppColor.primary)
                        }
                        Button(action: { withAnimation { showAddForm = true } }) {
                            Image(systemName: "plus")
                                .foregroundColor(AppColor.primary)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
            .sheet(isPresented: $showAddForm) {
                addExpenseSheet
            }
            .sheet(isPresented: $showReport) {
                MonthlyReportView().environmentObject(appState)
            }
            .sheet(item: $selectedReviewExpense) { expense in
                ReviewLinksSheet(expense: expense)
            }
            .sheet(item: $editingExpense) { expense in
                EditFixedExpenseSheet(expense: expense) { updated in
                    if let idx = appState.fixedExpenses.firstIndex(where: { $0.id == updated.id }) {
                        appState.fixedExpenses[idx] = updated
                    }
                }
                .environmentObject(appState)
            }
        }
    }

    // MARK: - 固定費推移グラフカード
    private var fixedExpChartPoints: [FixedExpChartPoint] {
        var points = appState.fixedExpenseHistory.map {
            FixedExpChartPoint(month: $0.month, amount: $0.totalAmount, year: $0.year)
        }
        // 当月分を追加（履歴にない場合）
        let cal = Calendar.current
        let now = Date()
        let currentYear = cal.component(.year, from: now)
        let currentMonth = cal.component(.month, from: now)
        let total = appState.totalFixedExpenses
        if total > 0 && !appState.fixedExpenseHistory.contains(where: { $0.year == currentYear && $0.month == currentMonth }) {
            points.append(FixedExpChartPoint(month: currentMonth, amount: total, year: currentYear))
        }
        return points
    }

    private func fixedExpAmount(year: Int, month: Int) -> Int? {
        fixedExpChartPoints.first { $0.year == year && $0.month == month }?.amount
    }

    private var fixedExpYears: [Int] {
        Array(Set(appState.fixedExpenseHistory.map { $0.year })).sorted()
    }

    private func fixedExpColor(for year: Int) -> Color {
        let colors: [Color] = [AppColor.tertiary, AppColor.primary, AppColor.safe, AppColor.caution]
        let idx = fixedExpYears.firstIndex(of: year) ?? 0
        return colors[idx % colors.count]
    }

    private var fixedExpYearlyTotals: [(year: Int, total: Int)] {
        let grouped = Dictionary(grouping: appState.fixedExpenseHistory, by: { $0.year })
        return grouped.map { (year: $0.key, total: $0.value.reduce(0) { $0 + $1.totalAmount }) }
            .sorted { $0.year > $1.year }
    }

    private var fixedExpenseChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("固定費の推移")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                if !fixedExpYearlyTotals.isEmpty {
                    VStack(alignment: .trailing, spacing: 3) {
                        ForEach(fixedExpYearlyTotals, id: \.year) { item in
                            HStack(spacing: 5) {
                                Text(String(item.year) + "年")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColor.textTertiary)
                                Text(item.total.yen)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(fixedExpColor(for: item.year))
                            }
                        }
                    }
                }
            }

            // タップ時情報表示（固定高さ）
            ZStack {
                if let month = selectedChartMonth {
                    HStack(spacing: 12) {
                        Text("\(month)月")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        ForEach(fixedExpYears, id: \.self) { year in
                            if let amt = fixedExpAmount(year: year, month: month) {
                                Rectangle().fill(AppColor.sectionBackground).frame(width: 1, height: 32)
                                VStack(spacing: 2) {
                                    Text(String(year) + "年")
                                        .font(.system(size: 10))
                                        .foregroundColor(AppColor.textTertiary)
                                    Text(amt.yen)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(fixedExpColor(for: year))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColor.sectionBackground.opacity(0.8))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                } else {
                    Text("グラフをタップ・ドラッグして確認")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(height: 50)

            if fixedExpChartPoints.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 36))
                        .foregroundColor(AppColor.textTertiary.opacity(0.5))
                    Text("履歴データがまだありません")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
            } else {
                Chart {
                    ForEach(fixedExpChartPoints) { point in
                        AreaMark(
                            x: .value("月", point.month),
                            yStart: .value("固定費", 0),
                            yEnd: .value("固定費", point.amount),
                            series: .value("年", String(point.year))
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [fixedExpColor(for: point.year).opacity(0.22), fixedExpColor(for: point.year).opacity(0.0)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("月", point.month),
                            y: .value("固定費", point.amount),
                            series: .value("年", String(point.year))
                        )
                        .foregroundStyle(fixedExpColor(for: point.year))
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.catmullRom)
                        .shadow(color: fixedExpColor(for: point.year).opacity(0.35), radius: 4, x: 0, y: 2)

                        PointMark(
                            x: .value("月", point.month),
                            y: .value("固定費", point.amount)
                        )
                        .foregroundStyle(fixedExpColor(for: point.year))
                        .symbolSize(32)
                    }
                    if let month = selectedChartMonth {
                        RuleMark(x: .value("月", month))
                            .foregroundStyle(AppColor.textSecondary.opacity(0.4))
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        ForEach(fixedExpYears, id: \.self) { year in
                            if let amt = fixedExpAmount(year: year, month: month) {
                                PointMark(
                                    x: .value("月", month),
                                    y: .value("固定費", amt)
                                )
                                .foregroundStyle(fixedExpColor(for: year))
                                .symbolSize(80)
                            }
                        }
                    }
                }
                .chartXScale(domain: 1...12)
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("¥\(v / 10000)万")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColor.textTertiary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: [1, 3, 6, 9, 12]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.gray.opacity(0.18))
                        AxisValueLabel {
                            if let m = value.as(Int.self) {
                                Text("\(m)月")
                                    .font(.system(size: 9))
                                    .foregroundColor(AppColor.textTertiary)
                            }
                        }
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let originX = geo[proxy.plotAreaFrame].origin.x
                                        let xPos = value.location.x - originX
                                        guard xPos >= 0, xPos <= geo[proxy.plotAreaFrame].width else {
                                            selectedChartMonth = nil; return
                                        }
                                        if let raw: Int = proxy.value(atX: xPos) {
                                            selectedChartMonth = max(1, min(raw, 12))
                                        }
                                    }
                                    .onEnded { _ in selectedChartMonth = nil }
                            )
                    }
                }
            }
        }
        .cardStyle()
    }

    private var reviewCandidates: [FixedExpense] {
        appState.fixedExpenses.filter { $0.isReviewCandidate }
    }

    // MARK: - 合計サマリーカード
    private var totalSummaryCard: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("今月の固定費合計").font(.system(size: 13)).foregroundColor(AppColor.textSecondary)
                Text(appState.totalFixedExpenses.yen)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                let subTotal = appState.fixedExpenses.filter { $0.isSubscription }.reduce(0) { $0 + $1.amount }
                Text("サブスク計").font(.system(size: 12)).foregroundColor(AppColor.textTertiary)
                Text(subTotal.yen)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.caution)
            }
        }
        .cardStyle()
    }

    // MARK: - 見直し候補カード
    private var reviewCandidatesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("✂️ 見直し候補")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.caution)
                Text("まとめて\(reviewCandidates.reduce(0){$0+$1.amount}.yen)が節約候補")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textTertiary)
                    .padding(.leading, 4)
                Spacer()
            }

            Text("👆 タップすると安くできるか調べられます")
                .font(.system(size: 11))
                .foregroundColor(AppColor.textTertiary)

            ForEach(reviewCandidates) { expense in
                Button(action: { selectedReviewExpense = expense }) {
                    ExpenseDetailRow(expense: expense, showReviewBadge: true)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(AppColor.cautionLight)
        .cornerRadius(14)
    }

    // MARK: - 全固定費リスト
    private var allExpensesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今月の固定費明細")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            if appState.fixedExpenses.isEmpty {
                VStack(spacing: 8) {
                    Text("📋").font(.system(size: 32))
                    Text("まだ登録されていません")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(FixedExpenseCategory.allCases, id: \.rawValue) { category in
                    let expenses = appState.fixedExpenses.filter { $0.category == category }
                    if !expenses.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(category.emoji) \(category.displayText)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppColor.textTertiary)

                            ForEach(expenses) { expense in
                                HStack(spacing: 6) {
                                    Button(action: { selectedReviewExpense = expense }) {
                                        ExpenseDetailRow(expense: expense, showReviewBadge: false)
                                    }
                                    .buttonStyle(.plain)

                                    VStack(spacing: 6) {
                                        Button {
                                            editingExpense = expense
                                        } label: {
                                            Image(systemName: "pencil")
                                                .font(.system(size: 13))
                                                .foregroundColor(AppColor.primary)
                                                .frame(width: 32, height: 32)
                                                .background(AppColor.primaryLight)
                                                .cornerRadius(8)
                                        }
                                        Button {
                                            appState.fixedExpenses.removeAll { $0.id == expense.id }
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 13))
                                                .foregroundColor(AppColor.caution)
                                                .frame(width: 32, height: 32)
                                                .background(AppColor.cautionLight)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - 追加シート
    private var addExpenseSheet: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("名前（例: Netflix）", text: $newName)
                    TextField("金額（円）", text: $newAmountText)
                        .keyboardType(.numberPad)
                    Picker("カテゴリ", selection: $newCategory) {
                        ForEach(FixedExpenseCategory.allCases, id: \.rawValue) { cat in
                            Text("\(cat.emoji) \(cat.displayText)").tag(cat)
                        }
                    }
                }
                Section("詳細") {
                    Toggle("サブスクリプション", isOn: $newIsSubscription)
                    Picker("引き落とし日", selection: $newBillingDay) {
                        ForEach(1...31, id: \.self) { day in
                            Text("毎月\(day)日").tag(day)
                        }
                    }
                    Picker("引き落とし日が休日の場合", selection: $newHolidayShift) {
                        ForEach(HolidayShift.allCases, id: \.rawValue) { shift in
                            Text(shift.displayText).tag(shift)
                        }
                    }
                }
            }
            .navigationTitle("固定費を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("追加") {
                        if let amount = Int(newAmountText), !newName.isEmpty {
                            let expense = FixedExpense(
                                name: newName, amount: amount, billingDay: newBillingDay,
                                holidayShift: newHolidayShift,
                                category: newCategory, isSubscription: newIsSubscription
                            )
                            appState.fixedExpenses.append(expense)
                            showAddForm = false
                        }
                    }
                    .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { showAddForm = false }
                }
            }
        }
    }
}

// MARK: - 固定費詳細行
struct ExpenseDetailRow: View {
    let expense: FixedExpense
    let showReviewBadge: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(expense.category.emoji)
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(AppColor.sectionBackground)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(expense.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    if expense.isSubscription {
                        Text("サブスク")
                            .font(.system(size: 10))
                            .foregroundColor(Color.purple.opacity(0.8))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                if let day = expense.billingDay {
                    Text("毎月\(day)日")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textTertiary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(expense.amount.yen)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                if showReviewBadge {
                    Text("見直し可")
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.caution)
                }
            }
        }
        .padding(10)
        .background(AppColor.cardBackground)
        .cornerRadius(10)
        .shadow(color: AppColor.shadowColor, radius: 3)
    }
}

// MARK: - 見直しリンクシート
struct ReviewLinksSheet: View {
    let expense: FixedExpense
    @Environment(\.dismiss) private var dismiss

    // リンクの種別
    enum LinkKind { case cancel, compare }

    struct ReviewLink: Identifiable {
        let id = UUID()
        let kind: LinkKind
        let emoji: String
        let title: String
        let subtitle: String
        let url: URL
    }

    // カテゴリが比較のみか（解約リンクを非表示）
    private var isComparisonOnly: Bool {
        switch expense.category {
        case .rent, .utilities, .phone, .insurance:
            return true
        default:
            return false
        }
    }

    // MARK: リンク生成
    private var links: [ReviewLink] {
        var result: [ReviewLink] = []
        result += cancelLinks
        result += compareLinks
        return result
    }

    // サービス名から解約リンクを生成
    private var cancelLinks: [ReviewLink] {
        let n = expense.name.lowercased()
        let known: [(keys: [String], title: String, sub: String, urlStr: String)] = [
            (["netflix", "ネットフリックス"],
             "Netflix 解約ページ", "メンバーシップをキャンセル",
             "https://www.netflix.com/cancelplan"),
            (["amazon prime", "amazonプライム", "prime video", "プライムビデオ"],
             "Amazon Prime 会員管理", "Prime会員資格を終了",
             "https://www.amazon.co.jp/mc"),
            (["hulu", "フールー"],
             "Hulu マイページ", "アカウント設定から解約",
             "https://auth.hulu.com/web/login"),
            (["disney", "ディズニー"],
             "Disney+ アカウント", "サブスクリプション設定",
             "https://www.disneyplus.com/ja-jp/account"),
            (["spotify", "スポティファイ"],
             "Spotify アカウント", "プレミアムをキャンセル",
             "https://www.spotify.com/jp/account/overview/"),
            (["youtube premium", "youtubepremium", "youtubeプレミアム"],
             "YouTube Premium 管理", "メンバーシップ設定",
             "https://www.youtube.com/account_management"),
            (["apple music", "apple tv", "apple one"],
             "Apple ID 管理", "サブスクリプションの管理",
             "https://appleid.apple.com/ja/"),
            (["u-next", "ユーネクスト"],
             "U-NEXT マイページ", "解約はマイページから",
             "https://video.unext.jp/"),
            (["dazn", "ダゾーン"],
             "DAZN アカウント", "サブスクリプション設定",
             "https://www.dazn.com/ja-JP/account"),
            (["abema", "アベマ"],
             "ABEMA プレミアム", "アカウント設定から解約",
             "https://abema.tv/account"),
            (["nhk", "nhkプラス"],
             "NHKオンライン", "受信料・契約の確認",
             "https://pid.nhk.or.jp/"),
            (["楽天マガジン"],
             "楽天マガジン マイページ", "解約申請はこちら",
             "https://magazine.rakuten.co.jp/"),
            (["kindle", "kindleアンリミテッド"],
             "Kindle Unlimited 管理", "プランのキャンセル",
             "https://www.amazon.co.jp/gp/kindle/ku/sign-in"),
            (["audible", "オーディブル"],
             "Audible 会員管理", "会員資格の一時停止・解約",
             "https://www.audible.co.jp/account/cancel-membership"),
        ]
        for entry in known {
            if entry.keys.contains(where: { n.contains($0) }),
               let url = URL(string: entry.urlStr) {
                return [ReviewLink(kind: .cancel, emoji: "🔗",
                                   title: entry.title, subtitle: entry.sub, url: url)]
            }
        }
        // 該当なし → Google検索
        let query = "\(expense.name) 解約方法".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://www.google.com/search?q=\(query)") {
            return [ReviewLink(kind: .cancel, emoji: "🔍",
                               title: "\(expense.name) の解約方法を検索",
                               subtitle: "Googleで解約手順を確認", url: url)]
        }
        return []
    }

    // カテゴリから比較サイトを生成
    private var compareLinks: [ReviewLink] {
        switch expense.category {
        case .phone:
            return [
                ReviewLink(kind: .compare, emoji: "📊",
                           title: "格安SIM 比較 – 価格.com",
                           subtitle: "通信費を月3,000円以上節約できる可能性",
                           url: URL(string: "https://kakaku.com/mobile/sim/")!),
                ReviewLink(kind: .compare, emoji: "📊",
                           title: "SIMフリー・格安スマホ比較 – MVNO.net",
                           subtitle: "キャリア別料金プランを一覧比較",
                           url: URL(string: "https://kakaku.com/mobile/")!),
            ]
        case .insurance:
            return [
                ReviewLink(kind: .compare, emoji: "📊",
                           title: "生命保険 一括比較 – インズウェブ",
                           subtitle: "複数社の保険料をまとめて比較",
                           url: URL(string: "https://www.insweb.co.jp/")!),
                ReviewLink(kind: .compare, emoji: "📊",
                           title: "保険の窓口 – 無料相談",
                           subtitle: "FPによる無料保険見直し相談",
                           url: URL(string: "https://www.hokennomadoguchi.com/")!),
            ]
        case .utilities:
            return [
                ReviewLink(kind: .compare, emoji: "📊",
                           title: "電力・ガス 切替 – エネチェンジ",
                           subtitle: "郵便番号入力だけで節約額を試算",
                           url: URL(string: "https://enechange.jp/")!),
                ReviewLink(kind: .compare, emoji: "📊",
                           title: "電気料金 比較 – 価格.com",
                           subtitle: "エリア別に電気会社を比較",
                           url: URL(string: "https://kakaku.com/energy/")!),
            ]
        case .subscription:
            return [
                ReviewLink(kind: .compare, emoji: "📊",
                           title: "動画配信サービス比較 – 価格.com",
                           subtitle: "月額・コンテンツ数・機能を比較",
                           url: URL(string: "https://kakaku.com/internet/video-streaming/")!),
            ]
        case .gym:
            return [
                ReviewLink(kind: .compare, emoji: "🔍",
                           title: "近くのジムを比較検索",
                           subtitle: "月額・設備・口コミで比較",
                           url: URL(string: "https://www.google.com/search?q=ジム+月額+比較+格安")!),
                ReviewLink(kind: .compare, emoji: "📊",
                           title: "格安フィットネスクラブ特集 – EPARK",
                           subtitle: "月額3,000円以下のジムも",
                           url: URL(string: "https://epark.jp/fitness/")!),
            ]
        case .loan:
            return [
                ReviewLink(kind: .compare, emoji: "📊",
                           title: "カードローン 金利比較 – 価格.com",
                           subtitle: "低金利ローンへの借り換えを検討",
                           url: URL(string: "https://kakaku.com/card/loan/")!),
            ]
        case .transport:
            return [
                ReviewLink(kind: .compare, emoji: "🔍",
                           title: "定期代 経路・運賃比較",
                           subtitle: "乗換案内で定期代の最安経路を確認",
                           url: URL(string: "https://roote.ekispert.net/ja/")!),
            ]
        default:
            return [
                ReviewLink(kind: .compare, emoji: "🔍",
                           title: "\(expense.name) の代替サービスを検索",
                           subtitle: "より安いサービスを探す",
                           url: URL(string: "https://www.google.com/search?q=\(expense.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") 代替 格安")!),
            ]
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 対象サービス情報
                        HStack(spacing: 14) {
                            Text(expense.category.emoji)
                                .font(.system(size: 32))
                                .frame(width: 52, height: 52)
                                .background(AppColor.cautionLight)
                                .cornerRadius(12)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(expense.name)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(AppColor.textPrimary)
                                Text("月額 \(expense.amount.yen)")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColor.caution)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(AppColor.cardBackground)
                        .cornerRadius(14)
                        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)

                        // 解約リンク（家賃・光熱費・通信費・保険は非表示）
                        if !isComparisonOnly {
                            let cancelItems = links.filter { $0.kind == .cancel }
                            if !cancelItems.isEmpty {
                                linkSection(title: "🗑️ 解約・退会", items: cancelItems)
                            }
                        }

                        // 比較サイト
                        let compareItems = links.filter { $0.kind == .compare }
                        if !compareItems.isEmpty {
                            linkSection(title: "📊 乗り換え・比較サイト", items: compareItems)
                        }

                        // 節約メモ
                        VStack(alignment: .leading, spacing: 6) {
                            Text("💡 節約のヒント")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)
                            Text(savingHint)
                                .font(.system(size: 13))
                                .foregroundColor(AppColor.textSecondary)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(AppColor.primaryLight.opacity(0.4))
                        .cornerRadius(12)

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("見直しガイド")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func linkSection(title: String, items: [ReviewLink]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)
            ForEach(items) { link in
                Link(destination: link.url) {
                    HStack(spacing: 12) {
                        Text(link.emoji)
                            .font(.system(size: 20))
                            .frame(width: 36, height: 36)
                            .background(AppColor.sectionBackground)
                            .cornerRadius(8)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(link.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColor.textPrimary)
                            Text(link.subtitle)
                                .font(.system(size: 11))
                                .foregroundColor(AppColor.textTertiary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.primary.opacity(0.7))
                    }
                    .padding(12)
                    .background(AppColor.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: AppColor.shadowColor, radius: 3, x: 0, y: 1)
                }
            }
        }
    }

    private var savingHint: String {
        switch expense.category {
        case .phone:
            return "大手キャリアから格安SIMに乗り換えると月3,000〜8,000円の節約になることがあります。まずは現在の料金プランを確認し、データ使用量に合ったプランか見直してみましょう。"
        case .insurance:
            return "保険は定期的な見直しが大切です。ライフステージの変化（結婚・出産・転職）に合わせて、補償内容と保険料のバランスを確認しましょう。重複している保障がないかもチェックを。"
        case .utilities:
            return "電力自由化で電力会社を自由に選べます。年間1〜3万円の節約につながるケースも。契約アンペア数を実態に合わせて下げるだけでも効果があります。"
        case .subscription:
            return "使用頻度が月3回以下なら解約を検討しましょう。複数の動画サービスを契約している場合は1つに絞るか、家族プランへの変更でコストを削減できます。"
        case .gym:
            return "月の利用回数を振り返ってみましょう。週1回未満なら解約してYouTubeの無料フィットネス動画や、都度払いの施設を利用する方が節約になることがほとんどです。"
        case .loan:
            return "高金利のローンは低金利への借り換えで総返済額を大きく減らせます。複数のローンをおまとめする「債務整理」も選択肢のひとつです。"
        default:
            return "本当に必要か、月に何回使っているか見直してみましょう。使用頻度が低いサービスを解約するだけで、意外と大きな節約になります。"
        }
    }
}

// MARK: - 固定費編集シート
struct EditFixedExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    let expense: FixedExpense
    let onSave: (FixedExpense) -> Void

    @State private var name: String
    @State private var amountText: String
    @State private var category: FixedExpenseCategory
    @State private var billingDay: Int
    @State private var holidayShift: HolidayShift
    @State private var isSubscription: Bool

    init(expense: FixedExpense, onSave: @escaping (FixedExpense) -> Void) {
        self.expense = expense
        self.onSave = onSave
        _name = State(initialValue: expense.name)
        _amountText = State(initialValue: "\(expense.amount)")
        _category = State(initialValue: expense.category)
        _billingDay = State(initialValue: expense.billingDay ?? 1)
        _holidayShift = State(initialValue: expense.holidayShift ?? .none)
        _isSubscription = State(initialValue: expense.isSubscription)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("名前（例: Netflix）", text: $name)
                    TextField("金額（円）", text: $amountText)
                        .keyboardType(.numberPad)
                    Picker("カテゴリ", selection: $category) {
                        ForEach(FixedExpenseCategory.allCases, id: \.rawValue) { cat in
                            Text("\(cat.emoji) \(cat.displayText)").tag(cat)
                        }
                    }
                }
                Section("詳細") {
                    Toggle("サブスクリプション", isOn: $isSubscription)
                    Picker("引き落とし日", selection: $billingDay) {
                        ForEach(1...31, id: \.self) { day in
                            Text("毎月\(day)日").tag(day)
                        }
                    }
                    Picker("引き落とし日が休日の場合", selection: $holidayShift) {
                        ForEach(HolidayShift.allCases, id: \.rawValue) { shift in
                            Text(shift.displayText).tag(shift)
                        }
                    }
                }
            }
            .navigationTitle("固定費を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        guard let amount = Int(amountText), !name.isEmpty else { return }
                        var updated = expense
                        updated.name = name
                        updated.amount = amount
                        updated.category = category
                        updated.billingDay = billingDay
                        updated.holidayShift = holidayShift
                        updated.isSubscription = isSubscription
                        onSave(updated)
                        dismiss()
                    }
                    .foregroundColor(AppColor.primary)
                    .disabled(name.isEmpty || Int(amountText) == nil)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    FixedExpenseView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
