import SwiftUI

// MARK: - レポート（週間・月間・年間）
struct MonthlyReportView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    var embedded: Bool = false
    @State private var selectedPeriod: ReportPeriod = .monthly

    enum ReportPeriod: String, CaseIterable {
        case weekly = "週間"
        case monthly = "月間"
        case yearly = "年間"
    }

    var body: some View {
        if embedded {
            scrollContent
        } else {
            NavigationStack {
                scrollContent
                    .navigationTitle("レポート")
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

    private var scrollContent: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            if embedded {
                // ReportContainerView 内に埋め込み時は月間コンテンツのみ
                let report = appState.monthlyReport
                ScrollView {
                    VStack(spacing: 18) {
                        monthlyContent(report: report)
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            } else {
                VStack(spacing: 0) {
                    // スライドグラス風ピッカー
                    Picker("期間", selection: $selectedPeriod) {
                        ForEach(ReportPeriod.allCases, id: \.self) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    let report = appState.monthlyReport
                    ScrollView {
                        VStack(spacing: 18) {
                            switch selectedPeriod {
                            case .weekly:
                                weeklyContent
                            case .monthly:
                                monthlyContent(report: report)
                            case .yearly:
                                yearlyContent
                            }
                            Spacer().frame(height: 20)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
            }
        }
    }

    // MARK: - 週間コンテンツ
    private var weeklyContent: some View {
        VStack(spacing: 18) {
            monthlySummaryTotalsCard
            ActionStackedBarChart(title: "過去6週間の行動", bars: past6WeekBars())
            ReportBarChart(title: "今週の日ごとの支出", bars: dailyBars(), unit: "円", savingsLabel: "収入")
        }
    }

    // MARK: - 月間コンテンツ
    private func monthlyContent(report: MonthlyReport) -> some View {
        VStack(spacing: 18) {
            BudgetFlowCard(
                income: appState.monthlyIncome,
                fixedExpenses: appState.totalFixedExpenses,
                debtPayments: appState.totalMonthlyDebtPayments,
                scheduledPayments: appState.totalScheduledPayments,
                remaining: appState.remainingBudget
            )
            SavingsProjectionCard(monthlySaving: appState.remainingBudget)
            monthlySummaryTotalsCard
            ActionStackedBarChart(title: "過去6週間の行動", bars: past6WeekBars())
            ReportBarChart(title: "今月の週ごとの収支", bars: weeklyBars(), unit: "円", savingsLabel: "収入")
            monthlySummaryCard(report: report)
            incomeBreakdownCard(report: report)
            comparisonCard(report: report)
            if appState.remainingBudget > 0 {
                CompoundGrowthCard(monthlySaving: appState.remainingBudget)
            }
            improvementsCard(report: report)
        }
    }

    // MARK: - 年間コンテンツ
    private var yearlyContent: some View {
        VStack(spacing: 18) {
            monthlySummaryTotalsCard
            ReportBarChart(title: "過去12ヶ月の収支", bars: monthlyBars(), unit: "円", savingsLabel: "収入")
        }
    }

    // MARK: - 月間合算カード（リングゲージ）
    private var monthlySummaryTotalsCard: some View {
        let protect = appState.monthlyProtectActions.count
        let grow = appState.monthlyGrowActions.count
        let saved = appState.monthlyProtectedAmount
        let income = max(1, appState.monthlyIncome)
        let savedRatio   = min(1.0, Double(saved) / Double(income))
        let learnRatio   = min(1.0, Double(protect + grow) / 20.0)
        let protectRatio = min(1.0, Double(protect) / 10.0)

        return VStack(spacing: 10) {
            HStack {
                Text("📊 今月の合算")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
                Text(monthText(Date()))
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textTertiary)
            }
            HStack(spacing: 0) {
                MiniRingGauge(
                    emoji: "💰",
                    ratio: savedRatio,
                    color: AppColor.primary,
                    centerText: monthlyCenterText(saved),
                    label: "収入"
                )
                Divider().frame(height: 80)
                MiniRingGauge(
                    emoji: "📚",
                    ratio: learnRatio,
                    color: AppColor.secondary,
                    centerText: "\(protect + grow)件",
                    label: "学んだ件数"
                )
                Divider().frame(height: 80)
                MiniRingGauge(
                    emoji: "🛡️",
                    ratio: protectRatio,
                    color: Color(red: 0.27, green: 0.52, blue: 0.96),
                    centerText: "\(protect)件",
                    label: "支出を減らす行動"
                )
            }
        }
        .cardStyle()
    }

    private func monthlyCenterText(_ v: Int) -> String {
        if v >= 10000 {
            let d = Double(v) / 10000.0
            return d.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(d))万" : String(format: "%.1f万", d)
        }
        return v > 0 ? "\(v)円" : "0円"
    }

    // MARK: - 過去6週間 アクション棒グラフデータ
    private func past6WeekBars() -> [ActionStackedBarChart.Bar] {
        let calendar = Calendar.current
        let today = Date()
        let totalProtect = max(6, appState.protectActionsTotal)
        let totalGrow    = max(4, appState.growActionsTotal)
        let avgProtect   = Double(totalProtect) / 6.0
        let avgGrow      = Double(totalGrow) / 6.0
        let pVar: [Double] = [0.50, 0.70, 0.85, 1.08, 0.92, 1.0]
        let gVar: [Double] = [0.42, 0.62, 0.78, 1.05, 0.98, 1.0]
        let df = DateFormatter(); df.dateFormat = "M/d"; df.locale = Locale(identifier: "ja_JP")

        return (0..<6).map { i in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -(5 - i), to: today) ?? today
            let isCurrentWeek = i == 5
            let p = max(0, Int((avgProtect * pVar[i]).rounded()))
            let g = max(0, Int((avgGrow    * gVar[i]).rounded()))
            return ActionStackedBarChart.Bar(
                label: df.string(from: weekStart),
                protectCount: p, growCount: g,
                isCurrentPeriod: isCurrentWeek
            )
        }
    }

    // MARK: - 週ごとのバーデータ生成
    private func weeklyBars() -> [ReportBarChart.Bar] {
        let calendar = Calendar.current
        let today = Date()
        let variations: [Double] = [0.88, 1.05, 0.92, 0.78, 0.60]

        // 今月の1日
        let comps = calendar.dateComponents([.year, .month], from: today)
        guard let monthStart = calendar.date(from: comps) else { return [] }

        // 今月の週数を算出（最大5週）
        let range = calendar.range(of: .weekOfMonth, in: .month, for: today) ?? (1..<5)
        let weekCount = min(5, range.count)

        return (0..<weekCount).map { i in
            // 第i週の開始日
            let weekStart = calendar.date(byAdding: .weekOfMonth, value: i, to: monthStart) ?? today
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? today
            let isCurrentWeek = today >= weekStart && today <= weekEnd
            let isFuture = weekStart > today

            // 最終週は部分的なため日数に応じてスケール
            let daysInWeek: Int
            if let nextWeekStart = calendar.date(byAdding: .weekOfMonth, value: i + 1, to: monthStart),
               let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) {
                let end = min(nextWeekStart, monthEnd)
                daysInWeek = max(1, calendar.dateComponents([.day], from: weekStart, to: end).day ?? 7)
            } else {
                daysInWeek = 7
            }

            // 月収ベースで週予算を計算（未設定時は20万円/月を想定）
            let weeklyIncome = max(200_000, appState.monthlyIncome) / 4
            let scaledBudget = weeklyIncome * daysInWeek / 7
            let value = isFuture ? 0 : isCurrentWeek
                ? Int(Double(scaledBudget) * 0.65)
                : Int(Double(scaledBudget) * variations[i])

            return ReportBarChart.Bar(
                label: "第\(i + 1)週",
                value: value,
                budget: scaledBudget,
                isCurrentPeriod: isCurrentWeek,
                isFuture: isFuture
            )
        }
    }

    // MARK: - 今週の日別バーデータ
    private func dailyBars() -> [ReportBarChart.Bar] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let labels = ["月", "火", "水", "木", "金", "土", "日"]
        // 月収ベースで1日予算を計算（未設定時は20万円/月を想定）
        let budget = max(200_000, appState.monthlyIncome) / 30
        let variations: [Double] = [0.82, 1.05, 0.90, 1.15, 0.75, 1.30, 0.95]
        return (0..<7).map { i in
            let isFuture = i > daysFromMonday
            let isToday  = i == daysFromMonday
            return ReportBarChart.Bar(
                label: labels[i],
                value: isFuture ? 0 : isToday ? Int(Double(budget) * 0.55) : Int(Double(budget) * variations[i]),
                budget: budget,
                isCurrentPeriod: isToday,
                isFuture: isFuture
            )
        }
    }

    // MARK: - 過去12ヶ月バーデータ
    private func monthlyBars() -> [ReportBarChart.Bar] {
        let calendar = Calendar.current
        let today = Date()
        let df = DateFormatter(); df.dateFormat = "M月"; df.locale = Locale(identifier: "ja_JP")
        // 支出バリエーション（収入の65〜85%帯を行き来して節約感が出るようにする）
        let variations: [Double] = [0.78, 0.82, 0.75, 0.80, 0.85, 0.72, 0.79, 0.83, 0.76, 0.70, 0.81, 0.68]
        // 月収ベースで計算（未設定時は25万円/月を想定）
        let monthlyBudget = max(250_000, appState.monthlyIncome)
        return (0..<12).map { i in
            let month = calendar.date(byAdding: .month, value: -(11 - i), to: today) ?? today
            let isCurrent = i == 11
            return ReportBarChart.Bar(
                label: df.string(from: month),
                value: isCurrent ? Int(Double(monthlyBudget) * 0.65) : Int(Double(monthlyBudget) * variations[i]),
                budget: monthlyBudget,
                isCurrentPeriod: isCurrent,
                isFuture: false
            )
        }
    }

    // MARK: - 月次サマリーカード（ドーナツ + 比率バー）
    private func monthlySummaryCard(report: MonthlyReport) -> some View {
        let income = max(1, report.totalIncome)
        return VStack(spacing: 16) {
            HStack {
                Text("月次サマリー")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(AppColor.textSecondary)
                Spacer()
                Text(monthText(report.month))
                    .font(.system(size: 13)).foregroundColor(AppColor.textTertiary)
            }
            HStack(spacing: 24) {
                ZStack {
                    Circle().stroke(AppColor.sectionBackground, lineWidth: 12).frame(width: 100, height: 100)
                    Circle()
                        .trim(from: 0, to: CGFloat(report.savingsRate))
                        .stroke(AppColor.secondary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.0), value: report.savingsRate)
                    VStack(spacing: 0) {
                        Text("\(Int(report.savingsRate * 100))%")
                            .font(.system(size: 22, weight: .bold)).foregroundColor(AppColor.secondary)
                        Text("残り").font(.system(size: 11)).foregroundColor(AppColor.textTertiary)
                    }
                }
                VStack(alignment: .leading, spacing: 10) {
                    monthlyProportionBar(
                        label: "手取り", ratio: 1.0, color: AppColor.secondary)
                    monthlyProportionBar(
                        label: "支出",
                        ratio: Double(report.totalExpenses) / Double(income),
                        color: AppColor.primary)
                    monthlyProportionBar(
                        label: "残り",
                        ratio: max(0, Double(report.remainingAtEnd) / Double(income)),
                        color: Color(red: 0.18, green: 0.62, blue: 0.35))
                }
            }
        }
        .cardStyle()
    }

    private func monthlyProportionBar(label: String, ratio: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.system(size: 10)).foregroundColor(color)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(AppColor.sectionBackground).frame(height: 7)
                    RoundedRectangle(cornerRadius: 3).fill(color)
                        .frame(width: max(4, geo.size.width * CGFloat(min(1.0, max(0, ratio)))), height: 7)
                        .animation(.spring(response: 0.8), value: ratio)
                }
            }
            .frame(height: 7)
        }
    }

    private func incomeBreakdownCard(report: MonthlyReport) -> some View {
        ExpenseDonutChart(
            title: "支出の内訳",
            slices: [
                ExpenseDonutChart.Slice(label: "固定費",     value: report.totalFixedExpenses,    color: AppColor.primary),
                ExpenseDonutChart.Slice(label: "変動費",     value: report.totalVariableExpenses,  color: AppColor.tertiary),
                ExpenseDonutChart.Slice(label: "支払い予定", value: report.totalPayments,          color: AppColor.caution)
            ]
        )
    }

    private func comparisonCard(report: MonthlyReport) -> some View {
        let isPositive = report.previousMonthComparison >= 0
        let thisMonth  = max(0, report.totalExpenses)
        let lastMonth  = max(0, report.totalExpenses + report.previousMonthComparison)
        let maxVal     = max(1, max(thisMonth, lastMonth))
        let thisRatio  = Double(thisMonth) / Double(maxVal)
        let lastRatio  = Double(lastMonth) / Double(maxVal)

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(isPositive ? "📈" : "📉").font(.system(size: 18))
                Text("今月 vs 先月の支出")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(AppColor.textSecondary)
            }
            VStack(spacing: 10) {
                monthlyComparisonBar(
                    label: "今月",
                    ratio: thisRatio,
                    color: isPositive ? AppColor.secondary : AppColor.danger)
                monthlyComparisonBar(
                    label: "先月",
                    ratio: lastRatio,
                    color: AppColor.textSecondary.opacity(0.4))
            }
            HStack {
                Text(isPositive ? "先月より節約" : "先月より増加")
                    .font(.system(size: 12)).foregroundColor(AppColor.textTertiary)
                Spacer()
                Text(report.previousMonthComparison.yenWithSign)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isPositive ? AppColor.secondary : AppColor.danger)
            }
        }
        .cardStyle()
    }

    private func monthlyComparisonBar(label: String, ratio: Double, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppColor.textSecondary)
                .frame(width: 28, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(AppColor.sectionBackground).frame(height: 16)
                    RoundedRectangle(cornerRadius: 4).fill(color)
                        .frame(width: max(4, geo.size.width * CGFloat(ratio)), height: 16)
                        .animation(.spring(response: 0.8), value: ratio)
                }
            }
            .frame(height: 16)
        }
    }

    private func improvementsCard(report: MonthlyReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💡").font(.system(size: 18))
                Text("来月への提案")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(AppColor.textSecondary)
            }
            ForEach(report.improvementSuggestions, id: \.self) { s in
                HStack(spacing: 8) {
                    Circle().fill(AppColor.accent).frame(width: 6, height: 6)
                    Text(s).font(.system(size: 14)).foregroundColor(AppColor.textPrimary).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .cardStyle()
    }

    private func monthText(_ date: Date) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "ja_JP"); f.dateFormat = "yyyy年M月"
        return f.string(from: date)
    }
}

