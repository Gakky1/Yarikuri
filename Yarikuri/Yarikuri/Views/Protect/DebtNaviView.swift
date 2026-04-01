import SwiftUI
import Charts

// MARK: - 借金・リボ返済ナビ画面
struct DebtNaviView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showAddDebt = false
    @State private var showReport  = false
    @State private var newName = ""
    @State private var newBalance = ""
    @State private var newMonthly = ""
    @State private var newRate = ""
    @State private var newType: DebtType = .other
    @State private var newPaymentDay: Int = 27
    @State private var editingDebt: Debt? = nil

    // 優先度順（金利高い順）でソート
    private var sortedDebts: [Debt] {
        appState.debts.sorted { $0.priorityScore > $1.priorityScore }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        if appState.debts.isEmpty {
                            emptyState
                        } else {
                            // 合計カード
                            totalDebtCard

                            // 返済シミュレーショングラフ
                            DebtRepaymentChartView(debts: appState.debts)

                            // 借金リスト（優先度順）
                            ForEach(Array(sortedDebts.enumerated()), id: \.1.id) { index, debt in
                                DebtDetailCard(debt: debt, priority: index + 1,
                                    onDelete: { appState.debts.removeAll { $0.id == debt.id } },
                                    onEdit: { editingDebt = debt }
                                )
                            }
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("借金返済ナビ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 14) {
                        Button(action: { showReport = true }) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(AppColor.primary)
                        }
                        Button(action: { showAddDebt = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(AppColor.primary)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
            .sheet(isPresented: $showAddDebt) { addDebtSheet }
            .sheet(isPresented: $showReport) {
                MonthlyReportView().environmentObject(appState)
            }
            .sheet(item: $editingDebt) { debt in
                editDebtSheet(debt: debt)
            }
        }
    }

    // MARK: - 空状態
    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("✨").font(.system(size: 52))
            Text("借金はゼロです！")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColor.textPrimary)
            Text("この状態をキープしましょう。\nもし借金が増えた場合は右上の＋から入力できます。")
                .font(.system(size: 14))
                .foregroundColor(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .cardStyle()
    }

    // MARK: - 合計カード
    private var totalDebtCard: some View {
        let total = appState.debts.reduce(0) { $0 + $1.remainingBalance }
        let monthly = appState.debts.reduce(0) { $0 + $1.monthlyPayment }
        let maxMonths = appState.debts.compactMap { $0.estimatedMonthsToPayoff }.max() ?? 0
        let payoffText: String = {
            if maxMonths <= 0 { return "—" }
            let y = maxMonths / 12; let m = maxMonths % 12
            if y == 0 { return "\(m)ヶ月" }
            if m == 0 { return "\(y)年" }
            return "\(y)年\(m)ヶ月"
        }()
        return HStack(spacing: 0) {
            VStack(spacing: 3) {
                Text("借金残高合計")
                    .font(.system(size: 11)).foregroundColor(AppColor.textSecondary)
                Text(total.yen)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColor.danger)
                    .minimumScaleFactor(0.7).lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            Divider().frame(height: 44)
            VStack(spacing: 3) {
                Text("月返済額")
                    .font(.system(size: 11)).foregroundColor(AppColor.textSecondary)
                Text(monthly.yen)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColor.caution)
                    .minimumScaleFactor(0.7).lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            Divider().frame(height: 44)
            VStack(spacing: 3) {
                Text("完済まで")
                    .font(.system(size: 11)).foregroundColor(AppColor.textSecondary)
                Text(payoffText)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColor.primary)
                    .minimumScaleFactor(0.7).lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .cardStyle()
    }

    // MARK: - 優先度説明
    private var priorityExplanation: some View {
        HStack(spacing: 8) {
            Text("💡").font(.system(size: 14))
            Text("金利の高い借金から返すと、利息が減ります")
                .font(.system(size: 12))
                .foregroundColor(AppColor.textSecondary)
        }
        .padding(10)
        .background(AppColor.tertiaryLight)
        .cornerRadius(10)
    }

    // MARK: - 完済目標カード
    private var payoffGoalCard: some View {
        let monthlyTotal = appState.debts.reduce(0) { $0 + $1.monthlyPayment }
        return HStack(spacing: 12) {
            Text("🎯").font(.system(size: 28))
            VStack(alignment: .leading, spacing: 3) {
                Text("完済したら毎月\(monthlyTotal.yen)が自由に！")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColor.secondary)
                Text("貯金や投資に回せます")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(AppColor.secondaryLight)
        .cornerRadius(14)
    }

    // MARK: - 追加シート
    private var addDebtSheet: some View {
        NavigationStack {
            Form {
                Section("借入先") {
                    TextField("例: ○○カード、消費者金融A", text: $newName)
                    Picker("種類", selection: $newType) {
                        ForEach(DebtType.allCases, id: \.rawValue) { type in
                            Text("\(type.emoji) \(type.displayText)").tag(type)
                        }
                    }
                }
                Section("金額") {
                    TextField("残高（円）", text: $newBalance).keyboardType(.numberPad)
                    TextField("毎月の返済額（円）", text: $newMonthly).keyboardType(.numberPad)
                    TextField("金利（%、任意）", text: $newRate).keyboardType(.decimalPad)
                }
                Section("返済日") {
                    Picker("返済日", selection: $newPaymentDay) {
                        ForEach(1...31, id: \.self) { Text("毎月\($0)日").tag($0) }
                    }
                }
            }
            .navigationTitle("借金を追加")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("追加") {
                        if let balance = Int(newBalance), let monthly = Int(newMonthly), !newName.isEmpty {
                            let debt = Debt(
                                lenderName: newName, remainingBalance: balance, monthlyPayment: monthly,
                                interestRate: Double(newRate), debtType: newType, paymentDay: newPaymentDay
                            )
                            appState.debts.append(debt)
                            showAddDebt = false
                        }
                    }
                    .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { showAddDebt = false }
                }
            }
        }
    }

    // MARK: - 借金編集シート
    @ViewBuilder
    private func editDebtSheet(debt: Debt) -> some View {
        DebtEditSheet(debt: debt) { updated in
            if let idx = appState.debts.firstIndex(where: { $0.id == debt.id }) {
                appState.debts[idx] = updated
            }
        }
    }
}

