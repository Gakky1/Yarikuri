import SwiftUI

// MARK: - 借金入力（オンボーディング ステップ5）
struct DebtStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var showAddForm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                stepHeader

                // 借金あり・なしの選択
                HStack(spacing: 12) {
                    DebtToggleButton(
                        title: "ある",
                        emoji: "💳",
                        isSelected: vm.hasDebt,
                        onTap: { vm.hasDebt = true }
                    )
                    DebtToggleButton(
                        title: "ない",
                        emoji: "✨",
                        isSelected: !vm.hasDebt,
                        onTap: { vm.hasDebt = false }
                    )
                }
                .padding(.horizontal, 24)

                if vm.hasDebt {
                    debtInputSection
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                if !vm.hasDebt {
                    // ない場合の安心メッセージ
                    HStack {
                        Text("✨")
                        Text("素晴らしいです！\nこのまま管理を続けていきましょう。")
                            .font(.system(size: 15))
                            .foregroundColor(AppColor.textSecondary)
                    }
                    .padding()
                    .background(AppColor.secondaryLight)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .transition(.opacity)
                }
            }
            .padding(.top, 16)
            .animation(.spring(response: 0.4), value: vm.hasDebt)
        }
    }

    // MARK: - 借金入力セクション
    private var debtInputSection: some View {
        VStack(spacing: 14) {
            // 入力済みリスト
            if !vm.debts.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(vm.debts.enumerated()), id: \.1.id) { index, debt in
                        DebtListRow(debt: debt) {
                            vm.debts.remove(at: index)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            // 追加フォーム
            if showAddForm {
                addDebtForm
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // 追加ボタン
            Button(action: { withAnimation { showAddForm.toggle() } }) {
                Label(showAddForm ? "キャンセル" : "借金を追加する", systemImage: showAddForm ? "xmark" : "plus.circle")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColor.danger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColor.dangerLight)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            HintCard(text: "金利がわからなくても大丈夫。残高と毎月の返済額だけでもOKです。借金があることを認識するだけで、返済計画の第一歩になります。")
                .padding(.horizontal, 24)
        }
    }

    // MARK: - 借金追加フォーム
    private var addDebtForm: some View {
        VStack(spacing: 12) {
            TextField("借入先（例: ○○カード、消費者金融A）", text: $vm.newDebtName)
                .padding()
                .background(AppColor.inputBackground)
                .cornerRadius(10)

            Picker("種類", selection: $vm.newDebtType) {
                ForEach(DebtType.allCases, id: \.rawValue) { type in
                    Text("\(type.emoji) \(type.displayText)").tag(type)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .background(AppColor.inputBackground)
            .cornerRadius(10)

            HStack {
                VStack(alignment: .leading) {
                    Text("残高").font(.caption).foregroundColor(AppColor.textSecondary)
                    TextField("例: 300000", text: $vm.newDebtBalanceText)
                        .keyboardType(.numberPad)
                        .padding(10)
                        .background(AppColor.inputBackground)
                        .cornerRadius(8)
                }
                VStack(alignment: .leading) {
                    Text("毎月の返済額").font(.caption).foregroundColor(AppColor.textSecondary)
                    TextField("例: 10000", text: $vm.newDebtMonthlyText)
                        .keyboardType(.numberPad)
                        .padding(10)
                        .background(AppColor.inputBackground)
                        .cornerRadius(8)
                }
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("金利（任意）").font(.caption).foregroundColor(AppColor.textSecondary)
                    HStack {
                        TextField("例: 15", text: $vm.newDebtRateText)
                            .keyboardType(.decimalPad)
                            .padding(10)
                            .background(AppColor.inputBackground)
                            .cornerRadius(8)
                        Text("%").foregroundColor(AppColor.textSecondary)
                    }
                }
                VStack(alignment: .leading) {
                    Text("返済日").font(.caption).foregroundColor(AppColor.textSecondary)
                    Picker("返済日", selection: $vm.newDebtPaymentDay) {
                        ForEach(1...31, id: \.self) { day in
                            Text("毎月\(day)日").tag(day)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(10)
                    .background(AppColor.inputBackground)
                    .cornerRadius(8)
                }
            }

            Button(action: {
                vm.addDebt()
                showAddForm = false
            }) {
                Text("追加する")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColor.primary)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(AppColor.cardBackground)
        .cornerRadius(14)
        .shadow(color: AppColor.shadowColor, radius: 6)
    }

    private var stepHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(vm.currentStep.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColor.textPrimary)
                .padding(.horizontal, 24)
            Text(vm.currentStep.subtitle)
                .font(.system(size: 15))
                .foregroundColor(AppColor.textSecondary)
                .padding(.horizontal, 24)
        }
    }
}

// MARK: - 借金あり/なし切り替えボタン
private struct DebtToggleButton: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(emoji).font(.system(size: 28))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? AppColor.primary : AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? AppColor.primaryLight : AppColor.cardBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppColor.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - 借金リスト行
private struct DebtListRow: View {
    let debt: Debt
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text(debt.debtType.emoji)
            VStack(alignment: .leading, spacing: 2) {
                Text(debt.lenderName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Text("残\(debt.remainingBalance.man) / 月\(debt.monthlyPayment.yen)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(AppColor.textTertiary)
            }
        }
        .padding(12)
        .background(AppColor.cardBackground)
        .cornerRadius(10)
        .shadow(color: AppColor.shadowColor, radius: 3)
    }
}

#Preview {
    ZStack {
        AppColor.onboardingGradient.ignoresSafeArea()
        DebtStepView(vm: OnboardingViewModel())
    }
}
