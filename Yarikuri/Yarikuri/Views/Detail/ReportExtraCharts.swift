import SwiftUI

// MARK: - BudgetFlowCard
/// 今月のお金の流れを横積み上げバーで表示
struct BudgetFlowCard: View {
    let income: Int
    let fixedExpenses: Int
    let debtPayments: Int
    let scheduledPayments: Int
    let remaining: Int

    @State private var appeared = false

    private let fixedColor    = Color(red: 0.60, green: 0.45, blue: 0.80)  // purple
    private let debtColor     = Color(red: 0.91, green: 0.45, blue: 0.45)  // red
    private let scheduledColor = Color(red: 0.96, green: 0.65, blue: 0.30) // orange
    private let remainColor   = Color(red: 0.18, green: 0.62, blue: 0.35)  // green

    private var total: Int {
        max(1, fixedExpenses + debtPayments + scheduledPayments + max(0, remaining))
    }

    private var fixedRatio: CGFloat      { CGFloat(fixedExpenses)     / CGFloat(total) }
    private var debtRatio: CGFloat       { CGFloat(debtPayments)      / CGFloat(total) }
    private var scheduledRatio: CGFloat  { CGFloat(scheduledPayments) / CGFloat(total) }
    private var remainRatio: CGFloat     { CGFloat(max(0, remaining)) / CGFloat(total) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("💸 今月のお金の流れ")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            // 横積み上げバー
            GeometryReader { geo in
                let w = geo.size.width
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(fixedColor)
                        .frame(width: appeared ? w * fixedRatio : 0)
                    RoundedRectangle(cornerRadius: 0)
                        .fill(debtColor)
                        .frame(width: appeared ? w * debtRatio : 0)
                    RoundedRectangle(cornerRadius: 0)
                        .fill(scheduledColor)
                        .frame(width: appeared ? w * scheduledRatio : 0)
                    RoundedRectangle(cornerRadius: 0)
                        .fill(remainColor)
                        .frame(width: appeared ? w * remainRatio : 0)
                    Spacer(minLength: 0)
                }
                .frame(height: 22)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .animation(.spring(response: 1.0), value: appeared)
            }
            .frame(height: 22)

            // 2x2グリッド
            let incomeBase = max(1, income)
            let items: [(String, Color, Int)] = [
                ("固定費", fixedColor, fixedExpenses),
                ("借金返済", debtColor, debtPayments),
                ("支払い予定", scheduledColor, scheduledPayments),
                ("残予算", remainColor, max(0, remaining))
            ]
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(items, id: \.0) { label, color, amount in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(label)
                                .font(.system(size: 11))
                                .foregroundColor(AppColor.textSecondary)
                            Text(amount.yen)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppColor.textPrimary)
                            let pct = Int(Double(amount) / Double(incomeBase) * 100)
                            Text("\(pct)%")
                                .font(.system(size: 10))
                                .foregroundColor(color)
                        }
                        Spacer()
                    }
                }
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.spring(response: 1.0)) {
                appeared = true
            }
        }
    }
}

// MARK: - SavingsProjectionCard
/// 6ヶ月の貯蓄シミュレーションを縦バーで表示
struct SavingsProjectionCard: View {
    let monthlySaving: Int
    var goalAmount: Int = 0

    @State private var appeared = false

    private let barColor = Color(red: 0.18, green: 0.62, blue: 0.35)
    private let goalColor = Color(red: 0.96, green: 0.65, blue: 0.30)
    private let chartHeight: CGFloat = 120

    private var projectedValues: [Int] {
        (1...6).map { monthlySaving * $0 }
    }

    private var maxValue: Int {
        let vals = projectedValues
        let maxProj = vals.max() ?? 1
        if goalAmount > 0 { return max(maxProj, goalAmount) }
        return max(1, maxProj)
    }

