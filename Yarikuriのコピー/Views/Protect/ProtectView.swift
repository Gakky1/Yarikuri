import SwiftUI

// MARK: - 守るタブ（固定費・借金ナビ）
struct ProtectView: View {
    @EnvironmentObject var appState: AppState
    @State private var showFixedExpense = false
    @State private var showDebtNavi = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // ページタイトル説明
                    headerCard

                    // 固定費カード
                    fixedExpenseCard

                    // 借金ナビカード
                    if appState.userProfile?.hasDebt == true || !appState.debts.isEmpty {
                        debtNaviCard
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle("守る")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showFixedExpense) {
            FixedExpenseView()
        }
        .sheet(isPresented: $showDebtNavi) {
            DebtNaviView()
        }
    }

    private var headerCard: some View {
        HStack(spacing: 12) {
            Text("🛡️").font(.system(size: 28))
            VStack(alignment: .leading, spacing: 3) {
                Text("毎月出ていくお金を整える")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Text("固定費を見直し、借金をコントロールする")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
            }
        }
        .padding(16)
        .background(AppColor.secondaryLight)
        .cornerRadius(14)
    }

    // MARK: - 固定費カード
    private var fixedExpenseCard: some View {
        Button(action: { showFixedExpense = true }) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("固定費・サブスク整理")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Text("毎月の固定支出を確認・見直す")
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColor.textTertiary)
                }

                HStack(spacing: 12) {
                    fixedStat(label: "固定費合計", value: appState.totalFixedExpenses.yen, color: AppColor.primary)
                    fixedStat(label: "件数", value: "\(appState.fixedExpenses.count)件", color: AppColor.tertiary)

                    let reviewCount = appState.fixedExpenses.filter { $0.isReviewCandidate }.count
                    if reviewCount > 0 {
                        fixedStat(label: "見直し候補", value: "\(reviewCount)件", color: AppColor.caution)
                    }
                }

                // カテゴリバー（サブスク・家賃・保険など）
                if !appState.fixedExpenses.isEmpty {
                    categoryBar
                }
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    private func fixedStat(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption).foregroundColor(AppColor.textTertiary)
            Text(value).font(.system(size: 15, weight: .bold)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(AppColor.sectionBackground)
        .cornerRadius(8)
    }

    private var categoryBar: some View {
        let grouped = Dictionary(grouping: appState.fixedExpenses, by: { $0.category })
        return HStack(spacing: 4) {
            ForEach(FixedExpenseCategory.allCases, id: \.rawValue) { cat in
                if let expenses = grouped[cat], !expenses.isEmpty {
                    let total = expenses.reduce(0) { $0 + $1.amount }
                    let ratio = Double(total) / Double(max(1, appState.totalFixedExpenses))
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(categoryColor(cat))
                            .frame(height: 10)
                            .frame(maxWidth: .infinity)
                        Text(cat.emoji).font(.system(size: 10))
                    }
                    .frame(maxWidth: .infinity * ratio)
                }
            }
        }
        .frame(height: 22)
    }

    private func categoryColor(_ category: FixedExpenseCategory) -> Color {
        switch category {
        case .rent: return AppColor.primary
        case .utilities: return AppColor.tertiary
        case .phone: return AppColor.secondary
        case .insurance: return AppColor.caution
        case .subscription: return Color.purple.opacity(0.6)
        case .loan: return AppColor.danger
        case .gym: return Color.orange.opacity(0.6)
        case .transport: return Color.teal.opacity(0.6)
        case .other: return AppColor.textTertiary
        }
    }

    // MARK: - 借金ナビカード
    private var debtNaviCard: some View {
        Button(action: { showDebtNavi = true }) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("借金・リボ返済ナビ")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Text("返済計画を立てて、少しずつ減らす")
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColor.textTertiary)
                }

                // 借金サマリー
                if !appState.debts.isEmpty {
                    let totalDebt = appState.debts.reduce(0) { $0 + $1.remainingBalance }
                    let totalMonthly = appState.debts.reduce(0) { $0 + $1.monthlyPayment }

                    HStack(spacing: 12) {
                        debtStat(label: "残高合計", value: totalDebt.man, color: AppColor.danger)
                        debtStat(label: "月返済額", value: totalMonthly.yen, color: AppColor.caution)
                        debtStat(label: "件数", value: "\(appState.debts.count)件", color: AppColor.textSecondary)
                    }

                    // 高金利の警告
                    if appState.debts.contains(where: { $0.dangerLevel == .high }) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(AppColor.danger)
                                .font(.system(size: 12))
                            Text("高金利の借金があります。優先返済をおすすめします。")
                                .font(.system(size: 12))
                                .foregroundColor(AppColor.danger)
                        }
                        .padding(10)
                        .background(AppColor.dangerLight)
                        .cornerRadius(8)
                    }
                }
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    private func debtStat(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption).foregroundColor(AppColor.textTertiary)
            Text(value).font(.system(size: 14, weight: .bold)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(AppColor.sectionBackground)
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        ProtectView()
    }
    .environmentObject({
        let s = AppState()
        s.loadDemoData()
        return s
    }())
}
