import SwiftUI

// MARK: - 共通バーチャートコンポーネント（支出 + 守れた額 積み上げ表示）
struct ReportBarChart: View {

    struct Bar: Identifiable {
        let id = UUID()
        let label: String
        let value: Int
        let budget: Int
        let isCurrentPeriod: Bool
        let isFuture: Bool
        var saved: Int { isFuture ? 0 : max(0, budget - value) }
    }

    let title: String
    let bars: [Bar]
    let unit: String
    var savingsLabel: String = "守れた額"

    @State private var appeared = false

    private let barAreaHeight: CGFloat = 130
    private let barWidth: CGFloat = 38
    private let labelHeight: CGFloat = 14
    private let savedColor = Color(red: 0.18, green: 0.62, blue: 0.35)

    private var maxVal: Int {
        max(1, bars.map { max($0.value, $0.budget) }.max() ?? 1)
    }
    private var budgetVal: Int {
        bars.first(where: { !$0.isFuture })?.budget ?? 1
    }
    private var totalSaved: Int {
        bars.filter { !$0.isFuture }.reduce(0) { $0 + $1.saved }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // 上段：金額ラベル行
                    HStack(alignment: .bottom, spacing: 5) {
                        ForEach(bars) { bar in
                            valueLabelCell(bar)
                                .frame(width: barWidth, height: labelHeight)
                        }
                    }

                    // 中段：バーエリア（予算ライン付き）
                    ZStack(alignment: .bottomLeading) {
                        HStack(alignment: .bottom, spacing: 5) {
                            ForEach(bars) { bar in
                                stackedBar(bar)
                                    .frame(width: barWidth, height: barAreaHeight)
                            }
                        }

                        // 予算ライン（破線）
                        GeometryReader { geo in
                            let y = barAreaHeight * (1.0 - CGFloat(budgetVal) / CGFloat(maxVal))
                            Path { path in
                                var x: CGFloat = 0
                                while x < geo.size.width {
                                    path.move(to: CGPoint(x: x, y: y))
                                    path.addLine(to: CGPoint(x: x + 6, y: y))
                                    x += 10
                                }
                            }
                            .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 1.2))
                        }
                        .frame(height: barAreaHeight)
                        .allowsHitTesting(false)
                    }
                    .frame(height: barAreaHeight)

                    // 下段：期間ラベル行
                    HStack(spacing: 5) {
                        ForEach(bars) { bar in
                            Text(bar.label)
                                .font(.system(size: 9, weight: bar.isCurrentPeriod ? .bold : .regular))
                                .foregroundColor(bar.isCurrentPeriod ? AppColor.primary : AppColor.textTertiary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(width: barWidth)
                        }
                    }
                    .frame(height: labelHeight)
                }
                .frame(minWidth: CGFloat(bars.count) * (barWidth + 5) - 5)
            }

            // 凡例 + 合計守れた額
            HStack(spacing: 0) {
                HStack(spacing: 10) {
                    legendDot(color: AppColor.primary.opacity(0.75), label: "支出")
                    legendDot(color: savedColor, label: savingsLabel)
                    legendDot(color: AppColor.danger, label: "超過")
                }
                Spacer()
                if totalSaved > 0 {
                    HStack(spacing: 4) {
                        Text("合計")
                            .font(.system(size: 10))
                            .foregroundColor(AppColor.textTertiary)
                        Text("+\(formatYen(totalSaved))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(savedColor)
                    }
                } else {
                    Text("--- 予算ライン")
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.textTertiary)
                }
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.15)) {
                appeared = true
            }
        }
    }

    // MARK: - 金額ラベルセル
    @ViewBuilder
    private func valueLabelCell(_ bar: ReportBarChart.Bar) -> some View {
        if !bar.isFuture && bar.value > 0 {
            Text(compactYen(bar.value))
                .font(.system(size: 8))
                .foregroundColor(bar.isCurrentPeriod ? AppColor.primary : AppColor.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            Color.clear
        }
    }

    // MARK: - 積み上げバー（守れた額＋支出）
    @ViewBuilder
    private func stackedBar(_ bar: ReportBarChart.Bar) -> some View {
        let spendRatio = CGFloat(max(0, bar.value)) / CGFloat(maxVal)
        let savedRatio = CGFloat(bar.saved) / CGFloat(maxVal)
        let spendColor: Color = bar.value > bar.budget ? AppColor.danger
            : bar.isCurrentPeriod ? AppColor.primary
            : AppColor.primary.opacity(0.7)

        VStack(spacing: 1) {
            Spacer(minLength: 0)
            if bar.isFuture {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: barAreaHeight * CGFloat(bar.budget) / CGFloat(maxVal))
            } else {
                // 守れた額（緑、上段）
                if bar.saved > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(savedColor.opacity(0.82))
                        .frame(height: appeared ? max(2, barAreaHeight * savedRatio) : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.08), value: appeared)
                }
                // 支出（青/赤、下段）
                if bar.value > 0 {
                    RoundedRectangle(cornerRadius: bar.saved > 0 ? 2 : 4)
                        .fill(spendColor)
                        .frame(height: appeared ? max(2, barAreaHeight * spendRatio) : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: appeared)
                }
            }
        }
        .frame(height: barAreaHeight)
    }

    // MARK: - ヘルパー
    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 10, height: 8)
            Text(label).font(.system(size: 10)).foregroundColor(AppColor.textTertiary)
        }
    }

    private func compactYen(_ v: Int) -> String {
        if v >= 10000 {
            let d = Double(v) / 10000.0
            return d.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(d))万" : String(format: "%.1f万", d)
        } else if v >= 1000 {
            return "\(v / 1000)千"
        }
        return "\(v)"
    }

    private func formatYen(_ v: Int) -> String {
        if v >= 10000 {
            let d = Double(v) / 10000.0
            return d.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(d))万円" : String(format: "%.1f万円", d)
        }
        return "\(v)円"
    }
}

