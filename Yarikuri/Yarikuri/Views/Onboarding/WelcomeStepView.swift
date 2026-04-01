import SwiftUI

// MARK: - ウェルカム画面（オンボーディング ステップ1）
struct WelcomeStepView: View {
    var onStart: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // メインイラスト部分
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(AppColor.primaryLight)
                        .frame(width: 140, height: 140)

                    Text("🐷")
                        .font(.system(size: 72))
                }
                .scaleEffect(appeared ? 1.0 : 0.7)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)

                VStack(spacing: 8) {
                    Text("やりくり")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppColor.textPrimary)

                    Text("毎日のお金を、少しずつ整えよう")
                        .font(.system(size: 17))
                        .foregroundColor(AppColor.textSecondary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
            }

            Spacer().frame(height: 48)

            // アプリの説明
            VStack(spacing: 16) {
                FeatureRow(emoji: "✨", title: "今日やることが1つわかる", subtitle: "毎日10秒で状況を確認できます")
                FeatureRow(emoji: "📊", title: "今月いくら使えるか自動計算", subtitle: "入力した情報から自動で出します")
                FeatureRow(emoji: "🛡️", title: "制度や支援も一緒に確認", subtitle: "あなたが使える給付金を教えます")
            }
            .padding(.horizontal, 32)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.5), value: appeared)

            Spacer()

            // 開始ボタン
            VStack(spacing: 12) {
                Button(action: onStart) {
                    Text("はじめる")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppColor.primaryGradient)
                        .cornerRadius(16)
                }

                Text("所要時間 約3〜5分")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.7), value: appeared)
        }
        .onAppear { appeared = true }
    }
}

// MARK: - 機能紹介行
private struct FeatureRow: View {
    let emoji: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 44, height: 44)
                .background(AppColor.primaryLight)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
            }

            Spacer()
        }
    }
}

#Preview {
    ZStack {
        AppColor.onboardingGradient.ignoresSafeArea()
        WelcomeStepView(onStart: {})
    }
}
