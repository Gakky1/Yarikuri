import SwiftUI

// MARK: - 週間レポート（1日単位）
struct WeeklyReportView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    var embedded: Bool = false

    var body: some View {
        if embedded {
            scrollContent
        } else {
            NavigationStack {
                scrollContent
                    .navigationTitle("週間レポート")
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
            let report = appState.weeklyReport
            ScrollView {
                VStack(spacing: 16) {
                    weeklyTotalsCard(report: report)
                    ActionStackedBarChart(title: "今週の日ごとの行動", bars: dailyActionBars())
                    WeeklyScoreCard(
                        completedTasks: report.completedTasks,
                        totalTasks: report.totalTasks,
                        learnedActions: report.completedTasks,
                        dailyBudget: appState.dailyBudget
                    )
                    ReportBarChart(title: "今週の日ごとの収支", bars: dailyBars(), unit: "円", savingsLabel: "収入")
                    weekSummaryCard(report: report)
                    highlightsCard(report: report)
                    adviceCard
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - 週間合算カード（リングゲージ）
    private func weeklyTotalsCard(report: WeeklyReport) -> some View {
        let savedRatio  = report.budgetForWeek > 0
            ? max(0, min(1.0, Double(report.savedAmount) / Double(report.budgetForWeek))) : 0
        let taskRatio   = report.totalTasks > 0
            ? Double(report.completedTasks) / Double(report.totalTasks) : 0
        let learnRatio  = min(1.0, Double(report.completedTasks) / 10.0)
        let savedColor  = report.savedAmount >= 0
            ? Color(red: 0.18, green: 0.62, blue: 0.35) : AppColor.danger

        return VStack(spacing: 10) {
            HStack {
                Text("📊 今週の合算")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
                Text("\(report.weekStartDate.monthDay) 〜 \(report.weekEndDate.monthDay)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textTertiary)
            }
            HStack(spacing: 0) {
                MiniRingGauge(
                    emoji: "💰",
                    ratio: savedRatio,
                    color: savedColor,
                    centerText: "\(Int(savedRatio * 100))%",
                    label: "節約率"
                )
                Divider().frame(height: 80)
                MiniRingGauge(
                    emoji: "📚",
                    ratio: learnRatio,
                    color: AppColor.primary,
                    centerText: "\(report.completedTasks)件",
                    label: "学んだ件数"
                )
                Divider().frame(height: 80)
                MiniRingGauge(
                    emoji: "✅",
                    ratio: taskRatio,
                    color: AppColor.secondary,
                    centerText: "\(report.completedTasks)/\(report.totalTasks)",
                    label: "タスク達成"
                )
            }
        }
        .cardStyle()
    }

    // MARK: - 日別行動棒グラフデータ
    private func dailyActionBars() -> [ActionStackedBarChart.Bar] {
        let calendar = Calendar.current
        let today = Date()
        let totalProtect = max(3, appState.protectActionsTotal)
        let totalGrow    = max(2, appState.growActionsTotal)
        let avgP = Double(totalProtect) / 30.0
        let avgG = Double(totalGrow) / 30.0
        let pVar: [Double] = [0.6, 1.2, 0.8, 1.5, 0.5, 1.8, 1.0]
        let gVar: [Double] = [0.4, 0.9, 1.1, 1.3, 0.7, 1.6, 1.0]
        let labels = ["月", "火", "水", "木", "金", "土", "日"]

        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        comps.weekday = 2
        let weekStart = calendar.date(from: comps) ?? today

        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: i, to: weekStart) ?? today
            let isToday = calendar.isDateInToday(date)
            let isFuture = date > today && !isToday
            let p = isFuture ? 0 : max(0, Int((avgP * pVar[i]).rounded()))
            let g = isFuture ? 0 : max(0, Int((avgG * gVar[i]).rounded()))
            return ActionStackedBarChart.Bar(
                label: labels[i],
                protectCount: p, growCount: g,
                isCurrentPeriod: isToday,
                isFuture: isFuture
            )
        }
    }

    // MARK: - 1日ごとのバーデータ生成
    private func dailyBars() -> [ReportBarChart.Bar] {
        let calendar = Calendar.current
        let today = Date()
        let budget = max(1, appState.dailyBudget)
        // 変動率（月〜日）
        let variations: [Double] = [0.82, 1.08, 0.91, 1.15, 0.78, 1.22, 0.95]
        let labels = ["月", "火", "水", "木", "金", "土", "日"]

        // 今週の月曜日を取得
        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        comps.weekday = 2 // 月曜
        let weekStart = calendar.date(from: comps) ?? today

        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: i, to: weekStart) ?? today
            let isToday = calendar.isDateInToday(date)
            let isFuture = date > today && !isToday
            let value = isFuture ? 0 : Int(Double(budget) * variations[i])
            return ReportBarChart.Bar(
                label: labels[i],
                value: value,
                budget: budget,
                isCurrentPeriod: isToday,
                isFuture: isFuture
            )
        }
    }

    // MARK: - 週間収支ドーナツリングカード
    private func weekSummaryCard(report: WeeklyReport) -> some View {
        let budget     = max(1, report.budgetForWeek)
        let saved      = max(0, budget - report.totalSpent)
        let spentCapped = min(report.totalSpent, budget)
        let spentRatio = CGFloat(spentCapped) / CGFloat(budget)
        let savedRatio = CGFloat(saved) / CGFloat(budget)
        let savedGreen = Color(red: 0.18, green: 0.62, blue: 0.35)
        let spentColor: Color = report.isGoodWeek ? AppColor.primary.opacity(0.8) : AppColor.danger

        return VStack(spacing: 14) {
            HStack {
                Text("\(report.weekStartDate.monthDay) 〜 \(report.weekEndDate.monthDay)")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
                Text(report.isGoodWeek ? "✨ 節約できた週" : "😅 使いすぎた週")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(report.isGoodWeek ? AppColor.secondary : AppColor.danger)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(report.isGoodWeek ? AppColor.secondaryLight : AppColor.dangerLight)
                    .cornerRadius(8)
            }

            ZStack {
                Circle()
                    .stroke(AppColor.sectionBackground, lineWidth: 18)
                    .frame(width: 130, height: 130)
                Circle()
                    .trim(from: 0, to: spentRatio)
                    .stroke(spentColor,
                            style: StrokeStyle(lineWidth: 18, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 130, height: 130)
                    .animation(.spring(response: 1.0), value: spentRatio)
                if saved > 0 {
                    Circle()
                        .trim(from: spentRatio, to: spentRatio + savedRatio)
                        .stroke(savedGreen,
                                style: StrokeStyle(lineWidth: 18, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 130, height: 130)
                        .animation(.spring(response: 1.0), value: savedRatio)
                }
                VStack(spacing: 2) {
                    Text(report.isGoodWeek ? "💰 収入" : "😅 超過")
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.textTertiary)
                    Text(report.savedAmount.yenWithSign)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(report.savedAmount >= 0 ? savedGreen : AppColor.danger)
                    Text("予算 \(report.budgetForWeek.yen)")
                        .font(.system(size: 9))
                        .foregroundColor(AppColor.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 20) {
                weekLegendItem(color: spentColor, label: "支出")
                weekLegendItem(color: savedGreen, label: "収入")
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .cardStyle()
    }

    private func weekLegendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 11)).foregroundColor(AppColor.textSecondary)
        }
    }

    private func highlightsCard(report: WeeklyReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今週の良かったこと")
                .font(.system(size: 14, weight: .semibold)).foregroundColor(AppColor.textSecondary)
            ForEach(report.highlights, id: \.self) { h in
                HStack(spacing: 8) {
                    Image(systemName: "star.fill").foregroundColor(AppColor.accent).font(.system(size: 12))
                    Text(h).font(.system(size: 14)).foregroundColor(AppColor.textPrimary)
                }
            }
        }
        .cardStyle()
    }

    private var adviceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🌱").font(.system(size: 20))
                Text("来週へのヒント")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(AppColor.textSecondary)
            }
            Text("固定費の見直しを1件でも進めると、来月から自動的に余裕が生まれます。今週確認した候補を1つ試してみましょう。")
                .font(.system(size: 14)).foregroundColor(AppColor.textPrimary).lineSpacing(3)
        }
        .cardStyle()
        .background(AppColor.secondaryLight)
        .cornerRadius(14)
    }
}

#Preview {
    WeeklyReportView()
        .environmentObject({ let s = AppState(); s.loadDemoData(); return s }())
}
