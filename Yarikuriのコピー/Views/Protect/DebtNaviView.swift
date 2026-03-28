import SwiftUI

// MARK: - 借金・リボ返済ナビ画面
struct DebtNaviView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showAddDebt = false
    @State private var newName = ""
    @State private var newBalance = ""
    @State private var newMonthly = ""
    @State private var newRate = ""
    @State private var newType: DebtType = .other
    @State private var newPaymentDay: Int = 27

    // 優先度順（金利高い順）でソート
    private var sortedDebts: [Debt] {
        appState.debts.sorted { $0.priorityScore > $1.priorityScore }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        if appState.debts.isEmpty {
                            emptyState
                        } else {
                            // 合計カード
                            totalDebtCard

                            // 返済優先度
                            priorityExplanation

                            // 借金リスト（優先度順）
                            ForEach(Array(sortedDebts.enumerated()), id: \.1.id) { index, debt in
                                DebtDetailCard(debt: debt, priority: index + 1)
                            }

                            // 完済目標カード
                            payoffGoalCard
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("借金・リボ返済ナビ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddDebt = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppColor.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddDebt) {
                addDebtSheet
            }
        }
    }

    // MARK: - 空状態
    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("✨").font(.system(size: 52))
            Text("借金はゼロです！")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColor.textPrimary)
            Text("この状態をキープしましょう。\nもし借金が増えた場合は右上の＋から入力できます。")
                .font(.system(size: 14))
                .foregroundColor(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .cardStyle()
    }

    // MARK: - 合計カード
    private var totalDebtCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("借金残高合計").font(.system(size: 13)).foregroundColor(AppColor.textSecondary)
                    let total = appState.debts.reduce(0) { $0 + $1.remainingBalance }
                    Text(total.yen)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColor.danger)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("月返済額").font(.system(size: 12)).foregroundColor(AppColor.textTertiary)
                    let monthly = appState.debts.reduce(0) { $0 + $1.monthlyPayment }
                    Text(monthly.yen)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColor.caution)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - 優先度説明
    private var priorityExplanation: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(AppColor.tertiary)
                .font(.system(size: 14))
            Text("金利が高いものを優先して返すと、利息の節約になります")
                .font(.system(size: 13))
                .foregroundColor(AppColor.textSecondary)
        }
        .padding(12)
        .background(AppColor.tertiaryLight)
        .cornerRadius(10)
    }

    // MARK: - 完済目標カード
    private var payoffGoalCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("💭 返済が終わったら...")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            let monthlyTotal = appState.debts.reduce(0) { $0 + $1.monthlyPayment }
            Text("毎月\(monthlyTotal.yen)が自由になります。\n返済が完了したら貯金に回しましょう。")
                .font(.system(size: 14))
                .foregroundColor(AppColor.textPrimary)
                .lineSpacing(3)
        }
        .cardStyle()
        .background(AppColor.secondaryLight)
        .cornerRadius(14)
    }

    // MARK: - 追加シート
    private var addDebtSheet: some View {
        NavigationStack {
            Form {
                Section("借入先") {
                    TextField("例: ○○カード、消費者金融A", text: $newName)
                    Picker("種類", selection: $newType) {
                        ForEach(DebtType.allCases, id: \.rawValue) { type in
                            Text("\(type.emoji) \(type.displayText)").tag(type)
                        }
                    }
                }
                Section("金額") {
                    TextField("残高（円）", text: $newBalance).keyboardType(.numberPad)
                    TextField("毎月の返済額（円）", text: $newMonthly).keyboardType(.numberPad)
                    TextField("金利（%、任意）", text: $newRate).keyboardType(.decimalPad)
                }
                Section("返済日") {
                    Picker("返済日", selection: $newPaymentDay) {
                        ForEach(1...31, id: \.self) { Text("毎月\($0)日").tag($0) }
                    }
                }
            }
            .navigationTitle("借金を追加")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { showAddDebt = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        if let balance = Int(newBalance), let monthly = Int(newMonthly), !newName.isEmpty {
                            let debt = Debt(
                                lenderName: newName, remainingBalance: balance, monthlyPayment: monthly,
                                interestRate: Double(newRate), debtType: newType, paymentDay: newPaymentDay
                            )
                            appState.debts.append(debt)
                            showAddDebt = false
                        }
                    }
                    .foregroundColor(AppColor.primary)
                }
            }
        }
    }
}

// MARK: - 借金詳細カード
private struct DebtDetailCard: View {
    let debt: Debt
    let priority: Int

    var body: some View {
        VStack(spacing: 12) {
            // ヘッダー
            HStack(spacing: 10) {
                // 優先度バッジ
                ZStack {
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 28, height: 28)
                    Text("\(priority)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(debt.debtType.emoji)
                        Text(debt.lenderName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)
                    }
                    if let rate = debt.interestRate {
                        Text("年利\(String(format: "%.1f", rate))%")
                            .font(.system(size: 12))
                            .foregroundColor(dangerColor)
                    } else {
                        Text("金利不明（暫定）")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textTertiary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("残高")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textTertiary)
                    Text(debt.remainingBalance.man)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColor.danger)
                }
            }

            // リボ警告
            if let warning = debt.debtType.warningMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.danger)
                    Text(warning)
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.danger)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .background(AppColor.dangerLight)
                .cornerRadius(8)
            }

            // 返済詳細
            HStack(spacing: 0) {
                debtMetric(label: "毎月返済", value: debt.monthlyPayment.yen)
                divider
                debtMetric(
                    label: "完済まで約",
                    value: debt.estimatedMonthsToPayoff.map { "\($0)ヶ月" } ?? "不明"
                )
                divider
                debtMetric(label: "返済日", value: "毎月\(debt.paymentDay)日")
            }
        }
        .cardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(debt.dangerLevel == .high ? AppColor.danger.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
    }

    private var priorityColor: Color {
        switch priority {
        case 1: return AppColor.danger
        case 2: return AppColor.caution
        default: return AppColor.secondary
        }
    }

    private var dangerColor: Color {
        switch debt.dangerLevel {
        case .high: return AppColor.danger
        case .medium: return AppColor.caution
        case .low: return AppColor.secondary
        }
    }

    private func debtMetric(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.system(size: 11)).foregroundColor(AppColor.textTertiary)
            Text(value).font(.system(size: 13, weight: .semibold)).foregroundColor(AppColor.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle().fill(AppColor.sectionBackground).frame(width: 1, height: 36)
    }
}

#Preview {
    DebtNaviView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