    private var goalReachedMonth: Int? {
        guard goalAmount > 0 else { return nil }
        return projectedValues.firstIndex(where: { $0 >= goalAmount }).map { $0 + 1 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("📈 貯蓄シミュレーション（6ヶ月）")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            GeometryReader { geo in
                let w = geo.size.width
                let barWidth = (w - 5 * 8) / 6
                let maxV = CGFloat(maxValue)

                ZStack(alignment: .bottomLeading) {
                    // Goal line
                    if goalAmount > 0 {
                        let goalY = chartHeight * (1 - CGFloat(goalAmount) / maxV)
                        Path { path in
                            var x: CGFloat = 0
                            while x < w {
                                path.move(to: CGPoint(x: x, y: goalY))
                                path.addLine(to: CGPoint(x: x + 6, y: goalY))
                                x += 10
                            }
                        }
                        .stroke(goalColor, style: StrokeStyle(lineWidth: 1.5))

                        Text("目標 \(goalAmount.yen)")
                            .font(.system(size: 9))
                            .foregroundColor(goalColor)
                            .position(x: w - 36, y: goalY - 8)
                    }

                    // Bars
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(0..<6, id: \.self) { i in
                            let val = projectedValues[i]
                            let ratio = CGFloat(val) / maxV
                            let isGoalMonth = goalReachedMonth == i + 1
                            let color = isGoalMonth ? goalColor : barColor

                            VStack(spacing: 2) {
                                Text("\(i + 1)ヶ月後")
                                    .font(.system(size: 7))
                                    .foregroundColor(AppColor.textTertiary)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(color.opacity(isGoalMonth ? 1.0 : 0.8))
                                    .frame(
                                        width: barWidth,
                                        height: appeared ? max(4, chartHeight * ratio) : 0
                                    )
                                    .animation(
                                        .spring(response: 0.7).delay(Double(i) * 0.08),
                                        value: appeared
                                    )
                            }
                        }
                    }
                    .frame(height: chartHeight + 16, alignment: .bottom)
                }
                .frame(height: chartHeight + 16)
            }
            .frame(height: chartHeight + 24)

            if monthlySaving > 0 {
                let sixMonthTotal = monthlySaving * 6
                let man = sixMonthTotal / 10000
                let motivationText = man > 0
                    ? "このペースなら6ヶ月で\(man)万円！"
                    : "このペースなら6ヶ月で\(sixMonthTotal.yen)！"
                Text(motivationText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(barColor)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.spring(response: 1.0)) {
                appeared = true
            }
        }
    }
}

// MARK: - CompoundGrowthCard
/// 複利効果を3本の折れ線グラフで表示（最もエキサイティングなチャート）
struct CompoundGrowthCard: View {
    let monthlySaving: Int

    @State private var appeared = false

    private let chartHeight: CGFloat = 160
    private let yearPoints = [1, 2, 3, 5, 10]
    private let yearLabels = ["1年", "2年", "3年", "5年", "10年"]

    // Rate colors
    private let flatColor  = Color(red: 0.65, green: 0.65, blue: 0.65)   // gray
    private let rate1Color = Color(red: 0.35, green: 0.55, blue: 0.90)   // blue
    private let rate3Color = Color(red: 0.18, green: 0.62, blue: 0.35)   // green
    private let rate5Color = Color(red: 0.93, green: 0.73, blue: 0.20)   // gold

    private func futureValue(monthly: Int, annualRate: Double, years: Int) -> Double {
        let months = years * 12
        if annualRate == 0 {
            return Double(monthly * months)
        }
        let r = annualRate / 12.0
        return Double(monthly) * (pow(1 + r, Double(months)) - 1) / r
    }

    private var allValues: [Double] {
        yearPoints.flatMap { y in
            [0.0, 0.01, 0.03, 0.05].map { rate in
                futureValue(monthly: monthlySaving, annualRate: rate, years: y)
            }
        }
    }

    private var maxValue: Double {
        max(1, allValues.max() ?? 1)
    }

    private func yPos(value: Double, height: CGFloat) -> CGFloat {
        height * (1 - CGFloat(value / maxValue))
    }

    private func linePath(rate: Double, width: CGFloat, height: CGFloat) -> Path {
        Path { path in
            let xStep = width / CGFloat(yearPoints.count - 1)
            for (i, y) in yearPoints.enumerated() {
                let val = futureValue(monthly: monthlySaving, annualRate: rate, years: y)
                let pt = CGPoint(x: CGFloat(i) * xStep, y: yPos(value: val, height: height))
                if i == 0 { path.move(to: pt) }
                else { path.addLine(to: pt) }
            }
        }
    }

    private func areaPath5(width: CGFloat, height: CGFloat) -> Path {
        Path { path in
            let xStep = width / CGFloat(yearPoints.count - 1)
            // flat line bottom
            let flatPts = yearPoints.map { y -> CGPoint in
                let val = futureValue(monthly: monthlySaving, annualRate: 0, years: y)
                return CGPoint(x: CGFloat(yearPoints.firstIndex(of: y)!) * xStep, y: yPos(value: val, height: height))
            }
            // 5% line top
            let rate5Pts = yearPoints.map { y -> CGPoint in
                let val = futureValue(monthly: monthlySaving, annualRate: 0.05, years: y)
                return CGPoint(x: CGFloat(yearPoints.firstIndex(of: y)!) * xStep, y: yPos(value: val, height: height))
            }

            // Start from first flat point
            path.move(to: flatPts[0])
            for pt in flatPts.dropFirst() { path.addLine(to: pt) }
            // Go up through rate5 in reverse
            for pt in rate5Pts.reversed() { path.addLine(to: pt) }
            path.closeSubpath()
        }
    }

