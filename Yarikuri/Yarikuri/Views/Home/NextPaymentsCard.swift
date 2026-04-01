import SwiftUI

// MARK: - 次の支払いカード（近い3件）
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

            if appState.upcomingPayments.isEmpty {
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
                    ForEach(appState.upcomingPayments) { payment in
                        PaymentRow(payment: payment)
                    }
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - 支払い行
struct PaymentRow: View {
    let payment: ScheduledPayment
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 12) {
            // 緊急度バッジ
            urgencyBadge

            // 支払い情報
            VStack(alignment: .leading, spacing: 2) {
                Text(payment.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(payment.isPaid ? AppColor.textTertiary : AppColor.textPrimary)
                    .strikethrough(payment.isPaid)
                Text(payment.dueDate.monthDayWeekday)
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }

            Spacer()

            // 金額と完了/取消ボタン
            VStack(alignment: .trailing, spacing: 4) {
                Text(payment.amount.yen)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(payment.isPaid ? AppColor.textTertiary
                                     : (payment.urgencyLevel == .urgent || payment.urgencyLevel == .overdue
                                        ? AppColor.danger : AppColor.textPrimary))

                if payment.isPaid {
                    Button(action: { appState.unmarkPaymentAsPaid(payment) }) {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                            Text("取消")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(AppColor.textTertiary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColor.sectionBackground)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AppColor.textTertiary.opacity(0.3), lineWidth: 1)
                        )
                    }
                } else {
                    Button(action: { appState.markPaymentAsPaid(payment) }) {
                        Text("済み")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppColor.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColor.secondaryLight)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(12)
        .background(payment.isPaid ? AppColor.cardBackground
                    : (payment.urgencyLevel == .urgent ? AppColor.dangerLight : AppColor.sectionBackground))
        .cornerRadius(10)
        .opacity(payment.isPaid ? 0.6 : 1.0)
    }

    private var urgencyBadge: some View {
        ZStack {
            Circle()
                .fill((payment.isPaid ? Color.gray : urgencyColor).opacity(0.15))
                .frame(width: 40, height: 40)
            Text(payment.category.emoji)
                .font(.system(size: 18))
        }
    }

    private var urgencyColor: Color {
        switch payment.urgencyLevel {
        case .overdue: return AppColor.danger
        case .urgent: return AppColor.danger
        case .soon: return AppColor.caution
        case .normal: return AppColor.secondary
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
