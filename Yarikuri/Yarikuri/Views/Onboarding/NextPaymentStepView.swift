import SwiftUI

// MARK: - 次の支払い入力（オンボーディング ステップ6）
struct NextPaymentStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var showAddForm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                stepHeader

                // あり・なし切り替え
                HStack(spacing: 12) {
                    PaymentToggleButton(
                        title: "ある",
                        emoji: "📅",
                        isSelected: vm.hasNextPayment,
                        onTap: { vm.hasNextPayment = true }
                    )
                    PaymentToggleButton(
                        title: "特にない",
                        emoji: "👍",
                        isSelected: !vm.hasNextPayment,
                        onTap: { vm.hasNextPayment = false }
                    )
                }
                .padding(.horizontal, 24)

                if vm.hasNextPayment {
                    paymentInputSection
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                HintCard(text: "大きな支払いとは、自動車税・医療費・旅行・家具の買い替えなど。1万円以上のものが目安です。")
                    .padding(.horizontal, 24)
            }
            .padding(.top, 16)
            .animation(.spring(response: 0.4), value: vm.hasNextPayment)
        }
    }

    // MARK: - 支払い入力セクション
    private var paymentInputSection: some View {
        VStack(spacing: 14) {
            // 追加済みリスト
            if !vm.scheduledPayments.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(vm.scheduledPayments.enumerated()), id: \.1.id) { index, payment in
                        PaymentListRow(payment: payment) {
                            vm.scheduledPayments.remove(at: index)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            // 追加フォーム
            if showAddForm {
                addPaymentForm
                    .padding(.horizontal, 24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Button(action: { withAnimation { showAddForm.toggle() } }) {
                Label(showAddForm ? "キャンセル" : "支払いを追加する", systemImage: showAddForm ? "xmark" : "plus.circle")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColor.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColor.tertiaryLight)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - 追加フォーム
    private var addPaymentForm: some View {
        VStack(spacing: 12) {
            TextField("支払いの名前（例: 自動車税）", text: $vm.newPaymentName)
                .padding()
                .background(AppColor.inputBackground)
                .cornerRadius(10)

            HStack {
                TextField("金額", text: $vm.newPaymentAmountText)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(AppColor.inputBackground)
                    .cornerRadius(10)
                Text("円").foregroundColor(AppColor.textSecondary)
            }

            DatePicker("支払い予定日", selection: $vm.newPaymentDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .padding()
                .background(AppColor.inputBackground)
                .cornerRadius(10)

            Button(action: {
                vm.addScheduledPayment()
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

private struct PaymentToggleButton: View {
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

private struct PaymentListRow: View {
    let payment: ScheduledPayment
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text("📅")
            VStack(alignment: .leading, spacing: 2) {
                Text(payment.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Text("\(payment.dueDate.monthDay) · \(payment.amount.yen)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill").foregroundColor(AppColor.textTertiary)
            }
        }
        .padding(12)
        .background(AppColor.cardBackground)
        .cornerRadius(10)
        .shadow(color: AppColor.shadowColor, radius: 3)
    }
}
