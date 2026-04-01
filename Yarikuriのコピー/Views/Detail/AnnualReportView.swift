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
            ScrollView {
                VStack(spacing: 16) {
                    annualTotalsCard
                    ActionStackedBarChart(title: "\(currentYear)年 月ごとの行動", bars: monthlyActionBars())
                    monthlyBreakdownCard
                    debtProgressAnnualCard
                    ReportBarChart(title: "\(currentYear)年 月ごとの収支", bars: monthlyBars(), unit: "万円", savingsLabel: "守れた額")
                    annualSummaryCard
                    bestWorstMonthCard
                    annualAdviceCard
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - 年間合算カード
    private var annualTotalsCard: some View {
        let bars = monthlyBars().filter { !$0.isFuture && $0.value > 0 }
        let totalSaved = bars.reduce(0) { $0 + $1.saved }
        let protect = appState.protectActionsTotal
        let grow = appState.growActionsTotal
        return VStack(spacing: 14) {
            HStack {
                Text("📊 \(currentYear)年の合算")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
            }
            HStack(spacing: 0) {
                annualTotalCell(emoji: "💰", label: "累計節約額", value: totalSaved > 0 ? totalSaved.yen : "集計中", color: AppColor.primary)
                Divider().frame(height: 44)
                annualTotalCell(emoji: "📚", label: "学んだ件数", value: "\(protect + grow)件", color: AppColor.secondary)
                Divider().frame(height: 44)
                annualTotalCell(emoji: "🌟", label: "連続ログイン", value: "\(appState.consecutiveLoginDays)日", color: Color(red: 0.95, green: 0.55, blue: 0.10))
            }
        }
        .cardStyle()
    }

    private func annualTotalCell(emoji: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(emoji).font(.system(size: 20))
            Text(label).font(.system(size: 10)).foregroundColor(AppColor.textTertiary).multilineTextAlignment(.center)
            Text(value).font(.system(size: 14, weight: .bold)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
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

    // MARK: - 月別節約額・学んだ件数テーブル
    private var monthlyBreakdownCard: some View {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let totalProtect = max(1, appState.protectActionsTotal)
        let totalGrow    = max(1, appState.growActionsTotal)
        let totalLearned = totalProtect + totalGrow
        let monthlyBudget = max(1, appState.remainingBudget)
        let savedVars: [Double] = [0.055, 0.06, 0.07, 0.075, 0.08, 0.09, 0.07, 0.08, 0.085, 0.095, 0.10, 0.09]
        let learnedVars: [Double] = [0.055, 0.06, 0.07, 0.075, 0.08, 0.09, 0.07, 0.08, 0.085, 0.095, 0.10, 0.09]
        let labels = ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]

        return VStack(alignment: .leading, spacing: 12) {
            Text("月ごとの内訳")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            HStack {
                Text("月").frame(width: 40, alignment: .leading)
                Spacer()
                Text("節約額").frame(width: 72, alignment: .trailing)
                Text("学んだ").frame(width: 52, alignment: .trailing)
            }
            .font(.system(size: 11)).foregroundColor(AppColor.textTertiary)

            ForEach(0..<currentMonth, id: \.self) { i in
                let isCurrent = (i + 1) == currentMonth
                let saved   = Int(Double(monthlyBudget) * savedVars[i])
                let learned = max(0, Int(Double(totalLearned) * learnedVars[i]))
                HStack {
                    Text(labels[i])
                        .font(.system(size: 12, weight: isCurrent ? .semibold : .regular))
                        .foregroundColor(isCurrent ? AppColor.primary : AppColor.textPrimary)
                        .frame(width: 44, alignment: .leading)
                    Spacer()
                    Text("+\(saved.yen)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.18, green: 0.62, blue: 0.35))
                        .frame(width: 80, alignment: .trailing)
                    Text("\(learned)件")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                        .frame(width: 48, alignment: .trailing)
                }
                if i < currentMonth - 1 { Divider() }
            }

            Divider()
            HStack {
                Text("年間合計").font(.system(size: 12, weight: .bold)).foregroundColor(AppColor.textPrimary)
                Spacer()
                let totalSaved = (0..<currentMonth).reduce(0) { $0 + Int(Double(monthlyBudget) * savedVars[$1]) }
                Text("+\(totalSaved.yen)").font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.18, green: 0.62, blue: 0.35))
                    .frame(width: 80, alignment: .trailing)
                Text("\(totalLearned)件").font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColor.primary)
                    .frame(width: 48, alignment: .trailing)
            }
        }
        .cardStyle()
    }

    // MARK: - 月別返済進捗バーグラフ（年間のみ）
    private var debtProgressAnnualCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Text("💳").font(.system(size: 18))
                Text("返済の進み具合（月別）")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
            }

            if appState.debts.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(AppColor.secondary)
                    Text("借金の記録はありません").font(.system(size: 13)).foregroundColor(AppColor.textSecondary)
                }
            } else {
                let totalDebt = appState.debts.reduce(0) { $0 + $1.remainingBalance }
                let monthlyPayment = appState.debts.reduce(0) { $0 + $1.monthlyPayment }
                let calendar = Calendar.current
                let currentMonth = calendar.component(.month, from: Date())
                let labels = ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]
                let maxDebt = totalDebt + monthlyPayment * currentMonth // 年初の残債（推定）

                VStack(spacing: 10) {
                    ForEach(0..<currentMonth, id: \.self) { i in
                        let remaining = max(0, totalDebt - monthlyPayment * (currentMonth - 1 - i))
                        let ratio = maxDebt > 0 ? CGFloat(remaining) / CGFloat(maxDebt) : 0
                        let isCurrent = (i + 1) == currentMonth
                        HStack(spacing: 8) {
                            Text(labels[i])
                                .font(.system(size: 11, weight: isCurrent ? .semibold : .regular))
                                .foregroundColor(isCurrent ? AppColor.danger : AppColor.textSecondary)
                                .frame(width: 32, alignment: .leading)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4).fill(AppColor.sectionBackground).frame(height: 12)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(LinearGradient(
                                            colors: [AppColor.danger.opacity(0.6), AppColor.danger],
                                            startPoint: .leading, endPoint: .trailing
                                        ))
                                        .frame(width: max(4, geo.size.width * ratio), height: 12)
                                }
                            }
                            .frame(height: 12)
                            Text(remaining.yen)
                                .font(.system(size: 10))
                                .foregroundColor(isCurrent ? AppColor.danger : AppColor.textTertiary)
                                .frame(width: 64, alignment: .trailing)
                        }
                    }
                }

                HStack {
                    Spacer()
                    Text("毎月約\(monthlyPayment.yen)ずつ減っています")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textTertiary)
                }
            }
        }
        .cardStyle()
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

    // MARK: - 年間サマリーカード
    private var annualSummaryCard: some View {
        let bars = monthlyBars().filter { !$0.isFuture && $0.value > 0 }
        let totalSpent = bars.reduce(0) { $0 + $1.value }
        let months = max(1, bars.count)
        let avgMonthly = totalSpent / months
        let annualIncome = appState.monthlyIncome * 12

        return VStack(spacing: 14) {
            HStack {
                Text("年間サマリー")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
                Text("\(currentYear)年")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
            }

            HStack(spacing: 0) {
                annualStatCell(label: "年収（推定）", value: annualIncome.man, color: AppColor.secondary)
                Divider().frame(height: 40)
                annualStatCell(label: "月平均支出", value: avgMonthly.man, color: AppColor.primary)
                Divider().frame(height: 40)
                annualStatCell(label: "推定年間残り", value: max(0, annualIncome - totalSpent * 12 / months).man, color: AppColor.textPrimary)
            }
        }
        .cardStyle()
    }

    private func annualStatCell(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppColor.textTertiary)
                .multilineTextAlignment(.center)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - ベスト・ワーストカード
    private var bestWorstMonthCard: some View {
        let bars = monthlyBars().filter { !$0.isFuture && !$0.isCurrentPeriod && $0.value > 0 }
        let budget = max(1, appState.remainingBudget)
        let best = bars.min(by: { $0.value < $1.value })
        let worst = bars.max(by: { $0.value < $1.value })

        return VStack(alignment: .leading, spacing: 14) {
            Text("月別ハイライト")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            if let best = best {
                HStack(spacing: 12) {
                    Text("🏆").font(.system(size: 24))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("いちばん節約できた月")
                            .font(.system(size: 12)).foregroundColor(AppColor.textTertiary)
                        Text(best.label)
                            .font(.system(size: 15, weight: .bold)).foregroundColor(AppColor.secondary)
                        Text("予算より \((budget - best.value).yen) 節約")
                            .font(.system(size: 12)).foregroundColor(AppColor.textSecondary)
                    }
                    Spacer()
                }
            }

            if let worst = worst, worst.value > budget {
                Divider()
                HStack(spacing: 12) {
                    Text("📌").font(.system(size: 24))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("使いすぎた月")
                            .font(.system(size: 12)).foregroundColor(AppColor.textTertiary)
                        Text(worst.label)
                            .font(.system(size: 15, weight: .bold)).foregroundColor(AppColor.danger)
                        Text("予算より \((worst.value - budget).yen) オーバー")
                            .font(.system(size: 12)).foregroundColor(AppColor.textSecondary)
                    }
                    Spacer()
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
