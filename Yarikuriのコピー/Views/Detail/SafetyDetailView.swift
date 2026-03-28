import SwiftUI

// MARK: - 安全度詳細画面
struct SafetyDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 今月サマリーカード
                        summaryCard

                        // 内訳カード
                        breakdownCard

                        // 危険日予測カード
                        dangerDayCard

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("お金の状況")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }

    // MARK: - サマリーカード
    private var summaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今月のサマリー")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
                Text(monthText)
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
            }

            // 大きな残予算表示
            VStack(spacing: 6) {
                Text("残予算")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
                Text(appState.remainingBudget.yen)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.safetyColor(ratio: appState.safetyRatio))

                // 詳細数字
                HStack(spacing: 20) {
                    DetailMetric(label: "給料日まで", value: "\(appState.daysToPayday)日")
                    DetailMetric(label: "1日の目安", value: appState.dailyBudget.yen)
                }
                .padding(.top, 4)
            }
        }
        .cardStyle()
    }

    // MARK: - 内訳カード
    private var breakdownCard: some View {
        VStack(spacing: 14) {
            HStack {
                Text("今月の内訳")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
            }

            VStack(spacing: 10) {
                BreakdownRow(label: "今月の手取り", value: appState.monthlyIncome.yen, isIncome: true)
                BreakdownRow(label: "固定費合計", value: "- \(appState.totalFixedExpenses.yen)", isDeduction: true)
                BreakdownRow(label: "支払い予定合計", value: "- \(appState.totalScheduledPayments.yen)", isDeduction: true)

                Divider()

                BreakdownRow(label: "変動費として使える額", value: appState.remainingBudget.yen, isTotal: true)
            }
        }
        .cardStyle()
    }

    // MARK: - 危険日予測カード
    private var dangerDayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("先月との比較")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("先月比")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textTertiary)
                    Text("+3,500円の節約")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColor.secondary)
                }
                Spacer()
                Text("📈")
                    .font(.system(size: 32))
            }

            Text("固定費の見直しが効いています。この調子で続けましょう！")
                .font(.system(size: 13))
                .foregroundColor(AppColor.textSecondary)
                .padding(.top, 4)
        }
        .cardStyle()
    }

    private var monthText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: Date())
    }
}

// MARK: - 共通コンポーネント
private struct DetailMetric: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppColor.textTertiary)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColor.textPrimary)
        }
    }
}

private struct BreakdownRow: View {
    let label: String
    let value: String
    var isIncome = false
    var isDeduction = false
    var isTotal = false

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: isTotal ? .semibold : .regular))
                .foregroundColor(isTotal ? AppColor.textPrimary : AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: isTotal ? .bold : .semibold))
                .foregroundColor(isIncome ? AppColor.secondary : isTotal ? AppColor.primary : AppColor.textPrimary)
        }
    }
}

#Preview {
    SafetyDetailView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
