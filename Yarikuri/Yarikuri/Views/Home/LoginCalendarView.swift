import SwiftUI

// MARK: - ログインカレンダー
struct LoginCalendarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var displayMonth: Date = Calendar.current.startOfMonth(for: Date())

    private let calendar = Calendar.current
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // サマリー
                        summaryCard

                        // カレンダー本体
                        calendarCard

                        // 凡例
                        legend

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("ログイン記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }

    // MARK: - サマリーカード
    private var summaryCard: some View {
        HStack(spacing: 0) {
            statItem(value: "\(appState.consecutiveLoginDays)日", label: "連続ログイン", color: .orange)
            Divider().frame(height: 40)
            statItem(value: "\(appState.loginDateHistory.count)日", label: "累計ログイン", color: AppColor.primary)
            Divider().frame(height: 40)
            statItem(value: "\(thisMonthCount)日", label: "今月のログイン", color: AppColor.safe)
        }
        .padding(.vertical, 16)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
    }

    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var thisMonthCount: Int {
        let comps = calendar.dateComponents([.year, .month], from: displayMonth)
        return appState.loginDateHistory.filter { dateStr in
            guard let d = formatter.date(from: dateStr) else { return false }
            let dc = calendar.dateComponents([.year, .month], from: d)
            return dc.year == comps.year && dc.month == comps.month
        }.count
    }

    // MARK: - カレンダーカード
    private var calendarCard: some View {
        VStack(spacing: 12) {
            // 月ナビゲーション
            HStack {
                Button(action: prevMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColor.primary)
                        .frame(width: 36, height: 36)
                        .background(AppColor.primaryLight)
                        .cornerRadius(10)
                }

                Spacer()

                Text(monthTitle)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(canGoNext ? AppColor.primary : AppColor.textTertiary)
                        .frame(width: 36, height: 36)
                        .background(canGoNext ? AppColor.primaryLight : AppColor.sectionBackground)
                        .cornerRadius(10)
                }
                .disabled(!canGoNext)
            }

            // 曜日ヘッダー
            HStack(spacing: 0) {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(day == "日" ? .red.opacity(0.7) : day == "土" ? .blue.opacity(0.7) : AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            Divider()

            // 日グリッド
            let days = makeDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { date in
                    DayCell(date: date, isLoggedIn: isLoggedIn(date), displayMonth: displayMonth)
                }
            }
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
    }

    // MARK: - 凡例
    private var legend: some View {
        HStack(spacing: 20) {
            legendItem(color: .orange, label: "ログインした日")
            legendItem(color: AppColor.primary.opacity(0.3), label: "今日")
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppColor.textSecondary)
        }
    }

    // MARK: - ヘルパー
    private var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月"
        f.locale = Locale(identifier: "ja_JP")
        return f.string(from: displayMonth)
    }

    private var canGoNext: Bool {
        let thisMonth = calendar.startOfMonth(for: Date())
        return displayMonth < thisMonth
    }

    private func prevMonth() {
        displayMonth = calendar.date(byAdding: .month, value: -1, to: displayMonth) ?? displayMonth
    }

    private func nextMonth() {
        guard canGoNext else { return }
        displayMonth = calendar.date(byAdding: .month, value: 1, to: displayMonth) ?? displayMonth
    }

    private func makeDays() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayMonth))
        else { return [] }

        let weekday = (calendar.component(.weekday, from: firstDay) - 1 + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(d)
            }
        }
        // 6週分になるよう末尾を埋める
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    private func isLoggedIn(_ date: Date?) -> Bool {
        guard let date else { return false }
        return appState.loginDateHistory.contains(formatter.string(from: date))
    }
}

// MARK: - 日セル
private struct DayCell: View {
    let date: Date?
    let isLoggedIn: Bool
    let displayMonth: Date

    private let calendar = Calendar.current

    private var isToday: Bool {
        guard let date else { return false }
        return calendar.isDateInToday(date)
    }

    private var dayNumber: String {
        guard let date else { return "" }
        return "\(calendar.component(.day, from: date))"
    }

    var body: some View {
        ZStack {
            if isLoggedIn {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 34, height: 34)
            } else if isToday {
                Circle()
                    .stroke(AppColor.primary, lineWidth: 2)
                    .frame(width: 34, height: 34)
            }

            if date != nil {
                Text(dayNumber)
                    .font(.system(size: 14, weight: isLoggedIn ? .bold : .regular))
                    .foregroundColor(isLoggedIn ? .white : isToday ? AppColor.primary : AppColor.textPrimary)
            }
        }
        .frame(height: 36)
    }
}

// MARK: - Calendar拡張
private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }
}