// MARK: - 借金編集シート（内部）
private struct DebtEditSheet: View {
    let debt: Debt
    let onSave: (Debt) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var balanceText: String
    @State private var monthlyText: String
    @State private var rateText: String
    @State private var debtType: DebtType
    @State private var paymentDay: Int

    init(debt: Debt, onSave: @escaping (Debt) -> Void) {
        self.debt = debt
        self.onSave = onSave
        _name        = State(initialValue: debt.lenderName)
        _balanceText = State(initialValue: "\(debt.remainingBalance)")
        _monthlyText = State(initialValue: "\(debt.monthlyPayment)")
        _rateText    = State(initialValue: debt.interestRate.map { String($0) } ?? "")
        _debtType    = State(initialValue: debt.debtType)
        _paymentDay  = State(initialValue: debt.paymentDay)
    }

    private var canSave: Bool {
        !name.isEmpty
        && (Int(balanceText) ?? 0) > 0
        && (Int(monthlyText) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("借入先") {
                    TextField("例: ○○カード、消費者金融A", text: $name)
                    Picker("種類", selection: $debtType) {
                        ForEach(DebtType.allCases, id: \.rawValue) { type in
                            Text("\(type.emoji) \(type.displayText)").tag(type)
                        }
                    }
                }
                Section("金額") {
                    HStack {
                        Text("残高（円）")
                        Spacer()
                        TextField("0", text: $balanceText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 140)
                    }
                    HStack {
                        Text("毎月の返済額（円）")
                        Spacer()
                        TextField("0", text: $monthlyText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 140)
                    }
                    HStack {
                        Text("金利（%、任意）")
                        Spacer()
                        TextField("未入力", text: $rateText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
                Section("返済日") {
                    Picker("返済日", selection: $paymentDay) {
                        ForEach(1...31, id: \.self) { Text("毎月\($0)日").tag($0) }
                    }
                }
            }
            .navigationTitle("借金を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        guard let balance = Int(balanceText), let monthly = Int(monthlyText) else { return }
                        var updated = debt
                        updated.lenderName       = name
                        updated.remainingBalance = balance
                        updated.monthlyPayment   = monthly
                        updated.interestRate     = Double(rateText)
                        updated.debtType         = debtType
                        updated.paymentDay       = paymentDay
                        onSave(updated)
                        dismiss()
                    }
                    .foregroundColor(canSave ? AppColor.primary : AppColor.textTertiary)
                    .disabled(!canSave)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 借金詳細カード
private struct DebtDetailCard: View {
    let debt: Debt
    let priority: Int
    let onDelete: () -> Void
    let onEdit:   () -> Void

    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(spacing: 12) {
            // ヘッダー
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(debt.debtType.emoji)
                        Text(debt.lenderName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)
                    }
                    if let rate = debt.interestRate {
                        Text("年利\(String(format: "%.1f", rate))%")
                            .font(.system(size: 12))
                            .foregroundColor(dangerColor)
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("残高")
                            .font(.system(size: 11))
                            .foregroundColor(AppColor.textTertiary)
                        Text(debt.remainingBalance.man)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColor.danger)
                    }
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 18))
                            .foregroundColor(AppColor.primary)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    Button(action: { showDeleteConfirm = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(AppColor.danger)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
            }
            .confirmationDialog("この借金を削除しますか？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("削除", role: .destructive) { onDelete() }
                Button("キャンセル", role: .cancel) {}
            }

            // リボ警告
            if let warning = debt.debtType.warningMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.danger)
                    Text(warning)
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.danger)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .background(AppColor.dangerLight)
                .cornerRadius(8)
            }

