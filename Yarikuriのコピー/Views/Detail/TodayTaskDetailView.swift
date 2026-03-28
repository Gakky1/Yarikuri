import SwiftUI

// MARK: - 今日やること詳細画面
struct TodayTaskDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

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
                                    onComplete: {
                                        withAnimation {
                                            appState.completeTask(task)
                                        }
                                    }
                                )
                            }
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("今日やること")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
    let onComplete: () -> Void

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
                Button(action: onComplete) {
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

#Preview {
    TodayTaskDetailView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
