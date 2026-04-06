import SwiftUI
import Charts

private struct PaymentChartPoint: Identifiable {
    let id = UUID()
    let month: Int
    let amount: Int
    let year: Int
}

// MARK: - 支払い詳細画面
struct PaymentDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showAddPayment = false
    @State private var newPaymentName = ""
    @State private var newPaymentAmountText = ""
    @State private var newPaymentDate = Date()
    @State private var selectedChartMonth: Int? = nil
    @State private var editingRecordId: UUID? = nil
    @State private var editingSnapshotId: UUID? = nil
    @State private var editSnapshotName = ""
    @State private var editSnapshotAmountText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 今月の支払い合計
                        totalCard

                        // 支払い推移グラフ
                        paymentChartCard

                        // 支払い一覧
                        paymentListCard

                        // 過去の支払い明細
                        if !appState.scheduledPaymentHistory.isEmpty {
                            pastPaymentHistoryCard
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("変動費の詳細")
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
            .sheet(isPresented: Binding(
                get: { editingSnapshotId != nil },
                set: { if !$0 { editingSnapshotId = nil; editingRecordId = nil } }
            )) {
                editSnapshotSheet
            }
        }
    }

    // MARK: - 支払い推移グラフ
    private func paymentAmount(year: Int, month: Int) -> Int? {
        paymentChartPoints.first { $0.year == year && $0.month == month }?.amount
    }

    private var paymentChartPoints: [PaymentChartPoint] {
        appState.scheduledPaymentHistory.map {
            PaymentChartPoint(month: $0.month, amount: $0.totalAmount, year: $0.year)
        }
    }

    private var paymentYears: [Int] {
        Array(Set(appState.scheduledPaymentHistory.map { $0.year })).sorted()
    }

    private func paymentColor(for year: Int) -> Color {
        let colors: [Color] = [AppColor.tertiary, AppColor.caution, AppColor.safe, AppColor.primary]
        let idx = paymentYears.firstIndex(of: year) ?? 0
        return colors[idx % colors.count]
    }

    private var paymentYearlyTotals: [(year: Int, total: Int)] {
        let grouped = Dictionary(grouping: appState.scheduledPaymentHistory, by: { $0.year })
        return grouped.map { (year: $0.key, total: $0.value.reduce(0) { $0 + $1.totalAmount }) }
            .sorted { $0.year > $1.year }
    }

    private var paymentChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("支払いの推移")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                if !paymentYearlyTotals.isEmpty {
                    VStack(alignment: .trailing, spacing: 3) {
                        ForEach(paymentYearlyTotals, id: \.year) { item in
                            HStack(spacing: 5) {
                                Text(String(item.year) + "年")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColor.textTertiary)
                                Text(item.total.yen)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(paymentColor(for: item.year))
                            }
                        }
                    }
                }
            }

            // タップ時情報表示（固定高さ）
            ZStack {
                if let month = selectedChartMonth {
                    HStack(spacing: 12) {
                        Text("\(month)月")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        ForEach(paymentYears, id: \.self) { year in
                            if let amt = paymentAmount(year: year, month: month) {
                                Rectangle().fill(AppColor.sectionBackground).frame(width: 1, height: 32)
                                VStack(spacing: 2) {
                                    Text(String(year) + "年")
                                        .font(.system(size: 10))
                                        .foregroundColor(AppColor.textTertiary)
                                    Text(amt.yen)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(paymentColor(for: year))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColor.sectionBackground.opacity(0.8))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                } else {
                    Text("グラフをタップ・ドラッグして確認")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(height: 50)

            if paymentChartPoints.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 36))
                        .foregroundColor(AppColor.textTertiary.opacity(0.5))
                    Text("履歴データがまだありません")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
            } else {
                Chart {
                    ForEach(paymentChartPoints) { point in
                        AreaMark(
                            x: .value("月", point.month),
                            yStart: .value("支払い", 0),
                            yEnd: .value("支払い", point.amount),
                            series: .value("年", String(point.year))
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [paymentColor(for: point.year).opacity(0.22), paymentColor(for: point.year).opacity(0.0)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("月", point.month),
                            y: .value("支払い", point.amount),
                            series: .value("年", String(point.year))
                        )
                        .foregroundStyle(paymentColor(for: point.year))
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.catmullRom)
                        .shadow(color: paymentColor(for: point.year).opacity(0.35), radius: 4, x: 0, y: 2)

                        PointMark(
                            x: .value("月", point.month),
                            y: .value("支払い", point.amount)
                        )
                        .foregroundStyle(paymentColor(for: point.year))
                        .symbolSize(32)
                    }
                    if let month = selectedChartMonth {
                        RuleMark(x: .value("月", month))
                            .foregroundStyle(AppColor.textSecondary.opacity(0.4))
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        ForEach(paymentYears, id: \.self) { year in
                            if let amt = paymentAmount(year: year, month: month) {
                                PointMark(
                                    x: .value("月", month),
                                    y: .value("支払い", amt)
                                )
                                .foregroundStyle(paymentColor(for: year))
                                .symbolSize(80)
                            }
                        }
                    }
                }
                .chartXScale(domain: 1...12)
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("¥\(v / 10000)万")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColor.textTertiary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: [1, 3, 6, 9, 12]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.gray.opacity(0.18))
                        AxisValueLabel {
                            if let m = value.as(Int.self) {
                                Text("\(m)月")
                                    .font(.system(size: 9))
                                    .foregroundColor(AppColor.textTertiary)
                            }
                        }
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let originX = geo[proxy.plotAreaFrame].origin.x
                                        let xPos = value.location.x - originX
                                        guard xPos >= 0, xPos <= geo[proxy.plotAreaFrame].width else {
                                            selectedChartMonth = nil; return
                                        }
                                        if let raw: Int = proxy.value(atX: xPos) {
                                            selectedChartMonth = max(1, min(raw, 12))
                                        }
                                    }
                                    .onEnded { _ in selectedChartMonth = nil }
                            )
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - 合計カード
    private var totalCard: some View {
        let paidCount = appState.scheduledPayments.filter { $0.isPaid }.count
        let total     = appState.scheduledPayments.count
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("今月の変動費")
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
            Text("直近の変動費")
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

    // MARK: - 過去の支払い明細
    private var pastPaymentHistoryCard: some View {
        let sorted = appState.scheduledPaymentHistory.sorted {
            if $0.year != $1.year { return $0.year > $1.year }
            return $0.month > $1.month
        }
        return VStack(alignment: .leading, spacing: 12) {
            Text("過去の変動費")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            VStack(spacing: 12) {
                ForEach(sorted) { record in
                    VStack(alignment: .leading, spacing: 0) {
                        // 月ヘッダー
                        HStack {
                            Text(String(record.year) + "年" + String(record.month) + "月")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)
                            Spacer()
                            Text("合計 " + record.totalAmount.yen)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppColor.caution)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppColor.sectionBackground)

                        // 個別明細
                        if record.payments.isEmpty {
                            Text("明細なし")
                                .font(.system(size: 13))
                                .foregroundColor(AppColor.textTertiary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppColor.cardBackground)
                        } else {
                            ForEach(Array(record.payments.enumerated()), id: \.element.id) { idx, payment in
                                HStack(spacing: 8) {
                                    Text(payment.name)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColor.textPrimary)
                                    Spacer()
                                    Text(payment.amount.yen)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppColor.textPrimary)
                                    Button {
                                        editSnapshotName = payment.name
                                        editSnapshotAmountText = String(payment.amount)
                                        editingSnapshotId = payment.id
                                        editingRecordId = record.id
                                    } label: {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppColor.primary)
                                            .frame(width: 28, height: 28)
                                    }
                                    .buttonStyle(.plain)
                                    Button {
                                        deleteSnapshot(recordId: record.id, snapshotId: payment.id)
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppColor.caution)
                                            .frame(width: 28, height: 28)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(AppColor.cardBackground)

                                if idx < record.payments.count - 1 {
                                    Divider().padding(.leading, 14)
                                }
                            }
                        }
                    }
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                }
            }
        }
        .cardStyle()
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

    // MARK: - 過去の明細：削除・更新
    private func deleteSnapshot(recordId: UUID, snapshotId: UUID) {
        guard let recIdx = appState.scheduledPaymentHistory.firstIndex(where: { $0.id == recordId }) else { return }
        appState.scheduledPaymentHistory[recIdx].payments.removeAll { $0.id == snapshotId }
        appState.scheduledPaymentHistory[recIdx].totalAmount = appState.scheduledPaymentHistory[recIdx].payments.reduce(0) { $0 + $1.amount }
    }

    private func saveSnapshotEdit() {
        guard let recIdx = appState.scheduledPaymentHistory.firstIndex(where: { $0.id == editingRecordId }),
              let snapIdx = appState.scheduledPaymentHistory[recIdx].payments.firstIndex(where: { $0.id == editingSnapshotId }),
              let amount = Int(editSnapshotAmountText), !editSnapshotName.isEmpty else { return }
        appState.scheduledPaymentHistory[recIdx].payments[snapIdx].name = editSnapshotName
        appState.scheduledPaymentHistory[recIdx].payments[snapIdx].amount = amount
        appState.scheduledPaymentHistory[recIdx].totalAmount = appState.scheduledPaymentHistory[recIdx].payments.reduce(0) { $0 + $1.amount }
        editingSnapshotId = nil
        editingRecordId = nil
    }

    // MARK: - 過去の明細：編集シート
    private var editSnapshotSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("支払いの名前").font(.caption).foregroundColor(AppColor.textSecondary)
                    TextField("例: 自動車税", text: $editSnapshotName)
                        .padding()
                        .background(AppColor.inputBackground)
                        .cornerRadius(10)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("金額").font(.caption).foregroundColor(AppColor.textSecondary)
                    TextField("例: 34500", text: $editSnapshotAmountText)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(AppColor.inputBackground)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding(24)
            .navigationTitle("明細を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") { saveSnapshotEdit() }
                        .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { editingSnapshotId = nil; editingRecordId = nil }
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
