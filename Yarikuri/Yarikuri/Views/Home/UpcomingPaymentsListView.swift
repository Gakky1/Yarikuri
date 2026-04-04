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
                            // 固定費セクション
                            let fixedItems = allItems.filter { $0.kind == .fixed }
                            if !fixedItems.isEmpty {
                                sectionHeader(title: "固定費", icon: "calendar.badge.clock", color: AppColor.primary, count: fixedItems.count)
                                ForEach(fixedItems) { item in
                                    UpcomingDetailRow(item: item)
                                }
                            }

                            // 変動費セクション
                            let variableItems = allItems.filter { $0.kind == .variable }
                            if !variableItems.isEmpty {
                                sectionHeader(title: "変動費", icon: "creditcard", color: AppColor.secondary, count: variableItems.count)
                                ForEach(variableItems) { item in
                                    UpcomingDetailRow(item: item)
                                }
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

    private func sectionHeader(title: String, icon: String, color: Color, count: Int) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)
            Spacer()
            Text("\(count)件")
                .font(.system(size: 12))
                .foregroundColor(AppColor.textTertiary)
        }
        .padding(.top, 4)
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

    // 変動費の場合、対応するScheduledPaymentを取得
    private var scheduledPayment: ScheduledPayment? {
        guard item.kind == .variable else { return nil }
        return appState.scheduledPayments.first { $0.id == item.id }
    }

    var body: some View {
        HStack(spacing: 14) {
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
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(AppColor.dangerLight)
                            .cornerRadius(4)
                    } else if item.daysUntil <= 7 {
                        Text("あと\(item.daysUntil)日")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColor.caution)
                    }
                }
            }

            Spacer()

            // 金額 + 変動費の場合は済みボタン
            VStack(alignment: .trailing, spacing: 6) {
                Text(item.amount.yen)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(item.daysUntil <= 3 ? AppColor.danger : AppColor.textPrimary)

                if item.kind == .variable, let payment = scheduledPayment {
                    Button(action: { appState.markPaymentAsPaid(payment) }) {
                        Text("済み")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppColor.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(AppColor.secondaryLight)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(14)
        .background(item.daysUntil <= 3 ? AppColor.dangerLight : AppColor.cardBackground)
        .cornerRadius(12)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 1)
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
