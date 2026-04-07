import SwiftUI

// MARK: - 次の支払いカード（固定費＋変動費 近い5件）
struct NextPaymentsCard: View {
    @EnvironmentObject var appState: AppState
    var onDetailTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack {
                Text("次の支払い")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
                Button(action: onDetailTap) {
                    Text("詳細を見る")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.primary)
                }
            }
            .padding(.bottom, 12)

            if appState.upcomingCombinedPayments.isEmpty {
                // 支払い予定なし
                VStack(spacing: 6) {
                    Text("👍").font(.system(size: 28))
                    Text("近い支払い予定はありません")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            } else {
                VStack(spacing: 10) {
                    ForEach(appState.upcomingCombinedPayments) { item in
                        UpcomingPaymentRow(item: item)
                    }
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - 統合支払い行（固定費＋変動費）
struct UpcomingPaymentRow: View {
    let item: UpcomingPaymentItem

    var body: some View {
        HStack(spacing: 12) {
            // 絵文字バッジ
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(item.emoji)
                    .font(.system(size: 18))
            }

            // 情報
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    Text(item.kind == .fixed ? "固定費" : "変動費")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(item.kind == .fixed ? AppColor.primary : AppColor.secondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background((item.kind == .fixed ? AppColor.primaryLight : AppColor.secondaryLight))
                        .cornerRadius(4)
                }
                Text(item.dueDate.monthDayWeekday)
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }

            Spacer()

            Text(item.amount.yen)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(item.daysUntil <= 3 ? AppColor.danger : AppColor.textPrimary)
        }
        .padding(12)
        .background(item.daysUntil <= 3 ? AppColor.dangerLight : AppColor.sectionBackground)
        .cornerRadius(10)
    }

    private var badgeColor: Color {
        item.daysUntil <= 3 ? AppColor.danger
            : item.daysUntil <= 7 ? AppColor.caution
            : AppColor.secondary
    }
}

// MARK: - 支払い行（変動費専用）
struct PaymentRow: View {
    let payment: ScheduledPayment
    @EnvironmentObject var appState: AppState
    @State private var editingPayment: ScheduledPayment? = nil

    var body: some View {
        HStack(spacing: 10) {
            // 緊急度バッジ
            ZStack {
                Circle()
                    .fill(urgencyColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(payment.category.emoji)
                    .font(.system(size: 18))
            }

            // 支払い情報
            VStack(alignment: .leading, spacing: 2) {
                Text(payment.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Text(payment.dueDate.monthDayWeekday)
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }

            Spacer()

            Text(payment.amount.yen)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(payment.urgencyLevel == .urgent || payment.urgencyLevel == .overdue
                                 ? AppColor.danger : AppColor.textPrimary)

            // 編集・削除ボタン
            VStack(spacing: 4) {
                Button { editingPayment = payment } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.primary)
                        .frame(width: 28, height: 28)
                        .background(AppColor.primaryLight)
                        .cornerRadius(7)
                }
                Button {
                    appState.scheduledPayments.removeAll { $0.id == payment.id }
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
        .padding(12)
        .background(payment.urgencyLevel == .urgent ? AppColor.dangerLight : AppColor.sectionBackground)
        .cornerRadius(10)
        .sheet(item: $editingPayment) { p in
            EditScheduledPaymentSheet(payment: p) { updated in
                if let idx = appState.scheduledPayments.firstIndex(where: { $0.id == updated.id }) {
                    appState.scheduledPayments[idx] = updated
                }
            }
        }
    }

    private var urgencyColor: Color {
        switch payment.urgencyLevel {
        case .overdue: return AppColor.danger
        case .urgent:  return AppColor.danger
        case .soon:    return AppColor.caution
        case .normal:  return AppColor.secondary
        }
    }
}

#Preview {
    NextPaymentsCard(onDetailTap: {})
        .padding()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
