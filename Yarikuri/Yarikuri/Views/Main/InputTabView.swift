import SwiftUI

// MARK: - 入力タブ
struct InputTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedInputTab: InputTab = .expense

    enum InputTab { case expense, income }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // ヘッダー（HomeViewと同じ構造: VStack 12pt + HStack 8pt = 20pt）
                    HStack {
                        Text("入力")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
                    }
                    .padding(.top, 8)

                    // セグメント切り替え
                    Picker("", selection: $selectedInputTab) {
                        Text("支出").tag(InputTab.expense)
                        Text("収入").tag(InputTab.income)
                    }
                    .pickerStyle(.segmented)

                    if selectedInputTab == .expense {
                        ExpenseInputForm()
                    } else {
                        IncomeInputForm()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
    }
}

// MARK: - 支出入力フォーム
private struct ExpenseInputForm: View {
    @EnvironmentObject var appState: AppState

    enum ExpenseType { case fixed, variable }
    @State private var expenseType: ExpenseType = .variable

    // 変動費
    @State private var varName = ""
    @State private var varAmountText = ""
    @State private var varCategory: PaymentCategory = .other
    @State private var varDueDate = Date()

    // 固定費
    @State private var fixName = ""
    @State private var fixAmountText = ""
    @State private var fixCategory: FixedExpenseCategory = .other
    @State private var fixBillingDay: Int = 1
    @State private var fixIsSubscription = false

    @State private var saved = false

    var body: some View {
        VStack(spacing: 16) {
            // 固定費 / 変動費 切り替え
            VStack(alignment: .leading, spacing: 10) {
                Picker("", selection: $expenseType) {
                    Text("変動費").tag(ExpenseType.variable)
                    Text("固定費").tag(ExpenseType.fixed)
                }
                .pickerStyle(.segmented)

                // 説明文
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("📅 変動費")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColor.caution)
                        Text("月によって金額が変わる支出。自動車税・医療費・旅行など一度きりや不定期の支払い。")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("📋 固定費")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColor.primary)
                        Text("毎月ほぼ同じ金額がかかる支出。家賃・保険・サブスクなど毎月自動で引き落とされるもの。")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(12)
                .background(AppColor.sectionBackground)
                .cornerRadius(10)
            }
            .cardInputStyle()

            // 入力フォーム
            if expenseType == .variable {
                variableForm
            } else {
                fixedForm
            }

