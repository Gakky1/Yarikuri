import SwiftUI
import Charts

// MARK: - 収入トラッカーシート
struct IncomeTrackerSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var amountText: String = ""
    @State private var noteText: String = ""
    @State private var showingDeleteAlert = false
    @State private var recordToDelete: IncomeRecord?
    @State private var recordToEdit: IncomeRecord? = nil

    private var years: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array((current - 5)...current).reversed()
    }

    private var chartData: [IncomeRecord] {
        let sorted = appState.incomeHistory.sorted {
            if $0.year != $1.year { return $0.year < $1.year }
            return $0.month < $1.month
        }
        return Array(sorted.suffix(12))
    }

    private var totalThisYear: Int {
        let year = Calendar.current.component(.year, from: Date())
        return appState.incomeHistory
            .filter { $0.year == year }
            .reduce(0) { $0 + $1.amount }
    }

    private var averageMonthly: Int {
        guard !appState.incomeHistory.isEmpty else { return 0 }
        return appState.incomeHistory.reduce(0) { $0 + $1.amount } / appState.incomeHistory.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ── グラフ（常に表示） ──────────────
                    chartSection

                    // ── サマリーカード ──────────────────
                    if !appState.incomeHistory.isEmpty {
                        summarySection
                    }

                    // ── 入力フォーム ──────────────────
                    inputSection

                    // ── 履歴 ──────────────────────────
                    if !appState.incomeHistory.isEmpty {
                        historySection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(AppColor.background)
            .navigationTitle("収入の記録・推移")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
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

    // MARK: - 入力フォーム
    private var inputSection: some View {
        VStack(spacing: 14) {
            Text("収入を入力")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                // 年ピッカー
                Picker("年", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year) + "年").tag(year)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColor.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(AppColor.cardBackground)
                .cornerRadius(10)

                // 月ピッカー
                Picker("月", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text("\(month)月").tag(month)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColor.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(AppColor.cardBackground)
                .cornerRadius(10)
            }

            // 金額入力
            HStack {
                Text("¥")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColor.primary)
                TextField("手取り収入を入力", text: $amountText)
                    .keyboardType(.numberPad)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppColor.cardBackground)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColor.primary.opacity(0.3), lineWidth: 1))

            // メモ
            TextField("メモ（任意）", text: $noteText)
                .font(.system(size: 14))
                .foregroundColor(AppColor.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppColor.cardBackground)
                .cornerRadius(12)

            // 保存ボタン
            Button(action: saveRecord) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("保存する")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(amountText.isEmpty ? AppColor.primary.opacity(0.4) : AppColor.primary)
                .cornerRadius(14)
            }
            .disabled(amountText.isEmpty)
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
    }

    // MARK: - サマリー
    private var summarySection: some View {
        HStack(spacing: 12) {
            summaryCard(
                label: "今年の合計",
                value: "¥\(totalThisYear.formattedYen)",
                icon: "calendar",
                color: AppColor.primary
            )
            summaryCard(
                label: "月平均",
                value: "¥\(averageMonthly.formattedYen)",
                icon: "chart.bar.fill",
                color: Color.orange
            )
        }
    }

    private func summaryCard(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textTertiary)
            }
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppColor.cardBackground)
        .cornerRadius(14)
        .shadow(color: AppColor.shadowColor, radius: 3, x: 0, y: 1)
    }

    private var thisYear: Int { Calendar.current.component(.year, from: Date()) }

    // MARK: - グラフ
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("収入の推移")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                if totalThisYear > 0 {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(String(thisYear) + "年 合計")
                            .font(.system(size: 10))
                            .foregroundColor(AppColor.textTertiary)
                        Text(totalThisYear.yen)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppColor.primary)
                    }
                }
            }

            if chartData.isEmpty {
                // データなし時のプレースホルダー
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 36))
                        .foregroundColor(AppColor.textTertiary.opacity(0.5))
                    Text("収入を記録するとグラフが表示されます")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
            } else {
                Chart(chartData) { record in
                    BarMark(
                        x: .value("月", "\(record.year % 100)/\(record.month)"),
                        y: .value("収入", record.amount)
                    )
                    .foregroundStyle(AppColor.primary.gradient)
                    .cornerRadius(4)
                }
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
                    AxisMarks { value in
                        AxisValueLabel {
                            if let s = value.as(String.self) {
                                Text(s)
                                    .font(.system(size: 9))
                                    .foregroundColor(AppColor.textTertiary)
                            }
                        }
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
                    return $0.month > $1.month
                }) { record in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(record.displayLabel)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColor.textPrimary)
                            if !record.note.isEmpty {
                                Text(record.note)
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColor.textTertiary)
                            }
                        }
                        Spacer()
                        Text("¥\(record.amount.formattedYen)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)
                        Button(action: { recordToEdit = record }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 13))
                                .foregroundColor(AppColor.primary)
                        }
                        .padding(.leading, 12)
                        Button(action: {
                            recordToDelete = record
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 13))
                                .foregroundColor(AppColor.danger)
                        }
                        .padding(.leading, 8)
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
                Text("\(r.displayLabel)の収入記録を削除します")
            }
        }
    }

    // MARK: - 保存処理
    private func saveRecord() {
        guard let amount = Int(amountText.filter { $0.isNumber }), amount > 0 else { return }
        // 同じ年月があれば上書き
        if let idx = appState.incomeHistory.firstIndex(where: { $0.year == selectedYear && $0.month == selectedMonth }) {
            appState.incomeHistory[idx].amount = amount
            appState.incomeHistory[idx].note = noteText
        } else {
            let record = IncomeRecord(year: selectedYear, month: selectedMonth, amount: amount, note: noteText)
            appState.incomeHistory.append(record)
        }
        amountText = ""
        noteText = ""
    }
}

// MARK: - 収入編集シート
private struct IncomeEditSheet: View {
    let record: IncomeRecord
    let onSave: (IncomeRecord) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String
    @State private var noteText: String

    init(record: IncomeRecord, onSave: @escaping (IncomeRecord) -> Void) {
        self.record = record
        self.onSave = onSave
        _amountText = State(initialValue: "\(record.amount)")
        _noteText   = State(initialValue: record.note)
    }

    private var canSave: Bool {
        (Int(amountText.filter { $0.isNumber }) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 年月ラベル（変更不可）
                HStack {
                    Text(record.displayLabel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    Spacer()
                }

                // 金額
                HStack {
                    Text("¥")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColor.primary)
                    TextField("手取り収入を入力", text: $amountText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppColor.cardBackground)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColor.primary.opacity(0.3), lineWidth: 1))

                // メモ
                TextField("メモ（任意）", text: $noteText)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppColor.cardBackground)
                    .cornerRadius(12)

                Spacer()
            }
            .padding(20)
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle("収入を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        guard let amount = Int(amountText.filter { $0.isNumber }), amount > 0 else { return }
                        var updated = record
                        updated.amount = amount
                        updated.note = noteText
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
