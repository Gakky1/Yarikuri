import SwiftUI

// MARK: - 安全度カード（残予算・給料日まで・1日あたり）
struct SafetyCard: View {
    @EnvironmentObject var appState: AppState
    var onDetailTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack {
                Text("今月のお金の状況")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
                Button(action: onDetailTap) {
                    Text("詳細を見る")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.primary)
                }
            }
            .padding(.bottom, 16)

            // 安全度インジケーター
            safetyIndicator

            Divider()
                .padding(.vertical, 14)

            // 3つの数字
            HStack(spacing: 0) {
                SafetyMetric(
                    label: "残予算",
                    value: appState.remainingBudget.yen,
                    color: Color.safetyColor(ratio: appState.safetyRatio)
                )

                dividerLine

                SafetyMetric(
                    label: "給料日まで",
                    value: "\(appState.daysToPayday)日",
                    color: appState.daysToPayday <= 5 ? AppColor.caution : AppColor.textPrimary
                )

                dividerLine

                SafetyMetric(
                    label: "1日の目安",
                    value: appState.dailyBudget.yen,
                    color: appState.dailyBudget <= 0 ? AppColor.danger : AppColor.secondary
                )
            }
        }
        .cardStyle()
    }

    // MARK: - 安全度インジケーター
    private var safetyIndicator: some View {
        HStack(spacing: 12) {
            // アイコン
            ZStack {
                Circle()
                    .fill(Color.safetyColor(ratio: appState.safetyRatio).opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(appState.safetyLevel.emoji)
                    .font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(appState.safetyLevel.label)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.safetyColor(ratio: appState.safetyRatio))
                    Text("·")
                        .foregroundColor(AppColor.textTertiary)
                    Text(safetyDescription)
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textSecondary)
                }

                // プログレスバー
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColor.sectionBackground)
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.safetyColor(ratio: appState.safetyRatio))
                            .frame(width: geo.size.width * min(1.0, max(0, appState.safetyRatio)), height: 8)
                            .animation(.spring(response: 0.5), value: appState.safetyRatio)
                    }
                }
                .frame(height: 8)
            }
        }
    }

    private var safetyDescription: String {
        let ratio = appState.safetyRatio
        if ratio > 0.5 { return "余裕あり" }
        if ratio > 0.25 { return "少し注意" }
        if ratio > 0 { return "要注意" }
        return "予算オーバー"
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(AppColor.sectionBackground)
            .frame(width: 1, height: 44)
    }
}

// MARK: - 安全度メトリクス
private struct SafetyMetric: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppColor.textTertiary)
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SafetyCard(onDetailTap: {})
        .padding()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