    private func compactYen(_ v: Double) -> String {
        let i = Int(v)
        if i >= 100_000_000 {
            return String(format: "%.0f億", Double(i) / 100_000_000)
        } else if i >= 10_000 {
            let man = Double(i) / 10_000.0
            return man.truncatingRemainder(dividingBy: 1) == 0
                ? "\(Int(man))万円"
                : String(format: "%.1f万円", man)
        }
        return "\(i)円"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("🚀 資産シミュレーション（複利効果）")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Text("毎月\(monthlySaving.yen)を積み立てた場合")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textTertiary)
            }

            GeometryReader { geo in
                let w = geo.size.width
                let h = chartHeight

                ZStack(alignment: .topLeading) {
                    // グリッド線
                    ForEach([0.25, 0.5, 0.75], id: \.self) { ratio in
                        Path { path in
                            let y = h * CGFloat(ratio)
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: w, y: y))
                        }
                        .stroke(Color.gray.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    }

                    // 5%エリア塗りつぶし
                    areaPath5(width: w, height: h)
                        .fill(
                            LinearGradient(
                                colors: [rate5Color.opacity(0.25), rate5Color.opacity(0.03)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeIn(duration: 0.5).delay(0.8), value: appeared)

                    // 各折れ線
                    Group {
                        linePath(rate: 0.0, width: w, height: h)
                            .trim(from: 0, to: appeared ? 1 : 0)
                            .stroke(flatColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 4]))
                            .animation(.easeInOut(duration: 1.0).delay(0.1), value: appeared)

                        linePath(rate: 0.01, width: w, height: h)
                            .trim(from: 0, to: appeared ? 1 : 0)
                            .stroke(rate1Color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .animation(.easeInOut(duration: 1.0).delay(0.2), value: appeared)

                        linePath(rate: 0.03, width: w, height: h)
                            .trim(from: 0, to: appeared ? 1 : 0)
                            .stroke(rate3Color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                            .animation(.easeInOut(duration: 1.0).delay(0.3), value: appeared)

                        linePath(rate: 0.05, width: w, height: h)
                            .trim(from: 0, to: appeared ? 1 : 0)
                            .stroke(rate5Color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .animation(.easeInOut(duration: 1.0).delay(0.4), value: appeared)
                    }

                    // 10年後コールアウト
                    let val10y5 = futureValue(monthly: monthlySaving, annualRate: 0.05, years: 10)
                    let calloutX = w
                    let calloutY = yPos(value: val10y5, height: h) - 28
                    Text(compactYen(val10y5))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(rate5Color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(rate5Color.opacity(0.15))
                        .cornerRadius(6)
                        .position(x: calloutX - 28, y: max(16, calloutY))
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeIn.delay(1.1), value: appeared)
                }
                .frame(height: h)
            }
            .frame(height: chartHeight)

            // X軸ラベル
            HStack(spacing: 0) {
                ForEach(yearLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // 凡例
            HStack(spacing: 12) {
                legendItem(color: flatColor, label: "元本のみ", dashed: true)
                legendItem(color: rate1Color, label: "年利1%")
                legendItem(color: rate3Color, label: "年利3%")
                legendItem(color: rate5Color, label: "年利5%")
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.spring(response: 1.0)) {
                appeared = true
            }
        }
    }

    private func legendItem(color: Color, label: String, dashed: Bool = false) -> some View {
        HStack(spacing: 4) {
            if dashed {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 4))
                    path.addLine(to: CGPoint(x: 14, y: 4))
                }
                .stroke(color, style: StrokeStyle(lineWidth: 1.5, dash: [3, 2]))
                .frame(width: 14, height: 8)
            } else {
                RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 14, height: 3)
            }
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(AppColor.textTertiary)
        }
    }
}

// MARK: - WeeklyScoreCard
/// 今週のスコアを円形ゲージで表示
struct WeeklyScoreCard: View {
    let completedTasks: Int
    let totalTasks: Int
    let learnedActions: Int
    let dailyBudget: Int

    @State private var appeared = false

    private var taskScore: Int {
        guard totalTasks > 0 else { return 0 }
        return min(40, Int(Double(completedTasks) / Double(totalTasks) * 40))
    }

    private var learnScore: Int {
        min(30, Int(Double(learnedActions) / 5.0 * 30))
    }

    private var budgetScore: Int {
        dailyBudget > 0 ? 30 : 0
    }

