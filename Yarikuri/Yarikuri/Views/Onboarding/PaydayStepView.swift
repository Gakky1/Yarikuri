import SwiftUI

// MARK: - 給料日入力（オンボーディング ステップ2）
struct PaydayStepView: View {
    @ObservedObject var vm: OnboardingViewModel

    // 選択肢：毎月の日付
    private let days = Array(1...31)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHeader

                // 日付グリッド
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        DayButton(
                            day: day,
                            isSelected: vm.paydayDay == day,
                            onTap: { vm.paydayDay = day }
                        )
                    }
                }
                .padding(.horizontal, 24)

                // 選択中の表示
                if vm.paydayDay > 0 {
                    HStack {
                        Spacer()
                        Text("毎月\(vm.paydayDay)日が給料日ですね")
                            .font(.system(size: 15))
                            .foregroundColor(AppColor.textSecondary)
                        Spacer()
                    }
                    .padding(.top, 8)
                }

                // ヒント
                HintCard(
                    text: "「末日」「最終営業日」の場合は、だいたいの日付を選んでください。あとで変更できます。"
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

// MARK: - 日付選択ボタン
private struct DayButton: View {
    let day: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("\(day)")
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : AppColor.textPrimary)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(isSelected ? AppColor.primary : AppColor.cardBackground)
                .cornerRadius(10)
                .shadow(color: isSelected ? AppColor.primary.opacity(0.3) : AppColor.shadowColor, radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    ZStack {
        AppColor.onboardingGradient.ignoresSafeArea()
        PaydayStepView(vm: OnboardingViewModel())
    }
}
