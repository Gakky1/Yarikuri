import SwiftUI

// MARK: - Int 拡張：金額フォーマット
extension Int {
    /// 金額を日本円形式でフォーマット（例: 150000 → "150,000円"）
    var yen: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return "\(formatted)円"
    }

    /// 金額を万円単位でフォーマット（例: 150000 → "15万円"）
    var man: String {
        if self >= 10000 {
            let man = self / 10000
            let sen = (self % 10000) / 1000
            if sen > 0 {
                return "\(man).\(sen)万円"
            }
            return "\(man)万円"
        }
        return yen
    }

    /// 符号付き金額（例: +3,000円 / -5,000円）
    var yenWithSign: String {
        let prefix = self >= 0 ? "+" : ""
        return "\(prefix)\(yen)"
    }
}

// MARK: - Date 拡張
extension Date {
    /// 今日から指定日付までの日数
    func daysUntil(_ target: Date) -> Int {
        Calendar.current.dateComponents([.day], from: startOfDay, to: target.startOfDay).day ?? 0
    }

    /// 日付の始まり（00:00:00）
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// 月と日の表示（例: "3月25日"）
    var monthDay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: self)
    }

    /// 曜日付きの月日（例: "3月25日（月）"）
    var monthDayWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日（E）"
        return formatter.string(from: self)
    }

    /// 今月の特定日付を返す
    static func thisMonthDate(day: Int) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month], from: Date())
        components.day = day
        return Calendar.current.date(from: components)
    }

    /// 次の特定日付（今月か来月）を返す
    static func nextDate(day: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: Date())
        components.day = day
        guard var date = calendar.date(from: components) else { return Date() }

        // 今日以前なら来月
        if date <= Date() {
            components.month = (components.month ?? 1) + 1
            date = calendar.date(from: components) ?? date
        }
        return date
    }
}

// MARK: - View 拡張
extension View {
    /// カード風のスタイルを適用する
    func cardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(AppColor.cardBackground)
            .cornerRadius(16)
            .shadow(color: AppColor.shadowColor, radius: 8, x: 0, y: 2)
    }

    /// セクションヘッダースタイル
    func sectionHeader() -> some View {
        self
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(AppColor.textSecondary)
            .textCase(nil)
    }
}

// MARK: - Color 拡張
extension Color {
    /// 安全度に応じた色を返す（0.0〜1.0、1.0が最安全）
    static func safetyColor(ratio: Double) -> Color {
        if ratio > 0.5 {
            return AppColor.safe
        } else if ratio > 0.25 {
            return AppColor.caution
        } else {
            return AppColor.danger
        }
    }
}