// MARK: - 返済進捗行
private struct DebtProgressRow: View {
    let debt: Debt

    // 残り月数から推定総額を計算し、進捗率を算出
    private var estimatedTotal: Int {
        guard let months = debt.estimatedMonthsToPayoff, months > 0 else {
            return debt.remainingBalance
        }
        return debt.remainingBalance + debt.monthlyPayment * months
    }

    private var progressRatio: Double {
        let total = estimatedTotal
        guard total > 0 else { return 0 }
        let paid = total - debt.remainingBalance
        return min(1.0, max(0, Double(paid) / Double(total)))
    }

    private var progressColor: Color {
        if progressRatio >= 0.7 { return Color(red: 0.18, green: 0.62, blue: 0.35) }
        if progressRatio >= 0.4 { return AppColor.secondary }
        return AppColor.primary
    }

    private func formatPayoffMonths(_ months: Int) -> String {
        let years = months / 12
        let rem   = months % 12
        if years == 0 { return "\(rem)ヶ月" }
        if rem   == 0 { return "\(years)年" }
        return "\(years)年\(rem)ヶ月"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(debt.debtType.emoji).font(.system(size: 14))
                Text(debt.lenderName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                Text("残\(debt.remainingBalance.yen)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColor.danger)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColor.sectionBackground)
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [progressColor.opacity(0.7), progressColor],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: max(4, geo.size.width * progressRatio), height: 10)
                        .animation(.spring(response: 0.8), value: progressRatio)
                }
            }
            .frame(height: 10)