            // 返済詳細
            HStack(spacing: 0) {
                debtMetric(label: "毎月返済", value: debt.monthlyPayment.yen)
                divider
                debtMetric(
                    label: "完済まで約",
                    value: debt.estimatedMonthsToPayoff.map { formatMonths($0) } ?? "不明"
                )
                divider
                debtMetric(label: "返済日", value: "毎月\(debt.paymentDay)日")
            }
        }
        .cardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(debt.dangerLevel == .high ? AppColor.danger.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
    }

    private var priorityColor: Color {
        switch priority {
        case 1: return AppColor.danger
        case 2: return AppColor.caution
        default: return AppColor.secondary
        }
    }

    private var dangerColor: Color {
        switch debt.dangerLevel {
        case .high: return AppColor.danger
        case .medium: return AppColor.caution
        case .low: return AppColor.secondary
        }
    }

    private func formatMonths(_ months: Int) -> String {
        let years = months / 12
        let rem   = months % 12
        if years == 0 { return "\(rem)ヶ月" }
        if rem   == 0 { return "\(years)年" }
        return "\(years)年\(rem)ヶ月"
    }

    private func debtMetric(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.system(size: 11)).foregroundColor(AppColor.textTertiary)
            Text(value).font(.system(size: 13, weight: .semibold)).foregroundColor(AppColor.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle().fill(AppColor.sectionBackground).frame(width: 1, height: 36)
    }
}

// MARK: - 返済シミュレーショングラフ
struct DebtRepaymentChartView: View {
    let debts: [Debt]

    // MARK: データモデル
    private struct BalancePoint: Identifiable {
        let id = UUID()
        let month: Int
        let balance: Double   // 円
        let isFuture: Bool    // false = 推定過去
    }

    private struct DebtTimelinePoint: Identifiable {
        let id = UUID()
        let month: Int
        let balance: Double
        let debtId: UUID
    }

    // MARK: 計算
    private var maxFutureMonths: Int {
        let m = debts.compactMap { $0.estimatedMonthsToPayoff }.max() ?? 60
        return max(min(m, 120), 1)
    }

    private func balanceAt(debt: Debt, month: Int) -> Double {
        // month < 0 → 過去（線形逆算）
        if month < 0 {
            return Double(debt.remainingBalance) + Double(debt.monthlyPayment) * Double(abs(month))
        }
        var b = Double(debt.remainingBalance)
        let r = (debt.interestRate ?? 0.0) / 100.0 / 12.0
        for _ in 0..<month {
            guard b > 0 else { return 0 }
            b = r > 0 ? b * (1.0 + r) - Double(debt.monthlyPayment)
                      : b - Double(debt.monthlyPayment)
            b = max(0, b)
        }
        return b
    }

