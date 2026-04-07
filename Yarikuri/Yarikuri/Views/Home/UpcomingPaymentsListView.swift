import SwiftUI

// MARK: - 次の支払い一覧
struct UpcomingPaymentsListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if allItems.isEmpty {
                            emptyView
                        } else {
                            ForEach(allItems) { item in
                                UpcomingDetailRow(item: item)
                            }
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("次の支払い一覧")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }

    // 全件（上限なし）を日付順で返す
    private var allItems: [UpcomingPaymentItem] {
        var items: [UpcomingPaymentItem] = []

        // 変動費（未払いのみ）
        let variable = appState.scheduledPayments
            .filter { !$0.isPaid && $0.dueDate >= Date().startOfDay }
            .map { UpcomingPaymentItem(id: $0.id, name: $0.name, amount: $0.amount,
                                       dueDate: $0.dueDate, emoji: $0.category.emoji, kind: .variable) }
        items.append(contentsOf: variable)

        // 固定費（billingDayがある場合のみ、今月〜来月）
        let calendar = Calendar.current
        let today = Date()
        let currentDay = calendar.component(.day, from: today)
        for fe in appState.fixedExpenses {
            guard let billingDay = fe.billingDay else { continue }
            let base = billingDay >= currentDay ? today
                     : (calendar.date(byAdding: .month, value: 1, to: today) ?? today)
            var comps = calendar.dateComponents([.year, .month], from: base)
            let maxDay = calendar.range(of: .day, in: .month, for: base)?.count ?? billingDay
            comps.day = min(billingDay, maxDay)
            guard let dueDate = calendar.date(from: comps) else { continue }
            items.append(UpcomingPaymentItem(id: fe.id, name: fe.name, amount: fe.amount,
                                              dueDate: dueDate, emoji: fe.category.emoji, kind: .fixed))
        }

        return items.sorted { $0.dueDate < $1.dueDate }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Text("👍").font(.system(size: 48))
            Text("近い支払い予定はありません")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - 支払い詳細行
private struct UpcomingDetailRow: View {
    @EnvironmentObject var appState: AppState
    let item: UpcomingPaymentItem
    @State private var editingPayment: ScheduledPayment? = nil

    // 変動費の場合、対応するScheduledPaymentを取得
    private var scheduledPayment: ScheduledPayment? {
        guard item.kind == .variable else { return nil }
        return appState.scheduledPayments.first { $0.id == item.id }
    }

    var body: some View {
        HStack(spacing: 10) {
            // 絵文字バッジ
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(item.emoji)
                    .font(.system(size: 20))
            }

            // 情報
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    kindBadge
                }
                HStack(spacing: 8) {
                    Text(item.dueDate.monthDayWeekday)
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                    if item.daysUntil <= 3 {
                        Text("あと\(item.daysUntil)日")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppColor.danger)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(AppColor.dangerLight).cornerRadius(4)
                    } else if item.daysUntil <= 7 {
                        Text("あと\(item.daysUntil)日")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColor.caution)
                    }
                }
            }

            Spacer()

            // 金額
            Text(item.amount.yen)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(item.daysUntil <= 3 ? AppColor.danger : AppColor.textPrimary)

            // 変動費のみ: 編集・削除ボタン
            if item.kind == .variable {
                VStack(spacing: 4) {
                    Button {
                        editingPayment = scheduledPayment
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.primary)
                            .frame(width: 28, height: 28)
                            .background(AppColor.primaryLight)
                            .cornerRadius(7)
                    }
                    Button {
                        appState.scheduledPayments.removeAll { $0.id == item.id }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.caution)
                            .frame(width: 28, height: 28)
                            .background(AppColor.cautionLight)
                            .cornerRadius(7)
                    }
                }
            }
        }
        .padding(14)
        .background(item.daysUntil <= 3 ? AppColor.dangerLight : AppColor.cardBackground)
        .cornerRadius(12)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 1)
        .sheet(item: $editingPayment) { payment in
            EditScheduledPaymentSheet(payment: payment) { updated in
                if let idx = appState.scheduledPayments.firstIndex(where: { $0.id == updated.id }) {
                    appState.scheduledPayments[idx] = updated
                }
            }
        }
    }

    private var kindBadge: some View {
        Text(item.kind == .fixed ? "固定費" : "変動費")
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(item.kind == .fixed ? AppColor.primary : AppColor.secondary)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(item.kind == .fixed ? AppColor.primaryLight : AppColor.secondaryLight)
            .cornerRadius(4)
    }

    private var badgeColor: Color {
        item.daysUntil <= 3 ? AppColor.danger
            : item.daysUntil <= 7 ? AppColor.caution
            : AppColor.secondary
    }
}

// MARK: - 変動費編集シート
struct EditScheduledPaymentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let payment: ScheduledPayment
    let onSave: (ScheduledPayment) -> Void

    @State private var name: String
    @State private var amountText: String
    @State private var dueDate: Date
    @State private var category: PaymentCategory

    init(payment: ScheduledPayment, onSave: @escaping (ScheduledPayment) -> Void) {
        self.payment = payment
        self.onSave = onSave
        _name = State(initialValue: payment.name)
        _amountText = State(initialValue: "\(payment.amount)")
        _dueDate = State(initialValue: payment.dueDate)
        _category = State(initialValue: payment.category)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("名前", text: $name)
                    TextField("金額（円）", text: $amountText)
                        .keyboardType(.numberPad)
                    Picker("カテゴリ", selection: $category) {
                        ForEach(PaymentCategory.allCases, id: \.rawValue) { cat in
                            Text("\(cat.emoji) \(cat.displayText)").tag(cat)
                        }
                    }
                }
                Section("支払い日") {
                    DatePicker("支払い予定日", selection: $dueDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                }
            }
            .navigationTitle("変動費を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        guard let amount = Int(amountText), !name.isEmpty else { return }
                        var updated = payment
                        updated.name = name
                        updated.amount = amount
                        updated.dueDate = dueDate
                        updated.category = category
                        onSave(updated)
                        dismiss()
                    }
                    .foregroundColor(AppColor.primary)
                    .disabled(name.isEmpty || Int(amountText) == nil)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }
}
