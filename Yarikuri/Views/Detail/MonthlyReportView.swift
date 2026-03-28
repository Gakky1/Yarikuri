import SwiftUI

// MARK: - 月間レポート（週単位）
struct MonthlyReportView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    var embedded: Bool = false

    var body: some View {
        if embedded {
            scrollContent
        } else {
            NavigationStack {
                scrollContent
                    .navigationTitle("月間レポート")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
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
            let report = appState.monthlyReport
            ScrollView {
                VStack(spacing: 16) {
                    monthlySummaryTotalsCard
                    ActionStackedBarChart(title: "過去6週間の行動", bars: past6WeekBars())
                    weeklyBreakdownCard
                    monthlySummaryCard(report: report)
                    incomeBreakdownCard(report: report)
                    comparisonCard(report: report)
                    improvementsCard(report: report)
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - 月間合算カード（新規）
    private var monthlySummaryTotalsCard: some View {
        let protect = appState.monthlyProtectActions.count
        let grow = appState.monthlyGrowActions.count
        let saved = appState.monthlyProtectedAmount
        return VStack(spacing: 14) {
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
                totalCell(emoji: "💰", label: "節約できた額", value: saved.yen, color: AppColor.primary)
                Divider().frame(height: 44)
                totalCell(emoji: "📚", label: "学んだ件数", value: "\(protect + grow)件", color: AppColor.secondary)
                Divider().frame(height: 44)
                totalCell(emoji: "🛡️", label: "守る行動", value: "\(protect)件", color: Color(red: 0.27, green: 0.52, blue: 0.96))
            }
        }
        .cardStyle()
    }

    private func totalCell(emoji: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(emoji).font(.system(size: 20))
            Text(label).font(.system(size: 10)).foregroundColor(AppColor.textTertiary).multilineTextAlignment(.center)
            Text(value).font(.system(size: 14, weight: .bold)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
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

    // MARK: - 週別節約額・学んだ件数テーブル（新規）
    private var weeklyBreakdownCard: some View {
        let calendar = Calendar.current
        let today = Date()
        let totalSaved = appState.monthlyProtectedAmount
        let totalLearned = appState.monthlyProtectActions.count + appState.monthlyGrowActions.count
        let savedVars: [Double] = [0.10, 0.15, 0.22, 0.28, 0.18, 0.07]
        let learnedVars: [Double] = [0.10, 0.16, 0.20, 0.26, 0.18, 0.10]
        let df = DateFormatter(); df.dateFormat = "M/d"; df.locale = Locale(identifier: "ja_JP")

        return VStack(alignment: .leading, spacing: 12) {
            Text("週ごとの内訳")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            HStack {
                Text("週").frame(width: 50, alignment: .leading)
                Spacer()
                Text("節約額").frame(width: 72, alignment: .trailing)
                Text("学んだ").frame(width: 56, alignment: .trailing)
            }
            .font(.system(size: 11))
            .foregroundColor(AppColor.textTertiary)

            ForEach(0..<6) { i in
                let weekStart = calendar.date(byAdding: .weekOfYear, value: -(5 - i), to: today) ?? today
                let isCurrentWeek = i == 5
                let saved   = Int(Double(totalSaved)   * savedVars[i])
                let learned = max(0, Int(Double(totalLearned) * learnedVars[i]))
                HStack {
                    Text(df.string(from: weekStart) + "〜")
                        .font(.system(size: 12, weight: isCurrentWeek ? .semibold : .regular))
                        .foregroundColor(isCurrentWeek ? AppColor.primary : AppColor.textPrimary)
                        .frame(width: 60, alignment: .leading)
                    Spacer()
                    Text("+\(saved.yen)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.18, green: 0.62, blue: 0.35))
                        .frame(width: 80, alignment: .trailing)
                    Text("\(learned)件")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                        .frame(width: 44, alignment: .trailing)
                }
                if i < 5 { Divider() }
            }

            Divider()
            HStack {
                Text("月間合計").font(.system(size: 12, weight: .bold)).foregroundColor(AppColor.textPrimary)
                Spacer()
                Text("+\(totalSaved.yen)").font(.system(size: 13, weight: .bold)).foregroundColor(Color(red: 0.18, green: 0.62, blue: 0.35))
                    .frame(width: 80, alignment: .trailing)
                Text("\(totalLearned)件").font(.system(size: 13, weight: .bold)).foregroundColor(AppColor.primary)
                    .frame(width: 44, alignment: .trailing)
            }
        }
        .cardStyle()
    }

    // MARK: - 週ごとのバーデータ生成（既存）
    private func weeklyBars() -> [ReportBarChart.Bar] {
        let calendar = Calendar.current
        let today = Date()
        _ = max(1, appState.dailyBudget * 7)
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

            let scaledBudget = appState.dailyBudget * daysInWeek
            let value = isFuture ? 0 : isCurrentWeek
                ? Int(Double(scaledBudget) * 0.65) // 今週は途中なので少なめ
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

    // MARK: - 既存カード
    private func monthlySummaryCard(report: MonthlyReport) -> some View {
        VStack(spacing: 16) {
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
                VStack(alignment: .leading, spacing: 8) {
                    ReportMetricRow(label: "手取り", value: report.totalIncome.yen, color: AppColor.secondary)
                    ReportMetricRow(label: "支出合計", value: report.totalExpenses.yen, color: AppColor.textPrimary)
                    ReportMetricRow(label: "月末残り", value: report.remainingAtEnd.yen, color: AppColor.primary)
                }
            }
        }
        .cardStyle()
    }

    private func incomeBreakdownCard(report: MonthlyReport) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("支出の内訳")
                .font(.system(size: 14, weight: .semibold)).foregroundColor(AppColor.textSecondary)
            let items: [(String, Int, Color)] = [
                ("固定費", report.totalFixedExpenses, AppColor.primary),
                ("変動費", report.totalVariableExpenses, AppColor.tertiary),
                ("支払い予定", report.totalPayments, AppColor.caution)
            ]
            VStack(spacing: 10) {
                ForEach(items, id: \.0) { item in
                    VStack(spacing: 4) {
                        HStack {
                            Text(item.0).font(.system(size: 13)).foregroundColor(AppColor.textSecondary)
                            Spacer()
                            Text(item.1.yen).font(.system(size: 13, weight: .semibold)).foregroundColor(AppColor.textPrimary)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3).fill(AppColor.sectionBackground).frame(height: 6)
                                let ratio = report.totalIncome > 0 ? min(1.0, Double(item.1) / Double(report.totalIncome)) : 0
                                RoundedRectangle(cornerRadius: 3).fill(item.2).frame(width: geo.size.width * ratio, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
        }
        .cardStyle()
    }

    private func comparisonCard(report: MonthlyReport) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(report.previousMonthComparison >= 0 ? AppColor.secondaryLight : AppColor.dangerLight)
                    .frame(width: 52, height: 52)
                Text(report.previousMonthComparison >= 0 ? "📈" : "📉").font(.system(size: 26))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("先月比").font(.system(size: 13)).foregroundColor(AppColor.textSecondary)
                Text(report.previousMonthComparison.yenWithSign)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(report.previousMonthComparison >= 0 ? AppColor.secondary : AppColor.danger)
                Text(report.previousMonthComparison >= 0 ? "節約できました" : "先月より使いました")
                    .font(.system(size: 12)).foregroundColor(AppColor.textTertiary)
            }
            Spacer()
        }
        .cardStyle()
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