            saveButton(
                label: saved ? "保存しました！" : (expenseType == .variable ? "変動費に追加" : "固定費に追加"),
                color: expenseType == .variable ? AppColor.caution : AppColor.primary,
                saved: saved,
                action: save,
                disabled: !canSave
            )
        }
        .padding(.bottom, 12)
    }

    // MARK: 変動費フォーム
    private var variableForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            inputField(label: "支出の名前") {
                TextField("例: 自動車税、薬代", text: $varName)
                    .inputStyle()
            }
            inputField(label: "金額") {
                amountField(text: $varAmountText)
            }
            inputField(label: "カテゴリ") {
                Picker("カテゴリ", selection: $varCategory) {
                    ForEach(PaymentCategory.allCases, id: \.rawValue) { cat in
                        Text(cat.emoji + " " + cat.displayText).tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppColor.inputBackground)
                .cornerRadius(12)
            }
            inputField(label: "支払い予定日") {
                DatePicker("", selection: $varDueDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                    .tint(AppColor.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(AppColor.inputBackground)
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .cardInputStyle()
    }

    // MARK: 固定費フォーム
    private var fixedForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            inputField(label: "固定費の名前") {
                TextField("例: 家賃、Netflix", text: $fixName)
                    .inputStyle()
            }
            inputField(label: "月額") {
                amountField(text: $fixAmountText)
            }
            inputField(label: "カテゴリ") {
                Picker("カテゴリ", selection: $fixCategory) {
                    ForEach(FixedExpenseCategory.allCases, id: \.rawValue) { cat in
                        Text(cat.emoji + " " + cat.displayText).tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppColor.inputBackground)
                .cornerRadius(12)
            }
            inputField(label: "引き落とし日") {
                Picker("引き落とし日", selection: $fixBillingDay) {
                    ForEach(1...31, id: \.self) { day in
                        Text("毎月\(day)日").tag(day)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppColor.inputBackground)
                .cornerRadius(12)
            }
            inputField(label: "種別") {
                Toggle("サブスクリプション", isOn: $fixIsSubscription)
                    .tint(AppColor.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(AppColor.inputBackground)
                    .cornerRadius(12)
            }
        }
        .cardInputStyle()
    }

    private var canSave: Bool {
        expenseType == .variable
            ? !varName.isEmpty && Int(varAmountText) != nil
            : !fixName.isEmpty && Int(fixAmountText) != nil
    }

    private func save() {
        if expenseType == .variable {
            guard let amount = Int(varAmountText), !varName.isEmpty else { return }
            appState.scheduledPayments.append(
                ScheduledPayment(name: varName, amount: amount, dueDate: varDueDate, category: varCategory)
            )
            varName = ""; varAmountText = ""; varCategory = .other; varDueDate = Date()
        } else {
            guard let amount = Int(fixAmountText), !fixName.isEmpty else { return }
            appState.fixedExpenses.append(
                FixedExpense(name: fixName, amount: amount, billingDay: fixBillingDay,
                             category: fixCategory, isSubscription: fixIsSubscription)
            )
            fixName = ""; fixAmountText = ""; fixCategory = .other
            fixBillingDay = 1; fixIsSubscription = false
        }
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { saved = false }
    }
}

// MARK: - 収入入力フォーム
private struct IncomeInputForm: View {
    @EnvironmentObject var appState: AppState

    @State private var incomeName = ""
    @State private var amountText = ""
    @State private var category: IncomeCategory = .salary
    @State private var selectedDate = Date()
    @State private var noteText = ""
    @State private var saved = false

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 20) {
                inputField(label: "収入の名前") {
                    TextField("例: 4月分給与、ボーナス", text: $incomeName)
                        .inputStyle()
                }

                inputField(label: "手取り金額") {
                    amountField(text: $amountText)
                }

                inputField(label: "カテゴリ") {
                    Picker("カテゴリ", selection: $category) {
                        ForEach(IncomeCategory.allCases, id: \.rawValue) { cat in
                            Text(cat.emoji + " " + cat.displayText).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColor.safe)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(AppColor.inputBackground)
                    .cornerRadius(12)
                }

                inputField(label: "年月日") {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .tint(AppColor.safe)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(AppColor.inputBackground)
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                inputField(label: "メモ（任意）") {
                    TextField("例: 残業代含む、副業分", text: $noteText)
                        .inputStyle()
                }
            }
            .cardInputStyle()

            saveButton(
                label: saved ? "保存しました！" : "収入を記録",
                color: AppColor.safe,
                saved: saved,
                action: save,
                disabled: !canSave
            )
        }
        .padding(.bottom, 12)
    }

    private var canSave: Bool { !amountText.isEmpty && Int(amountText) != nil }

    private func save() {
        guard let amount = Int(amountText), amount > 0 else { return }
        let cal = Calendar.current
        let year  = cal.component(.year,  from: selectedDate)
        let month = cal.component(.month, from: selectedDate)
        let day   = cal.component(.day,   from: selectedDate)
        if let idx = appState.incomeHistory.firstIndex(where: { $0.year == year && $0.month == month }) {
            appState.incomeHistory[idx].amount   = amount
            appState.incomeHistory[idx].name     = incomeName
            appState.incomeHistory[idx].category = category
            appState.incomeHistory[idx].day      = day
            appState.incomeHistory[idx].note     = noteText
        } else {
            appState.incomeHistory.append(
                IncomeRecord(year: year, month: month, day: day,
                             amount: amount, name: incomeName,
                             category: category, note: noteText)
            )
        }
        incomeName = ""; amountText = ""; category = .salary
        selectedDate = Date(); noteText = ""
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { saved = false }
    }
}

// MARK: - 共通部品
private func inputField<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(label)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(AppColor.textSecondary)
        content()
    }
}

private func amountField(text: Binding<String>) -> some View {
    HStack(spacing: 4) {
        Text("¥")
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(AppColor.primary)
        TextField("0", text: text)
            .keyboardType(.numberPad)
            .font(.system(size: 17, weight: .semibold))
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 12)
    .background(AppColor.inputBackground)
    .cornerRadius(12)
    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColor.primary.opacity(0.3), lineWidth: 1))
}

private func saveButton(label: String, color: Color, saved: Bool, action: @escaping () -> Void, disabled: Bool) -> some View {
    Button(action: action) {
        HStack(spacing: 8) {
            Image(systemName: saved ? "checkmark.circle.fill" : "plus.circle.fill")
                .font(.system(size: 17))
            Text(label)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(disabled ? color.opacity(0.4) : color)
        .cornerRadius(14)
    }
    .disabled(disabled)
}

// MARK: - View modifier
private extension View {
    func inputStyle() -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppColor.inputBackground)
            .cornerRadius(12)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    func cardInputStyle() -> some View {
        self
            .padding(16)
            .background(AppColor.cardBackground)
            .cornerRadius(16)
            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
    }
}
