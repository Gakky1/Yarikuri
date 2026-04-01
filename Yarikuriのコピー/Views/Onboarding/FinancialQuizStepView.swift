import SwiftUI

// MARK: - 初回6問クイズステップ
struct FinancialQuizStepView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                stepHeader

                QuizSection(title: "1. いちばん近い悩み") {
                    QuizGrid(columns: 2) {
                        ForEach(MainConcernChoice.allCases, id: \.rawValue) { choice in
                            QuizOptionCard(
                                emoji: choice.emoji,
                                text: choice.displayText,
                                isSelected: vm.quizAnswers.mainConcern == choice
                            ) {
                                vm.quizAnswers.mainConcern = choice
                            }
                        }
                    }
                }

                QuizSection(title: "2. 毎月のお金の余裕") {
                    QuizGrid(columns: 3) {
                        ForEach(MonthlySlackChoice.allCases, id: \.rawValue) { choice in
                            QuizOptionCard(
                                emoji: choice.emoji,
                                text: choice.displayText,
                                isSelected: vm.quizAnswers.monthlySlack == choice
                            ) {
                                vm.quizAnswers.monthlySlack = choice
                            }
                        }
                    }
                }

                QuizSection(title: "3. 今ある支払い") {
                    QuizGrid(columns: 2) {
                        ForEach(ExistingPaymentsChoice.allCases, id: \.rawValue) { choice in
                            QuizOptionCard(
                                emoji: choice.emoji,
                                text: choice.displayText,
                                isSelected: vm.quizAnswers.existingPayments == choice
                            ) {
                                vm.quizAnswers.existingPayments = choice
                            }
                        }
                    }
                }

                QuizSection(title: "4. 急な出費に使えるお金") {
                    QuizGrid(columns: 3) {
                        ForEach(EmergencyFundChoice.allCases, id: \.rawValue) { choice in
                            QuizOptionCard(
                                emoji: choice.emoji,
                                text: choice.displayText,
                                isSelected: vm.quizAnswers.emergencyFund == choice
                            ) {
                                vm.quizAnswers.emergencyFund = choice
                            }
                        }
                    }
                }

                QuizSection(title: "5. 今の生活に近いもの") {
                    QuizGrid(columns: 2) {
                        ForEach(LifeStyleChoice.allCases, id: \.rawValue) { choice in
                            QuizOptionCard(
                                emoji: choice.emoji,
                                text: choice.displayText,
                                isSelected: vm.quizAnswers.lifeStyle == choice
                            ) {
                                vm.quizAnswers.lifeStyle = choice
                            }
                        }
                    }
                }

                QuizSection(title: "6. 投資の経験") {
                    QuizGrid(columns: 2) {
                        ForEach(InvestmentExpChoice.allCases, id: \.rawValue) { choice in
                            QuizOptionCard(
                                emoji: choice.emoji,
                                text: choice.displayText,
                                isSelected: vm.quizAnswers.investmentExp == choice
                            ) {
                                vm.quizAnswers.investmentExp = choice
                            }
                        }
                    }
                }

                Spacer().frame(height: 20)
            }
            .padding(.top, 16)
        }
    }

    private var stepHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(vm.currentStep.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColor.textPrimary)
                .padding(.horizontal, 24)
            Text(vm.currentStep.subtitle)
                .font(.system(size: 15))
                .foregroundColor(AppColor.textSecondary)
                .padding(.horizontal, 24)
        }
    }
}

// MARK: - クイズセクション
private struct QuizSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColor.textPrimary)
                .padding(.horizontal, 24)
            content()
        }
    }
}

// MARK: - クイズグリッド
private struct QuizGrid<Content: View>: View {
    let columns: Int
    @ViewBuilder let content: () -> Content

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: columns),
            spacing: 10
        ) {
            content()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - 選択肢カード（単一選択）
private struct QuizOptionCard: View {
    let emoji: String
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25)) { onTap() }
        }) {
            VStack(spacing: 6) {
                Text(emoji).font(.system(size: 26))
                Text(text)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColor.primary : AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 6)
            .background(isSelected ? AppColor.primaryLight : AppColor.cardBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppColor.primary : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: AppColor.shadowColor, radius: isSelected ? 0 : 3, x: 0, y: 1)
            .scaleEffect(isSelected ? 0.97 : 1.0)
        }
    }
}

#Preview {
    ZStack {
        AppColor.onboardingGradient.ignoresSafeArea()
        FinancialQuizStepView(vm: OnboardingViewModel())
    }
}