            HStack {
                Text("返済済み約\(Int(progressRatio * 100))%")
                    .font(.system(size: 11))
                    .foregroundColor(progressColor)
                Spacer()
                if let months = debt.estimatedMonthsToPayoff {
                    Text("あと約\(formatPayoffMonths(months))")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textTertiary)
                }
            }
        }
    }
}

// MARK: - 行動件数バー
private struct ActionCountBar: View {
    let label: String
    let count: Int
    let maxCount: Int
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppColor.textSecondary)
                .frame(width: 72, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(AppColor.sectionBackground)
                        .frame(height: 20)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(color.opacity(0.8))
                        .frame(
                            width: max(4, geo.size.width * CGFloat(count) / CGFloat(maxCount)),
                            height: 20
                        )
                        .animation(.spring(response: 0.7), value: count)
                    Text("\(count)件")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                }
            }
            .frame(height: 20)
        }
    }
}

struct ReportMetricRow: View {
    let label: String
    let value: String
    let color: Color
    var body: some View {
        HStack {
            Text(label).font(.system(size: 12)).foregroundColor(AppColor.textSecondary)
            Spacer()
            Text(value).font(.system(size: 14, weight: .bold)).foregroundColor(color)
        }
    }
}

#Preview {
    MonthlyReportView()
        .environmentObject({ let s = AppState(); s.loadDemoData(); return s }())
}
