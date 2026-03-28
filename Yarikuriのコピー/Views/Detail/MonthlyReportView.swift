import SwiftUI

// MARK: - 月次レポート画面
struct MonthlyReportView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                let report = appState.monthlyReport

                ScrollView {
                    VStack(spacing: 16) {
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
            .navigationTitle("今月のレポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }

    private func monthlySummaryCard(report: MonthlyReport) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("月次サマリー")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
                Text(monthText(report.month))
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
            }

            // 貯蓄率リング
            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(AppColor.sectionBackground, lineWidth: 12)
                        .frame(width: 100, height: 100)
                    Circle()
                        .trim(from: 0, to: CGFloat(report.savingsRate))
                        .stroke(AppColor.secondary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.0), value: report.savingsRate)

                    VStack(spacing: 0) {
                        Text("\(Int(report.savingsRate * 100))%")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppColor.secondary)
                        Text("残り")
                            .font(.system(size: 11))
                            .foregroundColor(AppColor.textTertiary)
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
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            let items: [(String, Int, Color)] = [
                ("固定費", report.totalFixedExpenses, AppColor.primary),
                ("変動費", report.totalVariableExpenses, AppColor.tertiary),
                ("支払い予定", report.totalPayments, AppColor.caution)
            ]

            VStack(spacing: 10) {
                ForEach(items, id: \.0) { item in
                    VStack(spacing: 4) {
                        HStack {
                            Text(item.0)
                                .font(.system(size: 13))
                                .foregroundColor(AppColor.textSecondary)
                            Spacer()
                            Text(item.1.yen)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.textPrimary)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(AppColor.sectionBackground)
                                    .frame(height: 6)
                                let ratio = report.totalIncome > 0
                                    ? min(1.0, Double(item.1) / Double(report.totalIncome)) : 0
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(item.2)
                                    .frame(width: geo.size.width * ratio, height: 6)
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
                Text(report.previousMonthComparison >= 0 ? "📈" : "📉")
                    .font(.system(size: 26))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("先月比")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
                Text(report.previousMonthComparison.yenWithSign)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(report.previousMonthComparison >= 0 ? AppColor.secondary : AppColor.danger)
                Text(report.previousMonthComparison >= 0 ? "節約できました" : "先月より使いました")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textTertiary)
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
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
            }

            ForEach(report.improvementSuggestions, id: \.self) { suggestion in
                HStack(spacing: 8) {
                    Circle()
                        .fill(AppColor.accent)
                        .frame(width: 6, height: 6)
                    Text(suggestion)
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .cardStyle()
    }

    private func monthText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: date)
    }
}

private struct ReportMetricRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
        }
    }
}

#Preview {
    MonthlyReportView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
