import SwiftUI

// MARK: - 固定費入力（オンボーディング ステップ4）
struct FixedExpenseStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var showAddForm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                stepHeader

                // 入力モード切り替え
                Picker("入力方法", selection: $vm.useTotalAmount) {
                    Text("1つずつ入力").tag(false)
                    Text("合計だけ入力").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)

                if vm.useTotalAmount {
                    totalAmountInput
                } else {
                    itemListInput
                }

                HintCard(text: "固定費＝毎月必ずかかるお金。家賃、保険、サブスク、通信費などです。変動費（食費、交際費など）は含めないでください。")
                    .padding(.horizontal, 24)
            }
            .padding(.top, 16)
        }
    }

    // MARK: - 合計入力モード
    private var totalAmountInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("固定費の合計額")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)
                .padding(.horizontal, 24)

            HStack {
                TextField("例: 90000", text: $vm.totalFixedExpenseText)
                    .keyboardType(.numberPad)
                    .font(.system(size: 20, weight: .semibold))
                    .padding()
                    .background(AppColor.cardBackground)
                    .cornerRadius(12)

                Text("円")
                    .font(.system(size: 18))
                    .foregroundColor(AppColor.textSecondary)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - 個別入力モード
    private var itemListInput: some View {
        VStack(spacing: 12) {
            // 入力済みリスト
            if !vm.fixedExpenses.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(vm.fixedExpenses.enumerated()), id: \.1.id) { index, expense in
                        ExpenseListRow(expense: expense) {
                            vm.fixedExpenses.remove(at: index)
                        }
                    }

                    // 合計行
                    HStack {
                        Text("合計")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColor.textSecondary)
                        Spacer()
                        Text(vm.totalFixedAmount.yen)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColor.primary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColor.primaryLight)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 24)
            }

            // 追加フォーム
            if showAddForm {
                addExpenseForm
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // 追加ボタン
            Button(action: { withAnimation { showAddForm.toggle() } }) {
                Label(showAddForm ? "キャンセル" : "固定費を追加する", systemImage: showAddForm ? "xmark" : "plus.circle")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColor.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColor.primaryLight)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            // 典型的な固定費の提案
            if vm.fixedExpenses.isEmpty && !showAddForm {
                suggestedExpenses
            }
        }
    }

    // MARK: - 追加フォーム
    private var addExpenseForm: some View {
        VStack(spacing: 12) {
            TextField("名前（例: Netflix）", text: $vm.newExpenseName)
                .padding()
                .background(AppColor.inputBackground)
                .cornerRadius(10)

            HStack {
                TextField("金額", text: $vm.newExpenseAmountText)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(AppColor.inputBackground)
                    .cornerRadius(10)

                Text("円")
                    .foregroundColor(AppColor.textSecondary)
            }

            Picker("カテゴリ", selection: $vm.newExpenseCategory) {
                ForEach(FixedExpenseCategory.allCases, id: \.rawValue) { cat in
                    Text("\(cat.emoji) \(cat.displayText)").tag(cat)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .background(AppColor.inputBackground)
            .cornerRadius(10)

            Button(action: {
                vm.addFixedExpense()
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

    // MARK: - よくある固定費の提案
    private var suggestedExpenses: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("よくある固定費")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(FixedExpenseCategory.allCases, id: \.rawValue) { cat in
                        Button(action: {
                            vm.newExpenseCategory = cat
                            vm.newExpenseName = cat.displayText
                            showAddForm = true
                        }) {
                            VStack(spacing: 4) {
                                Text(cat.emoji).font(.title2)
                                Text(cat.displayText)
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColor.textSecondary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(AppColor.cardBackground)
                            .cornerRadius(12)
                            .shadow(color: AppColor.shadowColor, radius: 4)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
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

// MARK: - 固定費リスト行
private struct ExpenseListRow: View {
    let expense: FixedExpense
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text(expense.category.emoji)
            Text(expense.name)
                .font(.system(size: 15))
                .foregroundColor(AppColor.textPrimary)
            Spacer()
            Text(expense.amount.yen)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColor.textPrimary)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(AppColor.textTertiary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppColor.cardBackground)
        .cornerRadius(10)
        .shadow(color: AppColor.shadowColor, radius: 3)
    }
}

#Preview {
    ZStack {
        AppColor.onboardingGradient.ignoresSafeArea()
        FixedExpenseStepView(vm: OnboardingViewModel())
    }
}
