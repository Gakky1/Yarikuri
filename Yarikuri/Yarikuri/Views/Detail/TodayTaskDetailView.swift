import SwiftUI

// MARK: - 今日やること詳細画面
struct TodayTaskDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var praiseTask: DailyTask? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        let tasks = appState.generateTasks()

                        if tasks.isEmpty {
                            allDoneView
                        } else {
                            ForEach(tasks) { task in
                                TaskDetailRow(
                                    task: task,
                                    isCompleted: appState.completedTaskIds.contains(task.id.uuidString),
                                    onTapAction: { praiseTask = task }
                                )
                            }
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }

                // やりくりん褒めポップアップ
                if let task = praiseTask {
                    TaskPraisePopup(task: task) {
                        withAnimation { appState.completeTask(task) }
                        praiseTask = nil
                        let tabIndex: Int
                        switch task.taskType.tabDestination {
                        case .home:    tabIndex = 0
                        case .protect: tabIndex = 2
                        case .recover: tabIndex = 3
                        case .myPage:  tabIndex = 0
                        }
                        dismiss()
                        NotificationCenter.default.post(
                            name: Notification.Name("NavigateToTab"),
                            object: tabIndex
                        )
                    } onDismiss: {
                        praiseTask = nil
                    }
                }
            }
            .navigationTitle("今日やること")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }

    private var allDoneView: some View {
        VStack(spacing: 16) {
            Text("🎉").font(.system(size: 60))
            Text("今日のタスクはすべて完了！")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColor.textPrimary)
            Text("よく頑張りました。\n引き続き、やりくりを楽しみましょう！")
                .font(.system(size: 15))
                .foregroundColor(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - タスク行
private struct TaskDetailRow: View {
    let task: DailyTask
    let isCompleted: Bool
    let onTapAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? AppColor.secondaryLight : taskColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    if isCompleted {
                        Image(systemName: "checkmark").foregroundColor(AppColor.secondary)
                    } else {
                        Text(task.taskType.emoji).font(.system(size: 20))
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isCompleted ? AppColor.textTertiary : AppColor.textPrimary)
                        .strikethrough(isCompleted)
                    Text(task.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }

                Spacer()
            }

            if !isCompleted {
                Button(action: onTapAction) {
                    Text(task.actionLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(taskColor)
                        .cornerRadius(10)
                }
            }
        }
        .padding(14)
        .background(isCompleted ? AppColor.sectionBackground : AppColor.cardBackground)
        .cornerRadius(14)
        .shadow(color: isCompleted ? .clear : AppColor.shadowColor, radius: 5)
    }

    private var taskColor: Color {
        switch task.taskType {
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

// MARK: - やりくりん褒めポップアップ
private struct TaskPraisePopup: View {
    let task: DailyTask
    let onConfirm: () -> Void
    let onDismiss: () -> Void

    private var praiseMessage: String {
        switch task.taskType {
        case .paymentDue:          return "支払いを確認しにいくりん！えらいりん✨"
        case .debtSetup:           return "借金と向き合えてるりん！すごいりん💪"
        case .fixedExpenseReview:  return "固定費チェック、さすがりん✂️"
        case .systemCheck:         return "制度を調べるなんて賢いりん🏛️"
        case .sideIncomeCheck:     return "副収入も意識してるりん！すごいりん💼"
        case .reportCheck:         return "自分のお金と向き合えてるりん📊"
        case .budgetAlert:         return "予算を気にしてえらいりん⚠️"
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                Text("🐷")
                    .font(.system(size: 64))

                VStack(spacing: 8) {
                    Text("やりくりんより")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textTertiary)
                    Text(praiseMessage)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppColor.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 8)

                VStack(spacing: 10) {
                    Button(action: onConfirm) {
                        Text("確認しに行くりん →")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(AppColor.primary)
                            .cornerRadius(12)
                    }
                    Button(action: onDismiss) {
                        Text("あとで確認する")
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSecondary)
                    }
                }
            }
            .padding(28)
            .background(AppColor.cardBackground)
            .cornerRadius(24)
            .shadow(color: AppColor.shadowColor, radius: 20, x: 0, y: 8)
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    TodayTaskDetailView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
