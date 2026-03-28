import SwiftUI

// MARK: - 固定費・サブスク整理画面
struct FixedExpenseView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showAddForm = false
    @State private var newName = ""
    @State private var newAmountText = ""
    @State private var newCategory: FixedExpenseCategory = .other
    @State private var newIsSubscription = false
    @State private var newBillingDay: Int = 1

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 合計サマリー
                        totalSummaryCard

                        // 見直し候補セクション
                        if !reviewCandidates.isEmpty {
                            reviewCandidatesCard
                        }

                        // 全固定費リスト
                        allExpensesCard

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("固定費・サブスク")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { withAnimation { showAddForm = true } }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppColor.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddForm) {
                addExpenseSheet
            }
        }
    }

    private var reviewCandidates: [FixedExpense] {
        appState.fixedExpenses.filter { $0.isReviewCandidate }
    }

    // MARK: - 合計サマリーカード
    private var totalSummaryCard: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("固定費合計").font(.system(size: 13)).foregroundColor(AppColor.textSecondary)
                Text(appState.totalFixedExpenses.yen)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                let subTotal = appState.fixedExpenses.filter { $0.isSubscription }.reduce(0) { $0 + $1.amount }
                Text("サブスク計").font(.system(size: 12)).foregroundColor(AppColor.textTertiary)
                Text(subTotal.yen)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.caution)
            }
        }
        .cardStyle()
    }

    // MARK: - 見直し候補カード
    private var reviewCandidatesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("✂️ 見直し候補")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.caution)
                Text("まとめて\(reviewCandidates.reduce(0){$0+$1.amount}.yen)が節約候補")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textTertiary)
                    .padding(.leading, 4)
                Spacer()
            }

            ForEach(reviewCandidates) { expense in
                ExpenseDetailRow(expense: expense, showReviewBadge: true)
            }
        }
        .padding(14)
        .background(AppColor.cautionLight)
        .cornerRadius(14)
    }

    // MARK: - 全固定費リスト
    private var allExpensesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("すべての固定費")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            if appState.fixedExpenses.isEmpty {
                Text("固定費が登録されていません")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(FixedExpenseCategory.allCases, id: \.rawValue) { category in
                    let expenses = appState.fixedExpenses.filter { $0.category == category }
                    if !expenses.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(category.emoji) \(category.displayText)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppColor.textTertiary)

                            ForEach(expenses) { expense in
                                ExpenseDetailRow(expense: expense, showReviewBadge: false)
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - 追加シート
    private var addExpenseSheet: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("名前（例: Netflix）", text: $newName)
                    TextField("金額（円）", text: $newAmountText)
                        .keyboardType(.numberPad)
                    Picker("カテゴリ", selection: $newCategory) {
                        ForEach(FixedExpenseCategory.allCases, id: \.rawValue) { cat in
                            Text("\(cat.emoji) \(cat.displayText)").tag(cat)
                        }
                    }
                }
                Section("詳細") {
                    Toggle("サブスクリプション", isOn: $newIsSubscription)
                    Picker("引き落とし日", selection: $newBillingDay) {
                        ForEach(1...31, id: \.self) { day in
                            Text("毎月\(day)日").tag(day)
                        }
                    }
                }
            }
            .navigationTitle("固定費を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { showAddForm = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        if let amount = Int(newAmountText), !newName.isEmpty {
                            let expense = FixedExpense(
                                name: newName, amount: amount, billingDay: newBillingDay,
                                category: newCategory, isSubscription: newIsSubscription
                            )
                            appState.fixedExpenses.append(expense)
                            showAddForm = false
                        }
                    }
                    .foregroundColor(AppColor.primary)
                }
            }
        }
    }
}

// MARK: - 固定費詳細行
struct ExpenseDetailRow: View {
    let expense: FixedExpense
    let showReviewBadge: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(expense.category.emoji)
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(AppColor.sectionBackground)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(expense.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    if expense.isSubscription {
                        Text("サブスク")
                            .font(.system(size: 10))
                            .foregroundColor(Color.purple.opacity(0.8))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                if let day = expense.billingDay {
                    Text("毎月\(day)日")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textTertiary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(expense.amount.yen)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                if showReviewBadge {
                    Text("見直し可")
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.caution)
                }
            }
        }
        .padding(10)
        .background(AppColor.cardBackground)
        .cornerRadius(10)
        .shadow(color: AppColor.shadowColor, radius: 3)
    }
}

#Preview {
    FixedExpenseView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
