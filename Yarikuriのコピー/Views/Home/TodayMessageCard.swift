import SwiftUI

// MARK: - 今日のひとことカード
struct TodayMessageCard: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        let msg = appState.todayMessage

        HStack(spacing: 14) {
            Text(msg.emoji)
                .font(.system(size: 36))

            VStack(alignment: .leading, spacing: 4) {
                Text(msg.greeting)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Text(msg.message)
                    .font(.system(size: 15))
                    .foregroundColor(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(16)
        .background(backgroundColor(for: msg.mood))
        .cornerRadius(14)
        .shadow(color: AppColor.shadowColor, radius: 6, x: 0, y: 2)
    }

    private func backgroundColor(for mood: TodayMessage.Mood) -> Color {
        switch mood {
        case .positive: return AppColor.secondaryLight
        case .neutral: return AppColor.accentLight
        case .careful: return AppColor.primaryLight
        }
    }
}

#Preview {
    TodayMessageCard()
        .padding()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
