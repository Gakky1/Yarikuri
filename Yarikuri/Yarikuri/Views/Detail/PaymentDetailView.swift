import SwiftUI

// MARK: - 支払い詳細画面
struct PaymentDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showAddPayment = false
    @State private var newPaymentName = ""
    @State private var newPaymentAmountText = ""
    @State private var newPaymentDate = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 今月の支払い合計
                        totalCard

                        // 支払い一覧
                        paymentListCard

                        // 固定費からの自動追加
                        fixedFromDebtCard

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("支払い詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showAddPayment = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppColor.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
            .sheet(isPresented: $showAddPayment) {
                addPaymentSheet
            }
        }
    }

    // MARK: - 合計カード
    private var totalCard: some View {
        let paidCount = appState.scheduledPayments.filter { $0.isPaid }.count
        let total     = appState.scheduledPayments.count
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("支払い予定合計（未払い）")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
                Text(appState.totalAllUnpaidPayments.yen)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                if paidCount > 0 {
                    Text("済み \(paidCount)/\(total)件")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.secondary)
                }
            }
            Spacer()
            Text("📅")
                .font(.system(size: 36))
        }
        .cardStyle()
    }

    // MARK: - 支払いリスト
    private var paymentListCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("支払い一覧")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            if appState.scheduledPayments.isEmpty {
                Text("支払い予定はありません")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(appState.scheduledPayments.sorted { $0.dueDate < $1.dueDate }) { payment in
                        PaymentRow(payment: payment)
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - 借金からの返済
    private var fixedFromDebtCard: some View {
        Group {
            if !appState.debts.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("毎月の返済（自動計上）")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColor.textSecondary)
                        Spacer()
                        Text("固定費に含む")
                            .font(.system(size: 11))
                            .foregroundColor(AppColor.textTertiary)
                    }

                    ForEach(appState.debts) { debt in
                        HStack {
                            Text(debt.debtType.emoji)
                            Text(debt.lenderName)
                                .font(.system(size: 14))
                                .foregroundColor(AppColor.textPrimary)
                            Spacer()
                            Text("毎月\(debt.paymentDay)日")
                                .font(.system(size: 12))
                                .foregroundColor(AppColor.textTertiary)
                            Text(debt.monthlyPayment.yen)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColor.danger)
                        }
                        .padding(10)
                        .background(AppColor.dangerLight)
                        .cornerRadius(8)
                    }
                }
                .cardStyle()
            }
        }
    }

    // MARK: - 追加シート
    private var addPaymentSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("支払いの名前").font(.caption).foregroundColor(AppColor.textSecondary)
                    TextField("例: 自動車税", text: $newPaymentName)
                        .padding()
                        .background(AppColor.inputBackground)
                        .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("金額").font(.caption).foregroundColor(AppColor.textSecondary)
                    TextField("例: 34500", text: $newPaymentAmountText)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(AppColor.inputBackground)
                        .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("支払い予定日").font(.caption).foregroundColor(AppColor.textSecondary)
                    DatePicker("", selection: $newPaymentDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("支払いを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("追加") {
                        if let amount = Int(newPaymentAmountText), !newPaymentName.isEmpty {
                            let payment = ScheduledPayment(name: newPaymentName, amount: amount, dueDate: newPaymentDate)
                            appState.scheduledPayments.append(payment)
                            showAddPayment = false
                        }
                    }
                    .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { showAddPayment = false }
                }
            }
        }
    }
}

#Preview {
    PaymentDetailView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
