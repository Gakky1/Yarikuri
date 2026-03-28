import SwiftUI

// MARK: - 手取り感入力（オンボーディング ステップ3）
struct IncomeStepView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHeader

                // レンジ選択
                VStack(spacing: 10) {
                    ForEach(IncomeRange.allCases, id: \.rawValue) { range in
                        RangeOptionButton(
                            text: range.displayText,
                            isSelected: !vm.useCustomAmount && vm.incomeRange == range,
                            onTap: {
                                vm.incomeRange = range
                                vm.useCustomAmount = false
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)

                // カスタム入力オプション
                VStack(spacing: 10) {
                    Divider().padding(.horizontal, 24)

                    Toggle(isOn: $vm.useCustomAmount.animation()) {
                        Text("正確な金額を入力する")
                            .font(.system(size: 15))
                            .foregroundColor(AppColor.textSecondary)
                    }
                    .tint(AppColor.primary)
                    .padding(.horizontal, 24)

                    if vm.useCustomAmount {
                        HStack {
                            TextField("例: 220000", text: $vm.customAmountText)
                                .keyboardType(.numberPad)
                                .font(.system(size: 18, weight: .semibold))
                                .padding()
                                .background(AppColor.inputBackground)
                                .cornerRadius(12)

                            Text("円")
                                .font(.system(size: 18))
                                .foregroundColor(AppColor.textSecondary)
                        }
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                HintCard(
                    text: "手取りとは、給料から税金・社会保険料を引いた後に振り込まれる金額です。ざっくりでOKです！"
                )
                .padding(.horizontal, 24)
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

// MARK: - 範囲選択ボタン
private struct RangeOptionButton: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColor.primary : AppColor.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColor.primary)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? AppColor.primaryLight : AppColor.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColor.primary : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    ZStack {
        AppColor.onboardingGradient.ignoresSafeArea()
        IncomeStepView(vm: OnboardingViewModel())
    }
}