    private var totalScore: Int {
        taskScore + learnScore + budgetScore
    }

    private var scoreColor: Color {
        if totalScore >= 80 { return Color(red: 0.18, green: 0.62, blue: 0.35) }
        if totalScore >= 60 { return AppColor.caution }
        return AppColor.danger
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("🎯 今週のスコア")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
            }

            // 円形ゲージ
            ZStack {
                Circle()
                    .stroke(AppColor.sectionBackground, lineWidth: 20)
                    .frame(width: 110, height: 110)
                Circle()
                    .trim(from: 0, to: appeared ? CGFloat(totalScore) / 100.0 : 0)
                    .stroke(
                        scoreColor,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 110, height: 110)
                    .animation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.1), value: appeared)

                VStack(spacing: 0) {
                    Text("\(totalScore)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(scoreColor)
                    Text("/ 100")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // 3行の達成項目
            VStack(spacing: 8) {
                achievementRow(
                    achieved: completedTasks > 0,
                    label: "タスクを達成した",
                    detail: "\(completedTasks)/\(totalTasks)件"
                )
                achievementRow(
                    achieved: learnedActions >= 3,
                    label: "行動を学んだ",
                    detail: "\(learnedActions)件"
                )
                achievementRow(
                    achieved: dailyBudget > 0,
                    label: "予算内に収まっている",
                    detail: dailyBudget > 0 ? "1日\(dailyBudget.yen)" : "予算設定なし"
                )
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.spring(response: 1.0)) {
                appeared = true
            }
        }
    }

    private func achievementRow(achieved: Bool, label: String, detail: String) -> some View {
        HStack(spacing: 10) {
            Text(achieved ? "✅" : "🔲")
                .font(.system(size: 14))
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(AppColor.textPrimary)
            Spacer()
            Text(detail)
                .font(.system(size: 12))
                .foregroundColor(AppColor.textTertiary)
        }
    }
}

// MARK: - DebtPayoffMotivationCard
/// 借金完済カウントダウンカード
struct DebtPayoffMotivationCard: View {
    @EnvironmentObject var appState: AppState

    @State private var appeared = false

    private var totalRemaining: Int {
        appState.debts.reduce(0) { $0 + $1.remainingBalance }
    }

    private var totalMonthlyPayment: Int {
        appState.debts.reduce(0) { $0 + $1.monthlyPayment }
    }

    private var estimatedMonthsToPayoff: Int {
        guard totalMonthlyPayment > 0 else { return 0 }
        return Int(ceil(Double(totalRemaining) / Double(totalMonthlyPayment)))
    }

    private func progressRatio(for debt: Debt) -> Double {
        guard let months = debt.estimatedMonthsToPayoff, months > 0 else { return 0 }
        let total = debt.remainingBalance + debt.monthlyPayment * months
        guard total > 0 else { return 0 }
        let paid = total - debt.remainingBalance
        return min(1.0, max(0, Double(paid) / Double(total)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("💳 借金完済カウントダウン")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
            }

            // 残高合計（大きな数字）
            VStack(spacing: 2) {
                Text("残り総額")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textTertiary)
                Text(totalRemaining.yen)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColor.danger)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // 各借金のプログレスバー（最大3件）
            ForEach(appState.debts.prefix(3)) { debt in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(debt.debtType.emoji).font(.system(size: 12))
                        Text(debt.lenderName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
                        Text("残\(debt.remainingBalance.yen)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColor.danger)
                    }

                    GeometryReader { geo in
                        let ratio = progressRatio(for: debt)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColor.sectionBackground)
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [AppColor.caution.opacity(0.7), AppColor.caution],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: appeared
                                        ? max(4, geo.size.width * CGFloat(ratio))
                                        : 0,
                                    height: 8
                                )
                                .animation(.spring(response: 1.0).delay(0.2), value: appeared)
                        }
                    }
                    .frame(height: 8)
                }
            }

            Divider()

            // 完済後の自由額
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("完済後は毎月")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                    Text(totalMonthlyPayment.yen + "が自由に！")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.18, green: 0.62, blue: 0.35))
                }
                Spacer()
                if estimatedMonthsToPayoff > 0 {
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("完済まであと推定")
                            .font(.system(size: 10))
                            .foregroundColor(AppColor.textTertiary)
                        let years = estimatedMonthsToPayoff / 12
                        let months = estimatedMonthsToPayoff % 12
                        let label = years > 0
                            ? (months > 0 ? "\(years)年\(months)ヶ月" : "\(years)年")
                            : "\(months)ヶ月"
                        Text(label)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                    }
                }
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.spring(response: 1.0)) {
                appeared = true
            }
        }
    }
}