// MARK: - 行動数 積み上げ棒グラフ（守る/増やす 2色積み上げ）
struct ActionStackedBarChart: View {

    struct Bar: Identifiable {
        let id = UUID()
        let label: String
        let protectCount: Int
        let growCount: Int
        let isCurrentPeriod: Bool
        var isFuture: Bool = false
        var total: Int { protectCount + growCount }
    }

    let title: String
    let bars: [Bar]
    var totalLabel: String = ""

    @State private var appeared = false

    private let barAreaHeight: CGFloat = 110
    private let barWidth: CGFloat = 32
    private let labelHeight: CGFloat = 14
    private let protectColor = Color(red: 0.27, green: 0.52, blue: 0.96)
    private let growColor    = Color(red: 0.18, green: 0.62, blue: 0.35)

    private var maxVal: Int { max(1, bars.map { $0.total }.max() ?? 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
                if !totalLabel.isEmpty {
                    Text(totalLabel)
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textTertiary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // 合計ラベル行
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(bars) { bar in
                            Group {
                                if !bar.isFuture && bar.total > 0 {
                                    Text("\(bar.total)")
                                        .font(.system(size: 9))
                                        .foregroundColor(bar.isCurrentPeriod ? AppColor.primary : AppColor.textTertiary)
                                } else {
                                    Color.clear
                                }
                            }
                            .frame(width: barWidth, height: labelHeight)
                        }
                    }

                    // バーエリア
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(bars) { bar in
                            actionBar(bar)
                                .frame(width: barWidth, height: barAreaHeight)
                        }
                    }
                    .frame(height: barAreaHeight)

                    // 期間ラベル
                    HStack(spacing: 4) {
                        ForEach(bars) { bar in
                            Text(bar.label)
                                .font(.system(size: 9, weight: bar.isCurrentPeriod ? .bold : .regular))
                                .foregroundColor(bar.isCurrentPeriod ? AppColor.primary : AppColor.textTertiary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(width: barWidth, height: labelHeight)
                        }
                    }
                }
                .frame(minWidth: CGFloat(bars.count) * (barWidth + 4) - 4)
            }

            // 凡例 + 合計
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2).fill(protectColor).frame(width: 10, height: 8)
                    Text("守る").font(.system(size: 10)).foregroundColor(AppColor.textTertiary)
                }
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2).fill(growColor).frame(width: 10, height: 8)
                    Text("増やす").font(.system(size: 10)).foregroundColor(AppColor.textTertiary)
                }
                Spacer()
                let total = bars.filter { !$0.isFuture }.reduce(0) { $0 + $1.total }
                Text("合計 \(total)件")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.15)) {
                appeared = true
            }
        }
    }

    @ViewBuilder
    private func actionBar(_ bar: ActionStackedBarChart.Bar) -> some View {
        if bar.isFuture {
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.08))
                    .frame(height: barAreaHeight * 0.25)
            }
        } else if bar.total == 0 {
            VStack { Spacer() }
        } else {
            let protectRatio = CGFloat(bar.protectCount) / CGFloat(maxVal)
            let growRatio    = CGFloat(bar.growCount)    / CGFloat(maxVal)
            VStack(spacing: 1) {
                Spacer(minLength: 0)
                if bar.growCount > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(growColor.opacity(0.85))
                        .frame(height: appeared ? max(2, barAreaHeight * growRatio) : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.08), value: appeared)
                }
                if bar.protectCount > 0 {
                    RoundedRectangle(cornerRadius: bar.growCount > 0 ? 2 : 4)
                        .fill(protectColor.opacity(0.85))
                        .frame(height: appeared ? max(2, barAreaHeight * protectRatio) : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: appeared)
                }
            }
            .frame(height: barAreaHeight)
        }
    }
}