    private var allPoints: [BalancePoint] {
        let maxM = maxFutureMonths
        let step = maxM <= 24 ? 1 : maxM <= 60 ? 2 : 3
        var pts: [BalancePoint] = []
        // 今（month=0）から完済まで
        var m = 0
        while m <= maxM {
            let total = debts.reduce(0.0) { $0 + balanceAt(debt: $1, month: m) }
            pts.append(BalancePoint(month: m, balance: total, isFuture: true))
            if m == maxM { break }
            m = min(m + step, maxM)
        }
        return pts
    }

    private var futurePoints: [BalancePoint] { allPoints }

    // 各借金の残高推移（個別タイムライン用）
    private func timelinePoints(for debt: Debt) -> [DebtTimelinePoint] {
        let months = debt.estimatedMonthsToPayoff ?? maxFutureMonths
        let step = months <= 24 ? 2 : months <= 60 ? 4 : 6
        var pts: [DebtTimelinePoint] = []
        var m = 0
        while m <= months {
            pts.append(DebtTimelinePoint(month: m, balance: balanceAt(debt: debt, month: m), debtId: debt.id))
            if m == months { break }
            m = min(m + step, months)
        }
        return pts
    }

    private var maxBalance: Double {
        allPoints.map { $0.balance }.max() ?? 1
    }

    private var totalInterestEstimate: Int {
        debts.reduce(0) { sum, debt in
            guard let months = debt.estimatedMonthsToPayoff else { return sum }
            let totalPaid = debt.monthlyPayment * months
            let interest  = max(0, totalPaid - debt.remainingBalance)
            return sum + interest
        }
    }

    private var monthlyFreeAfterPayoff: Int {
        debts.reduce(0) { $0 + $1.monthlyPayment }
    }

    private var payoffText: String {
        let m = maxFutureMonths
        let y = m / 12; let mo = m % 12
        if y == 0 { return "\(mo)ヶ月後" }
        if mo == 0 { return "\(y)年後" }
        return "\(y)年\(mo)ヶ月後"
    }

    private func xLabel(_ m: Int) -> String {
        if m == 0 { return "今" }
        if m == maxFutureMonths { return "完済" }
        let y = m / 12; let mo = m % 12
        if y == 0 { return "\(mo)ヶ月" }
        if mo == 0 { return "\(y)年" }
        return "\(y)年"
    }

    private var xAxisValues: [Int] {
        let maxM = maxFutureMonths
        var vals: [Int] = [0]
        let interval = maxM <= 24 ? 6 : 12
        var v = interval
        while v < maxM {
            vals.append(v)
            v += interval
        }
        vals.append(maxM) // 完済（右端）
        return vals.sorted()
    }

    private func debtColor(index: Int) -> Color {
        [AppColor.danger, AppColor.caution, AppColor.secondary, AppColor.tertiary][index % 4]
    }

    private func formatMonths(_ months: Int) -> String {
        let y = months / 12; let m = months % 12
        if y == 0 { return "\(m)ヶ月" }
        if m == 0 { return "\(y)年" }
        return "\(y)年\(m)ヶ月"
    }

    // MARK: タップ選択状態
    @State private var selectedMonth: Int? = nil
    @State private var selectedBalance: Double? = nil

