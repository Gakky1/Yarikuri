import SwiftUI

// MARK: - 年間レポート（月単位）
struct AnnualReportView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    var embedded: Bool = false

    var body: some View {
        if embedded {
            scrollContent
        } else {
            NavigationStack {
                scrollContent
                    .navigationTitle("年間レポート")
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
            ScrollView {
                VStack(spacing: 16) {
                    annualTotalsCard
                    ActionStackedBarChart(title: "\(currentYear)年 月ごとの行動", bars: monthlyActionBars())
                    debtProgressAnnualCard
                    ReportBarChart(title: "\(currentYear)年 月ごとの収支", bars: monthlyBars(), unit: "万円", savingsLabel: "収入")
                    annualSummaryCard
                    if appState.remainingBudget > 0 {
                        CompoundGrowthCard(monthlySaving: appState.remainingBudget)
                    }
                    if !appState.debts.isEmpty {
                        DebtPayoffMotivationCard()
                    }
                    bestWorstMonthCard
                    annualAdviceCard
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - 年間合算カード（リングゲージ）
    private var annualTotalsCard: some View {
        let bars = monthlyBars().filter { !$0.isFuture && $0.value > 0 }
        let totalSaved   = bars.reduce(0) { $0 + $1.saved }
        let protect      = appState.protectActionsTotal
        let grow         = appState.growActionsTotal
        let annualIncome = max(1, appState.monthlyIncome * 12)
        let savedRatio   = min(1.0, Double(totalSaved) / Double(annualIncome))
        let learnRatio   = min(1.0, Double(protect + grow) / 100.0)
        let loginRatio   = min(1.0, Double(appState.consecutiveLoginDays) / 365.0)

        return VStack(spacing: 10) {
            HStack {
                Text("📊 \(currentYear)年の合算")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
            }
            HStack(spacing: 0) {
                MiniRingGauge(
                    emoji: "💰",
                    ratio: savedRatio,
                    color: AppColor.primary,
                    centerText: annualCompact(totalSaved),
                    label: "累計節約額"
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
                    emoji: "🌟",
                    ratio: loginRatio,
                    color: Color(red: 0.95, green: 0.55, blue: 0.10),
                    centerText: "\(appState.consecutiveLoginDays)日",
                    label: "連続ログイン"
                )
            }
        }
        .cardStyle()
    }

    private func annualCompact(_ v: Int) -> String {
        if v >= 10000 {
            let d = Double(v) / 10000.0
            return d.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(d))万" : String(format: "%.1f万", d)
        }
        return v > 0 ? "\(v)円" : "集計中"
    }

    // MARK: - 月別行動棒グラフデータ
    private func monthlyActionBars() -> [ActionStackedBarChart.Bar] {
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let totalProtect = max(12, appState.protectActionsTotal)
        let totalGrow    = max(8,  appState.growActionsTotal)
        let avgP = Double(totalProtect) / Double(currentMonth)
        let avgG = Double(totalGrow)    / Double(currentMonth)
        let pVar: [Double] = [0.5, 0.7, 0.8, 0.9, 1.0, 1.1, 0.85, 0.9, 1.0, 1.15, 1.2, 1.0]
        let gVar: [Double] = [0.4, 0.6, 0.75, 0.85, 0.95, 1.05, 0.80, 0.9, 1.0, 1.1, 1.15, 1.0]
        let labels = ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]

        return (0..<12).map { i in
            let month = i + 1
            let isFuture = month > currentMonth
            let p = isFuture ? 0 : max(0, Int((avgP * pVar[i]).rounded()))
            let g = isFuture ? 0 : max(0, Int((avgG * gVar[i]).rounded()))
            return ActionStackedBarChart.Bar(
                label: labels[i], protectCount: p, growCount: g,
                isCurrentPeriod: month == currentMonth, isFuture: isFuture
            )
        }
    }

    // MARK: - 返済推移ラインチャート（年間）
    private var debtProgressAnnualCard: some View {
        let points: [DebtLineChart.Point] = {
            guard !appState.debts.isEmpty else { return [] }
            let totalDebt      = appState.debts.reduce(0) { $0 + $1.remainingBalance }
            let monthlyPayment = appState.debts.reduce(0) { $0 + $1.monthlyPayment }
            let calendar       = Calendar.current
            let currentMonth   = calendar.component(.month, from: Date())
            let labels = ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]
            return (0..<currentMonth).map { i in
                let remaining = max(0, totalDebt - monthlyPayment * (currentMonth - 1 - i))
                return DebtLineChart.Point(
                    label: labels[i],
                    amount: remaining,
                    isCurrent: (i + 1) == currentMonth
                )
            }
        }()
        return DebtLineChart(title: "返済の推移", points: points)
    }

    // MARK: - 月ごとのバーデータ生成
    private func monthlyBars() -> [ReportBarChart.Bar] {
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let monthlyBudget = max(1, appState.remainingBudget)

        // 月ごとの支出変動率（1月〜12月）
        let variations: [Double] = [1.05, 0.88, 0.92, 0.95, 1.02, 1.10, 0.91, 0.86, 0.97, 1.08, 1.15, 1.20]
        let monthLabels = ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]

        return (0..<12).map { i in
            let month = i + 1
            let isCurrentMonth = month == currentMonth
            let isFuture = month > currentMonth
            let value = isFuture ? 0 : isCurrentMonth
                ? Int(Double(monthlyBudget) * 0.55) // 今月は途中
                : Int(Double(monthlyBudget) * variations[i])

            return ReportBarChart.Bar(
                label: monthLabels[i],
                value: value,
                budget: monthlyBudget,
                isCurrentPeriod: isCurrentMonth,
                isFuture: isFuture
            )
        }
    }

    // MARK: - 年間サマリードーナツ
    private var annualSummaryCard: some View {
        let bars = monthlyBars().filter { !$0.isFuture && $0.value > 0 }
        let totalSpent   = bars.reduce(0) { $0 + $1.value }
        let months       = max(1, bars.count)
        let annualIncome = appState.monthlyIncome * 12
        let projectedSpend = totalSpent * 12 / months
        let projectedSave  = max(0, annualIncome - projectedSpend)

        return ExpenseDonutChart(
            title: "\(currentYear)年 収支見通し",
            slices: [
                ExpenseDonutChart.Slice(label: "支出（推定）", value: projectedSpend, color: AppColor.primary),
                ExpenseDonutChart.Slice(label: "貯蓄（推定）", value: projectedSave,  color: AppColor.secondary)
            ]
        )
    }

    // MARK: - 月別ハイライト スパークライン
    private var bestWorstMonthCard: some View {
        let allBars  = monthlyBars()
        let pastBars = allBars.filter { !$0.isFuture && !$0.isCurrentPeriod && $0.value > 0 }
        let budget   = max(1, appState.remainingBudget)
        let best     = pastBars.min(by: { $0.value < $1.value })
        let worst    = pastBars.max(by: { $0.value < $1.value })
        let maxVal   = max(1, allBars.filter { !$0.isFuture }.map { $0.value }.max() ?? 1)

        return VStack(alignment: .leading, spacing: 14) {
            Text("月別ハイライト")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            // スパークライン
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(allBars) { bar in
                    let isBest  = bar.label == best?.label
                    let isWorst = bar.label == worst?.label
                    let height: CGFloat = bar.isFuture ? 4
                        : max(4, 64 * CGFloat(bar.value) / CGFloat(maxVal))
                    let barColor: Color = bar.isFuture  ? Color.gray.opacity(0.15)
                        : isBest         ? AppColor.secondary
                        : isWorst        ? AppColor.danger
                        : bar.isCurrentPeriod ? AppColor.primary
                        : AppColor.primary.opacity(0.45)

                    VStack(spacing: 2) {
                        if isBest       { Text("🏆").font(.system(size: 8)) }
                        else if isWorst { Text("📌").font(.system(size: 8)) }
                        else            { Color.clear.frame(height: 12) }
                        RoundedRectangle(cornerRadius: 2)
                            .fill(barColor)
                            .frame(width: 16, height: height)
                        Text(bar.label.replacingOccurrences(of: "月", with: ""))
                            .font(.system(size: 8))
                            .foregroundColor(bar.isCurrentPeriod ? AppColor.primary : AppColor.textTertiary)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 16) {
                if let best = best {
                    HStack(spacing: 4) {
                        Text("🏆").font(.system(size: 11))
                        Text("\(best.label) · 節約 \((budget - best.value).yen)")
                            .font(.system(size: 11)).foregroundColor(AppColor.secondary)
                    }
                }
                if let worst = worst, worst.value > budget {
                    HStack(spacing: 4) {
                        Text("📌").font(.system(size: 11))
                        Text("\(worst.label) · 超過 \((worst.value - budget).yen)")
                            .font(.system(size: 11)).foregroundColor(AppColor.danger)
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - アドバイスカード
    private var annualAdviceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("💡").font(.system(size: 18))
                Text("年間を通じたアドバイス")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(AppColor.textSecondary)
            }
            VStack(alignment: .leading, spacing: 8) {
                adviceRow("年間の支出パターンを把握することで、ボーナス月や出費の多い時期を先読みできます。")
                adviceRow("毎月の固定費を1,000円ずつ下げるだけで、年間12,000円の節約になります。")
                adviceRow("来年に向けて、まず「毎月いくら残すか」を決めてから生活設計をするのがおすすめです。")
            }
        }
        .cardStyle()
    }

    private func adviceRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(AppColor.accent).frame(width: 5, height: 5).padding(.top, 6)
            Text(text).font(.system(size: 13)).foregroundColor(AppColor.textPrimary).lineSpacing(3)
        }
    }

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
}

#Preview {
    AnnualReportView()
        .environmentObject({ let s = AppState(); s.loadDemoData(); return s }())
}
