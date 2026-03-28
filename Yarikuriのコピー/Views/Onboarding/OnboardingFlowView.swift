import SwiftUI

// MARK: - オンボーディング全体フロー
// 各ステップを管理し、完了時にAppStateへデータを渡します

struct OnboardingFlowView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        ZStack {
            AppColor.onboardingGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // プログレスバー（ウェルカム以外で表示）
                if vm.currentStep != .welcome {
                    progressBar
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }

                // 各ステップのコンテンツ
                stepContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(vm.currentStep)

                Spacer()

                // ナビゲーションボタン
                if vm.currentStep != .welcome {
                    navigationButtons
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: vm.currentStep)
    }

    // MARK: - プログレスバー
    private var progressBar: some View {
        VStack(spacing: 6) {
            HStack {
                Button(action: { vm.previousStep() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColor.textSecondary)
                }
                .opacity(vm.isFirstStep ? 0 : 1)

                Spacer()

                Text("\(vm.currentStep.rawValue) / \(OnboardingStep.allCases.count - 1)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textTertiary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppColor.primaryLight)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppColor.primary)
                        .frame(width: geo.size.width * vm.stepProgress, height: 4)
                        .animation(.spring(response: 0.5), value: vm.stepProgress)
                }
            }
            .frame(height: 4)
        }
    }

    // MARK: - ステップコンテンツ
    @ViewBuilder
    private var stepContent: some View {
        switch vm.currentStep {
        case .welcome:
            WelcomeStepView(onStart: { vm.nextStep() })
        case .payday:
            PaydayStepView(vm: vm)
        case .income:
            IncomeStepView(vm: vm)
        case .fixedExpense:
            FixedExpenseStepView(vm: vm)
        case .debt:
            DebtStepView(vm: vm)
        case .nextPayment:
            NextPaymentStepView(vm: vm)
        case .concern:
            ConcernStepView(vm: vm, onComplete: completeOnboarding)
        }
    }

    // MARK: - ナビゲーションボタン
    private var navigationButtons: some View {
        VStack(spacing: 12) {
            if !vm.isLastStep {
                Button(action: { vm.nextStep() }) {
                    Text("次へ")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(vm.canProceedFromStep ? AppColor.primary : AppColor.textTertiary)
                        .cornerRadius(14)
                }
                .disabled(!vm.canProceedFromStep)

                if vm.currentStep == .fixedExpense || vm.currentStep == .debt || vm.currentStep == .nextPayment {
                    Button(action: { vm.nextStep() }) {
                        Text("あとで入力する")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - オンボーディング完了
    private func completeOnboarding() {
        let profile = vm.buildUserProfile()
        appState.completeOnboarding(
            with: profile,
            expenses: vm.fixedExpenses,
            debts: vm.hasDebt ? vm.debts : [],
            payments: vm.scheduledPayments
        )
    }
}

#Preview {
    OnboardingFlowView()
        .environmentObject(AppState())
}
