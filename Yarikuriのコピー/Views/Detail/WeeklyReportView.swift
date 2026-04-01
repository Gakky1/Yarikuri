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
            let report = appState.weeklyReport
            ScrollView {
                VStack(spacing: 16) {
                    weeklyTotalsCard(report: report)
                    ActionStackedBarChart(title: "今週の日ごとの行動", bars: dailyActionBars())
                    dailyBreakdownCard(report: report)
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

    // MARK: - 週間合算カード
    private func weeklyTotalsCard(report: WeeklyReport) -> some View {
        VStack(spacing: 14) {
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
                weekTotalCell(emoji: "💰", label: "節約できた額",
                              value: report.savedAmount >= 0 ? "+\(report.savedAmount.yen)" : report.savedAmount.yen,
                              color: report.savedAmount >= 0 ? Color(red: 0.18, green: 0.62, blue: 0.35) : AppColor.danger)
                Divider().frame(height: 44)
                weekTotalCell(emoji: "📚", label: "学んだ件数",
                              value: "\(report.completedTasks)件",
                              color: AppColor.primary)
                Divider().frame(height: 44)
                weekTotalCell(emoji: "✅", label: "タスク達成",
                              value: "\(report.completedTasks)/\(report.totalTasks)",
                              color: AppColor.secondary)
            }
        }
        .cardStyle()
    }

    private func weekTotalCell(emoji: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(emoji).font(.system(size: 20))
            Text(label).font(.system(size: 10)).foregroundColor(AppColor.textTertiary).multilineTextAlignment(.center)
            Text(value).font(.system(size: 14, weight: .bold)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
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

    // MARK: - 日別節約額・学んだ件数テーブル
    private func dailyBreakdownCard(report: WeeklyReport) -> some View {
        let totalSaved   = max(0, report.savedAmount)
        let totalLearned = report.completedTasks
        let savedVars: [Double]   = [0.12, 0.18, 0.14, 0.22, 0.16, 0.10, 0.08]
        let learnedVars: [Double] = [0.12, 0.18, 0.14, 0.22, 0.16, 0.10, 0.08]
        let labels = ["月曜", "火曜", "水曜", "木曜", "金曜", "土曜", "日曜"]
        let calendar = Calendar.current
        let today = Date()

        return VStack(alignment: .leading, spacing: 12) {
            Text("日ごとの内訳")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            HStack {
                Text("曜日").frame(width: 40, alignment: .leading)
                Spacer()
                Text("節約額").frame(width: 72, alignment: .trailing)
                Text("学んだ").frame(width: 56, alignment: .trailing)
            }
            .font(.system(size: 11)).foregroundColor(AppColor.textTertiary)

            ForEach(0..<7) { i in
                let weekStart2: Date = {
                    var comps2 = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
                    comps2.weekday = 2
                    return calendar.date(from: comps2) ?? today
                }()
                let date = calendar.date(byAdding: .day, value: i, to: weekStart2) ?? today
                let isToday2  = calendar.isDateInToday(date)
                let isFuture2 = date > today && !isToday2
                let saved   = isFuture2 ? 0 : Int(Double(totalSaved)   * savedVars[i])
                let learned = isFuture2 ? 0 : Int(Double(totalLearned) * learnedVars[i])
                HStack {
                    Text(labels[i])
                        .font(.system(size: 12, weight: isToday2 ? .semibold : .regular))
                        .foregroundColor(isToday2 ? AppColor.primary : (isFuture2 ? AppColor.textTertiary : AppColor.textPrimary))
                        .frame(width: 44, alignment: .leading)
                    Spacer()
                    Text(isFuture2 ? "---" : "+\(saved.yen)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isFuture2 ? AppColor.textTertiary : Color(red: 0.18, green: 0.62, blue: 0.35))
                        .frame(width: 80, alignment: .trailing)
                    Text(isFuture2 ? "---" : "\(learned)件")
                        .font(.system(size: 12))
                        .foregroundColor(isFuture2 ? AppColor.textTertiary : AppColor.textSecondary)
                        .frame(width: 44, alignment: .trailing)
                }
                if i < 6 { Divider() }
            }

            Divider()
            HStack {
                Text("週間合計").font(.system(size: 12, weight: .bold)).foregroundColor(AppColor.textPrimary)
                Spacer()
                Text(totalSaved > 0 ? "+\(totalSaved.yen)" : "¥0")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.18, green: 0.62, blue: 0.35))
                    .frame(width: 80, alignment: .trailing)
                Text("\(totalLearned)件")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColor.primary)
                    .frame(width: 44, alignment: .trailing)
            }
        }
        .cardStyle()
    }

    // MARK: - 1日ごとのバーデータ生成（既存）
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

    // MARK: - 既存カード
    private func weekSummaryCard(report: WeeklyReport) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(report.weekStartDate.monthDay) 〜 \(report.weekEndDate.monthDay)")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
                Text(report.isGoodWeek ? "✨ 節約できた週" : "😅 使いすぎた週")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(report.isGoodWeek ? AppColor.secondary : AppColor.danger)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(report.isGoodWeek ? AppColor.secondaryLight : AppColor.dangerLight)
                    .cornerRadius(8)
            }

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("今週の予算").font(.caption).foregroundColor(AppColor.textTertiary)
                    Text(report.budgetForWeek.yen)
                        .font(.system(size: 18, weight: .bold)).foregroundColor(AppColor.textPrimary)
                }
                Text("→").foregroundColor(AppColor.textTertiary)
                VStack(spacing: 4) {
                    Text("実際に使った").font(.caption).foregroundColor(AppColor.textTertiary)
                    Text(report.totalSpent.yen)
                        .font(.system(size: 18, weight: .bold)).foregroundColor(AppColor.primary)
                }
                Text("=").foregroundColor(AppColor.textTertiary)
                VStack(spacing: 4) {
                    Text("💰 守れた").font(.caption).foregroundColor(AppColor.textTertiary)
                    Text(report.savedAmount.yenWithSign)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(report.savedAmount >= 0 ? Color(red: 0.18, green: 0.62, blue: 0.35) : AppColor.danger)
                }
            }
        }
        .cardStyle()
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
