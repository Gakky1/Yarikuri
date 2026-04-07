import SwiftUI

// MARK: - 入力タブ
struct InputTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedInputTab: InputTab = .expense
    @State private var levelUpTrigger = false
    @State private var prevInputLevel: Int = 1

    enum InputTab { case expense, income }

    private var inputLevel: Int {
        switch appState.inputXpCount {
        case 0..<3:   return 1
        case 3..<7:   return 2
        case 7..<13:  return 3
        case 13..<21: return 4
        default:      return 5
        }
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // ヘッダー
                    HStack {
                        Text("入力")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
                    }
                    .padding(.top, 8)

                    // やりくりんマスコット
                    InputMascotBanner(
                        level: inputLevel,
                        xpCount: appState.inputXpCount,
                        levelUpTrigger: levelUpTrigger
                    )

                    // セグメント切り替え
                    Picker("", selection: $selectedInputTab) {
                        Text("支出").tag(InputTab.expense)
                        Text("収入").tag(InputTab.income)
                    }
                    .pickerStyle(.segmented)

                    if selectedInputTab == .expense {
                        ExpenseInputForm(onSaved: handleSaved)
                    } else {
                        IncomeInputForm(onSaved: handleSaved)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .onAppear { prevInputLevel = inputLevel }
    }

    private func handleSaved() {
        let old = inputLevel
        appState.inputXpCount += 1
        let new = inputLevel
        if new > old {
            levelUpTrigger = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                levelUpTrigger = false
            }
        }
    }
}

// MARK: - 入力タブ用マスコットバナー
private struct InputMascotBanner: View {
    let level: Int
    let xpCount: Int
    let levelUpTrigger: Bool

    @State private var bounce: CGFloat = 0
    @State private var starScale: CGFloat = 0
    @State private var starOpacity: Double = 0

    private var nextLevelAt: Int {
        switch level {
        case 1: return 3
        case 2: return 7
        case 3: return 13
        case 4: return 21
        default: return 21
        }
    }

    private var prevLevelAt: Int {
        switch level {
        case 1: return 0
        case 2: return 3
        case 3: return 7
        case 4: return 13
        default: return 21
        }
    }

    private var progressRatio: Double {
        guard level < 5 else { return 1.0 }
        let span = Double(nextLevelAt - prevLevelAt)
        let progress = Double(xpCount - prevLevelAt)
        return min(1.0, max(0.0, progress / span))
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(
                    colors: [AppColor.primaryLight, AppColor.accentLight],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))

            HStack(spacing: 14) {
                // やりくりん
                CoronView(size: 56, emotion: level >= 4 ? .happy : .normal, animate: true, level: level)
                    .frame(width: 72, height: 66)
                    .offset(y: bounce)

                VStack(alignment: .leading, spacing: 6) {
                    // 名前 + レベルバッジ
                    HStack(spacing: 8) {
                        Text("やりくりん")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Text("Lv.\(level)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(AppColor.primary)
                            .cornerRadius(8)
                    }

                    // プログレスバー
                    if level < 5 {
                        VStack(alignment: .leading, spacing: 3) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(AppColor.primary.opacity(0.15))
                                        .frame(height: 7)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(LinearGradient(
                                            colors: [AppColor.primary, AppColor.accent],
                                            startPoint: .leading, endPoint: .trailing
                                        ))
                                        .frame(width: geo.size.width * progressRatio, height: 7)
                                        .animation(.spring(response: 0.5), value: progressRatio)
                                }
                            }
                            .frame(height: 7)
                            Text("入力するたびにポイントが溜まるよ！ あと \(max(0, nextLevelAt - xpCount)) 回でLv.\(level + 1)")
                                .font(.system(size: 10))
                                .foregroundColor(AppColor.textSecondary)
                        }
                    } else {
                        Text("🏆 入力マスター達成！")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColor.primary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            // Lv.UP エフェクト
            if levelUpTrigger {
                VStack(spacing: 4) {
                    Text("⭐️ Lv.\(level) に UP！")
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(AppColor.primary)
                        .shadow(color: AppColor.primary.opacity(0.3), radius: 4)
                }
                .scaleEffect(starScale)
                .opacity(starOpacity)
            }
        }
        .frame(height: 110)
        .shadow(color: AppColor.shadowColor, radius: 5, x: 0, y: 2)
        .onChange(of: levelUpTrigger) { triggered in
            if triggered {
                // バウンス
                withAnimation(.spring(response: 0.18, dampingFraction: 0.4)) { bounce = -16 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.45)) { bounce = 0 }
                }
                // スター表示
                withAnimation(.spring(response: 0.3)) {
                    starScale = 1.0; starOpacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        starOpacity = 0; starScale = 1.3
                    }
                }
            } else {
                starScale = 0; starOpacity = 0
            }
        }
    }
}

// MARK: - 支出入力フォーム
private struct ExpenseInputForm: View {
    @EnvironmentObject var appState: AppState
    var onSaved: (() -> Void)? = nil

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
        onSaved?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { saved = false }
    }
}

// MARK: - 収入入力フォーム
private struct IncomeInputForm: View {
    @EnvironmentObject var appState: AppState
    var onSaved: (() -> Void)? = nil

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
        onSaved?()
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
