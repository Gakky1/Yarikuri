import SwiftUI

// MARK: - 困りごと診断（オンボーディング ステップ7 ＆ 最終ステップ）
struct ConcernStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    var onComplete: () -> Void
    @State private var showingComplete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHeader

                // 選択肢グリッド
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(ConcernType.allCases, id: \.rawValue) { concern in
                        ConcernToggleCard(
                            concern: concern,
                            isSelected: vm.selectedConcerns.contains(concern),
                            onTap: {
                                withAnimation(.spring(response: 0.3)) {
                                    if vm.selectedConcerns.contains(concern) {
                                        vm.selectedConcerns.remove(concern)
                                    } else {
                                        vm.selectedConcerns.insert(concern)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)

                // 選択数表示
                if !vm.selectedConcerns.isEmpty {
                    Text("\(vm.selectedConcerns.count)つ選ばれています")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                        .padding(.horizontal, 24)
                }

                // 完了ボタン
                Button(action: {
                    showingComplete = true
                }) {
                    Text("アプリを始める 🎉")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            vm.selectedConcerns.isEmpty
                            ? AppColor.textTertiary
                            : AppColor.primary
                        )
                        .cornerRadius(16)
                }
                .disabled(vm.selectedConcerns.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .padding(.top, 16)
        }
        .fullScreenCover(isPresented: $showingComplete) {
            OnboardingCompleteView(onComplete: onComplete)
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

// MARK: - 困りごとカード
private struct ConcernToggleCard: View {
    let concern: ConcernType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(concern.emoji).font(.system(size: 30))
                Text(concern.displayText)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColor.primary : AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(isSelected ? AppColor.primaryLight : AppColor.cardBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppColor.primary : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: AppColor.shadowColor, radius: isSelected ? 0 : 4, x: 0, y: 2)
            .scaleEffect(isSelected ? 0.97 : 1.0)
        }
    }
}

// MARK: - 完了画面
struct OnboardingCompleteView: View {
    var onComplete: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            AppColor.onboardingGradient.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppColor.secondaryLight)
                            .frame(width: 130, height: 130)
                        Text("🎉")
                            .font(.system(size: 64))
                    }
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)

                    Text("準備完了！")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColor.textPrimary)

                    Text("あなたのやりくりノートが\n整いました。\n一緒にゆっくり整えていきましょう。")
                        .font(.system(size: 17))
                        .foregroundColor(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)

                Spacer()

                Button(action: onComplete) {
                    Text("ホームへ進む")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppColor.primaryGradient)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.6), value: appeared)
            }
        }
        .onAppear { appeared = true }
    }
}

#Preview {
    ZStack {
        AppColor.onboardingGradient.ignoresSafeArea()
        ConcernStepView(vm: OnboardingViewModel(), onComplete: {})
    }
}
