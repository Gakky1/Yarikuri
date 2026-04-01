import SwiftUI

// MARK: - 今週守れたお金カード
struct WeeklySavingsCard: View {
    @EnvironmentObject var appState: AppState
    var onReportTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // アイコン
            ZStack {
                Circle()
                    .fill(AppColor.secondaryLight)
                    .frame(width: 52, height: 52)
                Text("🐷")
                    .font(.system(size: 26))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("今週守れたお金")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Text("+\(appState.weeklyProtectedAmount.yen)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColor.secondary)
                Text("予算より少なく使えました")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textTertiary)
            }

            Spacer()

            Button(action: onReportTap) {
                VStack(spacing: 2) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 18))
                    Text("レポート")
                        .font(.system(size: 11))
                }
                .foregroundColor(AppColor.primary)
            }
        }
        .cardStyle()
    }
}

#Preview {
    WeeklySavingsCard(onReportTap: {})
        .padding()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
