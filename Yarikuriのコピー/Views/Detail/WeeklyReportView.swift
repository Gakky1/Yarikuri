import SwiftUI

// MARK: - 週次レポート画面
struct WeeklyReportView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                let report = appState.weeklyReport

                ScrollView {
                    VStack(spacing: 16) {
                        // 週サマリーカード
                        weekSummaryCard(report: report)

                        // 節約バー
                        savingsBarCard(report: report)

                        // タスク達成状況
                        taskProgressCard(report: report)

                        // 今週の良かったこと
                        highlightsCard(report: report)

                        // 来週へのアドバイス
                        adviceCard

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("今週のレポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }

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
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColor.textPrimary)
                }
                Text("→").foregroundColor(AppColor.textTertiary)
                VStack(spacing: 4) {
                    Text("実際に使った").font(.caption).foregroundColor(AppColor.textTertiary)
                    Text(report.totalSpent.yen)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColor.primary)
                }
                Text("=").foregroundColor(AppColor.textTertiary)
                VStack(spacing: 4) {
                    Text("節約").font(.caption).foregroundColor(AppColor.textTertiary)
                    Text(report.savedAmount.yenWithSign)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(report.savedAmount >= 0 ? AppColor.secondary : AppColor.danger)
                }
            }
        }
        .cardStyle()
    }

    private func savingsBarCard(report: WeeklyReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("予算の使い方")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            let ratio = min(1.0, max(0, Double(report.totalSpent) / Double(report.budgetForWeek)))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColor.sectionBackground)
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(ratio > 0.9 ? AppColor.danger : ratio > 0.7 ? AppColor.caution : AppColor.secondary)
                        .frame(width: geo.size.width * ratio, height: 20)
                        .animation(.spring(response: 0.6), value: ratio)

                    Text("\(Int(ratio * 100))%使用")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                }
            }
            .frame(height: 20)

            HStack {
                Text("0円")
                Spacer()
                Text(report.budgetForWeek.yen)
            }
            .font(.system(size: 11))
            .foregroundColor(AppColor.textTertiary)
        }
        .cardStyle()
    }

    private func taskProgressCard(report: WeeklyReport) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColor.primaryLight)
                    .frame(width: 52, height: 52)
                Text("✅").font(.system(size: 24))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("タスク達成状況")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Text("\(report.completedTasks) / \(report.totalTasks)件完了")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColor.primary)
            }
            Spacer()
        }
        .cardStyle()
    }

    private func highlightsCard(report: WeeklyReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今週の良かったこと")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            ForEach(report.highlights, id: \.self) { highlight in
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColor.accent)
                        .font(.system(size: 12))
                    Text(highlight)
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textPrimary)
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
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
            }

            Text("固定費の見直しを1件でも進めると、来月から自動的に余裕が生まれます。今週確認した候補を1つ試してみましょう。")
                .font(.system(size: 14))
                .foregroundColor(AppColor.textPrimary)
                .lineSpacing(3)
        }
        .cardStyle()
        .background(AppColor.secondaryLight)
        .cornerRadius(14)
    }
}

#Preview {
    WeeklyReportView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