    // MARK: Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // ── ヘッダー
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("📉 返済シミュレーション")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    Text("このペースで返済を続けると…")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("完済まで")
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.textTertiary)
                    Text(payoffText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColor.primary)
                }
            }

            // ── タップ時の情報表示
            if let month = selectedMonth, let balance = selectedBalance {
                HStack(spacing: 12) {
                    VStack(spacing: 2) {
                        Text("残高")
                            .font(.system(size: 10))
                            .foregroundColor(AppColor.textTertiary)
                        Text(Int(balance).yen)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColor.danger)
                    }
                    Rectangle()
                        .fill(AppColor.sectionBackground)
                        .frame(width: 1, height: 32)
                    VStack(spacing: 2) {
                        Text("完済まで")
                            .font(.system(size: 10))
                            .foregroundColor(AppColor.textTertiary)
                        Text(month == 0 ? "今" : formatMonths(month))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColor.primary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppColor.sectionBackground.opacity(0.8))
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .transition(.opacity)
            } else {
                Text("グラフをタップ・ドラッグすると残高を確認できます")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            // ── メインチャート
            Chart {
                // 未来：グラデーションエリア
                ForEach(futurePoints) { pt in
                    AreaMark(
                        x: .value("月", pt.month),
                        y: .value("残高", pt.balance / 10000.0)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColor.danger.opacity(0.28), AppColor.secondary.opacity(0.07)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("月", pt.month),
                        y: .value("残高", pt.balance / 10000.0)
                    )
                    .foregroundStyle(AppColor.danger.opacity(0.85))
                    .lineStyle(StrokeStyle(lineWidth: 2.2))
                    .interpolationMethod(.catmullRom)
                }

                // 選択中の縦線＋ドット
                if let month = selectedMonth, let balance = selectedBalance {
                    RuleMark(x: .value("月", month))
                        .foregroundStyle(AppColor.primary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                    PointMark(
                        x: .value("月", month),
                        y: .value("残高", balance / 10000.0)
                    )
                    .foregroundStyle(AppColor.primary)
                    .symbolSize(60)
                }
            }
            .chartXScale(domain: 0...maxFutureMonths)
            .chartYScale(domain: 0...(maxBalance / 10000.0 * 1.08))
            .chartXAxis {
                AxisMarks(values: xAxisValues) { val in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.gray.opacity(0.18))
                    AxisValueLabel {
                        if let m = val.as(Int.self) {
                            Text(xLabel(m))
                                .font(.system(size: 9))
                                .foregroundColor(AppColor.textTertiary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { val in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.gray.opacity(0.18))
                    AxisValueLabel {
                        if let v = val.as(Double.self), v >= 0 {
                            Text(v >= 1 ? "\(Int(v))万" : "0")
                                .font(.system(size: 9))
                                .foregroundColor(AppColor.textTertiary)
                        }
                    }
                }
            }
            .frame(height: 190)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let plotOriginX = geo[proxy.plotAreaFrame].origin.x
                                    let xPos = value.location.x - plotOriginX
                                    guard xPos >= 0, xPos <= geo[proxy.plotAreaFrame].width else {
                                        selectedMonth = nil; selectedBalance = nil; return
                                    }
                                    if let rawMonth: Int = proxy.value(atX: xPos) {
                                        let clamped = max(0, min(rawMonth, maxFutureMonths))
                                        if let nearest = allPoints.min(by: {
                                            abs($0.month - clamped) < abs($1.month - clamped)
                                        }) {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                selectedMonth = nearest.month
                                                selectedBalance = nearest.balance
                                            }
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        selectedMonth = nil
                                        selectedBalance = nil
                                    }
                                }
                        )
                }
            }

            // ── フッター統計
            footerStatsRow
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 8, x: 0, y: 2)
    }

    // MARK: フッター統計
    @ViewBuilder
    private var footerStatsRow: some View {
        HStack(spacing: 0) {
            // 支払い利息
            if totalInterestEstimate > 0 {
                VStack(spacing: 3) {
                    Text("⚠️ 支払い利息の目安")
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.textTertiary)
                    Text("約\(totalInterestEstimate.yen)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppColor.caution)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(AppColor.sectionBackground)
                    .frame(width: 1, height: 36)
            }

            // 完済後の余裕
            VStack(spacing: 3) {
                Text("🎯 完済後に増える余裕")
                    .font(.system(size: 10))
                    .foregroundColor(AppColor.textTertiary)
                Text("月+\(monthlyFreeAfterPayoff.yen)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColor.safe)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 10)
        .background(AppColor.sectionBackground.opacity(0.6))
        .cornerRadius(10)
    }
}

#Preview {
    DebtNaviView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
