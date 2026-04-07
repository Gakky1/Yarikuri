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
                                    onTapAction: {
                                        withAnimation { appState.completeTask(task) }
                                        praiseTask = task
                                    }
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
    let onClose: () -> Void

    @State private var bounceOffset: CGFloat = 40
    @State private var opacity: Double = 0

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

    private var destinationLabel: String {
        switch task.taskType.tabDestination {
        case .protect: return "支出を減らすへ"
        case .recover: return "収入を増やすへ"
        default:       return "ホームへ"
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 0) {
                // やりくりん本体
                CoronView(size: 80, emotion: .celebrate, animate: true, level: 3)
                    .frame(width: 110, height: 100)
                    .offset(y: 10)
                    .zIndex(1)

                VStack(spacing: 18) {
                    // 褒め言葉
                    VStack(spacing: 6) {
                        Text("やりくりんより")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColor.textTertiary)
                        Text(praiseMessage)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 4)
                    }
                    .padding(.top, 16)

                    // 遷移先ボタン（閉じる＝遷移）
                    Button(action: onClose) {
                        HStack(spacing: 8) {
                            Text(destinationLabel)
                                .font(.system(size: 15, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColor.primary)
                        .cornerRadius(13)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .background(AppColor.cardBackground)
                .cornerRadius(24)
            }
            .padding(.horizontal, 36)
            .offset(y: bounceOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                    bounceOffset = 0
                    opacity = 1
                }
            }
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
