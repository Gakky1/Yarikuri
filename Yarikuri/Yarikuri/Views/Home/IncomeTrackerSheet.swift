import SwiftUI
import Charts

private struct IncomeChartPoint: Identifiable {
    let id = UUID()
    let month: Int
    let amount: Int
    let year: Int
}

// MARK: - 収入トラッカーシート
struct IncomeTrackerSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showingDeleteAlert = false
    @State private var recordToDelete: IncomeRecord?
    @State private var recordToEdit: IncomeRecord? = nil
    @State private var selectedChartMonth: Int? = nil
    @State private var showAddIncome = false

    private var totalThisYear: Int {
        let year = Calendar.current.component(.year, from: Date())
        return appState.incomeHistory
            .filter { $0.year == year }
            .reduce(0) { $0 + $1.amount }
    }

    private var yearlyTotals: [(year: Int, total: Int)] {
        let grouped = Dictionary(grouping: appState.incomeHistory, by: { $0.year })
        return grouped.map { (year: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.year > $1.year }
    }

    private func incomeAmount(year: Int, month: Int) -> Int? {
        incomeChartPoints.first { $0.year == year && $0.month == month }?.amount
    }

    private var incomeChartPoints: [IncomeChartPoint] {
        appState.incomeHistory.map { IncomeChartPoint(month: $0.month, amount: $0.amount, year: $0.year) }
    }

    private var incomeYears: [Int] {
        Array(Set(appState.incomeHistory.map { $0.year })).sorted()
    }

    private func incomeColor(for year: Int) -> Color {
        let colors: [Color] = [AppColor.tertiary, AppColor.safe, AppColor.secondary, AppColor.caution]
        let idx = incomeYears.firstIndex(of: year) ?? 0
        return colors[idx % colors.count]
    }

    private var averageMonthly: Int {
        guard !appState.incomeHistory.isEmpty else { return 0 }
        return appState.incomeHistory.reduce(0) { $0 + $1.amount } / appState.incomeHistory.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !appState.incomeHistory.isEmpty {
                        summarySection
                    }
                    chartSection
                    if !appState.incomeHistory.isEmpty {
                        historySection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(AppColor.background)
            .navigationTitle("収入")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showAddIncome = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppColor.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeSheet { record in
                    if let idx = appState.incomeHistory.firstIndex(where: { $0.year == record.year && $0.month == record.month }) {
                        appState.incomeHistory[idx] = record
                    } else {
                        appState.incomeHistory.append(record)
                    }
                }
            }
            .sheet(item: $recordToEdit) { record in
                IncomeEditSheet(record: record) { updated in
                    if let idx = appState.incomeHistory.firstIndex(where: { $0.id == updated.id }) {
                        appState.incomeHistory[idx] = updated
                    }
                }
            }
        }
    }

    // MARK: - サマリー
    private var summarySection: some View {
        HStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("今年の合計")
                    .font(.system(size: 11)).foregroundColor(AppColor.textSecondary)
                Text(totalThisYear.yen)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColor.safe)
                    .minimumScaleFactor(0.7).lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            Divider().frame(height: 36)
            VStack(spacing: 2) {
                Text("月平均")
                    .font(.system(size: 11)).foregroundColor(AppColor.textSecondary)
                Text(averageMonthly.yen)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColor.primary)
                    .minimumScaleFactor(0.7).lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 6)
        .cardStyle()
    }

    private var thisYear: Int { Calendar.current.component(.year, from: Date()) }

    // MARK: - グラフ
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("収入の推移")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                if !yearlyTotals.isEmpty {
                    VStack(alignment: .trailing, spacing: 3) {
                        ForEach(yearlyTotals, id: \.year) { item in
                            HStack(spacing: 5) {
                                Text(String(item.year) + "年")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColor.textTertiary)
                                Text(item.total.yen)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(incomeColor(for: item.year))
                            }
                        }
                    }
                }
            }

            ZStack {
                if let month = selectedChartMonth {
                    HStack(spacing: 12) {
                        Text("\(month)月")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        ForEach(incomeYears, id: \.self) { year in
                            if let amt = incomeAmount(year: year, month: month) {
                                Rectangle().fill(AppColor.sectionBackground).frame(width: 1, height: 32)
                                VStack(spacing: 2) {
                                    Text(String(year) + "年")
                                        .font(.system(size: 10))
                                        .foregroundColor(AppColor.textTertiary)
                                    Text(amt.yen)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(incomeColor(for: year))
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

            if incomeChartPoints.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 36))
                        .foregroundColor(AppColor.textTertiary.opacity(0.5))
                    Text("収入を記録するとグラフが表示されます")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
            } else {
                Chart {
                    ForEach(incomeChartPoints) { point in
                        AreaMark(
                            x: .value("月", point.month),
                            yStart: .value("収入", 0),
                            yEnd: .value("収入", point.amount),
                            series: .value("年", String(point.year))
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [incomeColor(for: point.year).opacity(0.22), incomeColor(for: point.year).opacity(0.0)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("月", point.month),
                            y: .value("収入", point.amount),
                            series: .value("年", String(point.year))
                        )
                        .foregroundStyle(incomeColor(for: point.year))
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.catmullRom)
                        .shadow(color: incomeColor(for: point.year).opacity(0.35), radius: 4, x: 0, y: 2)

                        PointMark(
                            x: .value("月", point.month),
                            y: .value("収入", point.amount)
                        )
                        .foregroundStyle(incomeColor(for: point.year))
                        .symbolSize(32)
                    }
                    if let month = selectedChartMonth {
                        RuleMark(x: .value("月", month))
                            .foregroundStyle(AppColor.textSecondary.opacity(0.4))
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        ForEach(incomeYears, id: \.self) { year in
                            if let amt = incomeAmount(year: year, month: month) {
                                PointMark(
                                    x: .value("月", month),
                                    y: .value("収入", amt)
                                )
                                .foregroundStyle(incomeColor(for: year))
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
                                        let originX = geo[proxy.plotFrame].origin.x
                                        let xPos = value.location.x - originX
                                        guard xPos >= 0, xPos <= geo[proxy.plotFrame].width else {
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
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
    }

    // MARK: - 履歴テーブル
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("収入履歴")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textPrimary)

            VStack(spacing: 1) {
                ForEach(appState.incomeHistory.sorted {
                    if $0.year != $1.year { return $0.year > $1.year }
                    if $0.month != $1.month { return $0.month > $1.month }
                    return $0.day > $1.day
                }) { record in
                    HStack(spacing: 10) {
                        // カテゴリ絵文字
                        Text(record.category.emoji)
                            .font(.system(size: 24))
                            .frame(width: 36)

                        // 名前・日付・メモ
                        VStack(alignment: .leading, spacing: 2) {
                            Text(record.name.isEmpty ? record.category.displayText : record.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColor.textPrimary)
                            Text("\(record.year)年\(record.month)月\(record.day)日・\(record.category.displayText)")
                                .font(.system(size: 11))
                                .foregroundColor(AppColor.textTertiary)
                            if !record.note.isEmpty {
                                Text(record.note)
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColor.textTertiary)
                            }
                        }

                        Spacer()

                        // 金額 + 操作ボタン
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("¥\(record.amount.formattedYen)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColor.textPrimary)
                            HStack(spacing: 8) {
                                Button(action: { recordToEdit = record }) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColor.primary)
                                }
                                Button(action: {
                                    recordToDelete = record
                                    showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColor.danger)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppColor.cardBackground)
                }
            }
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        .alert("削除しますか？", isPresented: $showingDeleteAlert) {
            Button("削除", role: .destructive) {
                if let r = recordToDelete {
                    appState.incomeHistory.removeAll { $0.id == r.id }
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            if let r = recordToDelete {
                Text("\(r.year)年\(r.month)月\(r.day)日の収入記録を削除します")
            }
        }
    }
}

// MARK: - 収入追加シート
private struct AddIncomeSheet: View {
    let onSave: (IncomeRecord) -> Void
    @Environment(\.dismiss) private var dismiss

    private var years: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array((current - 5)...current).reversed()
    }

    @State private var selectedYear:  Int = Calendar.current.component(.year,  from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedDay:   Int = Calendar.current.component(.day,   from: Date())
    @State private var nameText:      String = ""
    @State private var amountText:    String = ""
    @State private var category:      IncomeCategory = .salary
    @State private var noteText:      String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("収入の名前（例：4月分給与）", text: $nameText)
                    HStack {
                        Text("¥").foregroundColor(AppColor.primary).fontWeight(.bold)
                        TextField("手取り金額", text: $amountText)
                            .keyboardType(.numberPad)
                    }
                    Picker("カテゴリ", selection: $category) {
                        ForEach(IncomeCategory.allCases, id: \.rawValue) { cat in
                            Text(cat.emoji + " " + cat.displayText).tag(cat)
                        }
                    }
                }
                Section("日付") {
                    Picker("年", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year) + "年").tag(year)
                        }
                    }
                    Picker("月", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text("\(month)月").tag(month)
                        }
                    }
                    Picker("日", selection: $selectedDay) {
                        ForEach(1...31, id: \.self) { day in
                            Text("\(day)日").tag(day)
                        }
                    }
                }
                Section("メモ") {
                    TextField("任意", text: $noteText)
                }
            }
            .navigationTitle("収入を入力")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        guard let amount = Int(amountText.filter { $0.isNumber }), amount > 0 else { return }
                        let record = IncomeRecord(
                            year: selectedYear, month: selectedMonth, day: selectedDay,
                            amount: amount, name: nameText, category: category, note: noteText
                        )
                        onSave(record)
                        dismiss()
                    }
                    .foregroundColor(amountText.isEmpty ? AppColor.textTertiary : AppColor.primary)
                    .disabled(amountText.isEmpty)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 収入編集シート
private struct IncomeEditSheet: View {
    let record: IncomeRecord
    let onSave: (IncomeRecord) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var nameText:     String
    @State private var amountText:   String
    @State private var category:     IncomeCategory
    @State private var selectedDay:  Int
    @State private var noteText:     String

    init(record: IncomeRecord, onSave: @escaping (IncomeRecord) -> Void) {
        self.record = record
        self.onSave = onSave
        _nameText    = State(initialValue: record.name)
        _amountText  = State(initialValue: "\(record.amount)")
        _category    = State(initialValue: record.category)
        _selectedDay = State(initialValue: record.day)
        _noteText    = State(initialValue: record.note)
    }

    private var canSave: Bool {
        (Int(amountText.filter { $0.isNumber }) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    // 年月は変更不可（識別子）
                    HStack {
                        Text("年月").foregroundColor(AppColor.textSecondary)
                        Spacer()
                        Text(record.displayLabel).foregroundColor(AppColor.textTertiary)
                    }
                    TextField("収入の名前", text: $nameText)
                    HStack {
                        Text("¥").foregroundColor(AppColor.primary).fontWeight(.bold)
                        TextField("手取り金額", text: $amountText)
                            .keyboardType(.numberPad)
                    }
                    Picker("カテゴリ", selection: $category) {
                        ForEach(IncomeCategory.allCases, id: \.rawValue) { cat in
                            Text(cat.emoji + " " + cat.displayText).tag(cat)
                        }
                    }
                }
                Section("日付") {
                    Picker("日", selection: $selectedDay) {
                        ForEach(1...31, id: \.self) { day in
                            Text("\(day)日").tag(day)
                        }
                    }
                }
                Section("メモ") {
                    TextField("任意", text: $noteText)
                }
            }
            .navigationTitle("収入を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        guard let amount = Int(amountText.filter { $0.isNumber }), amount > 0 else { return }
                        var updated = record
                        updated.name     = nameText
                        updated.amount   = amount
                        updated.category = category
                        updated.day      = selectedDay
                        updated.note     = noteText
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

// MARK: - Int フォーマット拡張
private extension Int {
    var formattedYen: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
