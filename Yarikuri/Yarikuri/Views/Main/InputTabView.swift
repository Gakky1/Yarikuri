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
                    // ヘッダー
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
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - 支出入力フォーム
private struct ExpenseInputForm: View {
    @EnvironmentObject var appState: AppState

    @State private var name = ""
    @State private var amountText = ""
    @State private var category: PaymentCategory = .other
    @State private var dueDate = Date()
    @State private var saved = false

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 20) {
                // 名前
                inputBlock(label: "支出の名前") {
                    TextField("例: 自動車税、薬代", text: $name)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(AppColor.inputBackground)
                        .cornerRadius(12)
                }

                // 金額
                inputBlock(label: "金額") {
                    HStack {
                        Text("¥")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColor.primary)
                        TextField("0", text: $amountText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(AppColor.inputBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColor.primary.opacity(0.3), lineWidth: 1))
                }

                // カテゴリ
                inputBlock(label: "カテゴリ") {
                    Picker("カテゴリ", selection: $category) {
                        ForEach(PaymentCategory.allCases, id: \.rawValue) { cat in
                            Text(cat.emoji + " " + cat.displayText).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColor.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppColor.inputBackground)
                    .cornerRadius(12)
                }

                // 支払い予定日
                inputBlock(label: "支払い予定日") {
                    DatePicker("", selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .padding(.horizontal, 4)
                }
            }
            .padding(16)
            .background(AppColor.cardBackground)
            .cornerRadius(16)
            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)

            // 保存ボタン
            Button(action: save) {
                HStack {
                    Image(systemName: saved ? "checkmark.circle.fill" : "plus.circle.fill")
                    Text(saved ? "保存しました！" : "変動費に追加")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(canSave ? AppColor.caution : AppColor.caution.opacity(0.4))
                .cornerRadius(14)
            }
            .disabled(!canSave)
        }
        .padding(.bottom, 12)
    }

    private var canSave: Bool { !name.isEmpty && Int(amountText) != nil }

    private func save() {
        guard let amount = Int(amountText), !name.isEmpty else { return }
        let payment = ScheduledPayment(name: name, amount: amount, dueDate: dueDate, category: category)
        appState.scheduledPayments.append(payment)
        name = ""
        amountText = ""
        category = .other
        dueDate = Date()
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { saved = false }
    }
}

// MARK: - 収入入力フォーム
private struct IncomeInputForm: View {
    @EnvironmentObject var appState: AppState

    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var amountText = ""
    @State private var noteText = ""
    @State private var saved = false

    private var years: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array((current - 5)...current).reversed()
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 20) {
                // 年月
                inputBlock(label: "年月") {
                    HStack(spacing: 10) {
                        Picker("年", selection: $selectedYear) {
                            ForEach(years, id: \.self) { year in
                                Text(String(year) + "年").tag(year)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppColor.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(AppColor.inputBackground)
                        .cornerRadius(10)

                        Picker("月", selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)月").tag(month)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppColor.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(AppColor.inputBackground)
                        .cornerRadius(10)
                    }
                }

                // 金額
                inputBlock(label: "手取り収入") {
                    HStack {
                        Text("¥")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColor.safe)
                        TextField("0", text: $amountText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(AppColor.inputBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColor.safe.opacity(0.4), lineWidth: 1))
                }

                // メモ
                inputBlock(label: "メモ（任意）") {
                    TextField("例: ボーナス、副業収入", text: $noteText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(AppColor.inputBackground)
                        .cornerRadius(12)
                }
            }
            .padding(16)
            .background(AppColor.cardBackground)
            .cornerRadius(16)
            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)

            // 保存ボタン
            Button(action: save) {
                HStack {
                    Image(systemName: saved ? "checkmark.circle.fill" : "plus.circle.fill")
                    Text(saved ? "保存しました！" : "収入を記録")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(canSave ? AppColor.safe : AppColor.safe.opacity(0.4))
                .cornerRadius(14)
            }
            .disabled(!canSave)
        }
        .padding(.bottom, 12)
    }

    private var canSave: Bool { Int(amountText) != nil && !amountText.isEmpty }

    private func save() {
        guard let amount = Int(amountText), amount > 0 else { return }
        if let idx = appState.incomeHistory.firstIndex(where: { $0.year == selectedYear && $0.month == selectedMonth }) {
            appState.incomeHistory[idx].amount = amount
            appState.incomeHistory[idx].note = noteText
        } else {
            let record = IncomeRecord(year: selectedYear, month: selectedMonth, amount: amount, note: noteText)
            appState.incomeHistory.append(record)
        }
        amountText = ""
        noteText = ""
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { saved = false }
    }
}

// MARK: - ヘルパー
private func inputBlock<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(label)
            .font(.caption)
            .foregroundColor(AppColor.textSecondary)
        content()
    }
}
