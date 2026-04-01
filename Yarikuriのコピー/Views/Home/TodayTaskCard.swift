import SwiftUI

// MARK: - 今日やることカード
struct TodayTaskCard: View {
    @EnvironmentObject var appState: AppState
    var onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack {
                Text("今日やること")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textSecondary)
                Spacer()
                Button(action: onTap) {
                    Text("詳細を見る")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.primary)
                }
            }
            .padding(.bottom, 12)

            if let task = appState.todayTask {
                // タスクコンテンツ
                HStack(spacing: 14) {
                    // タスクアイコン
                    ZStack {
                        Circle()
                            .fill(taskColor(task.taskType).opacity(0.15))
                            .frame(width: 48, height: 48)
                        Text(task.taskType.emoji)
                            .font(.system(size: 22))
                    }

                    Text(task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }

                // アクションボタン
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        appState.completeTask(task)
                    }
                    onTap()
                }) {
                    Text(task.actionLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(taskColor(task.taskType))
                        .cornerRadius(10)
                }
                .padding(.top, 14)

            } else {
                // すべて完了済み
                VStack(spacing: 8) {
                    Text("🌟")
                        .font(.system(size: 36))
                    Text("今日のタスクはすべて完了！")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColor.textSecondary)
                    Text("よく頑張りました")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .cardStyle()
    }

    private func taskColor(_ type: TaskType) -> Color {
        switch type {
        case .paymentDue: return AppColor.danger
        case .debtSetup: return AppColor.caution
        case .fixedExpenseReview: return AppColor.secondary
        case .systemCheck: return AppColor.tertiary
        case .sideIncomeCheck: return AppColor.accent
        case .reportCheck: return AppColor.primary
        case .budgetAlert: return AppColor.danger
        }
    }
}

#Preview {
    TodayTaskCard(onTap: {})
        .padding()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
