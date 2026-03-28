import SwiftUI

// MARK: - ルートビュー
// オンボーディング完了済みならメイン画面、未完了ならオンボーディングを表示

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var hasShownSplash = false

    var body: some View {
        Group {
            if !hasShownSplash {
                SplashView()
                    .onAppear {
                        // スプラッシュを1.5秒表示後にメインへ
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                hasShownSplash = true
                            }
                        }
                    }
            } else if appState.userProfile?.isOnboardingCompleted == true {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingFlowView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.userProfile?.isOnboardingCompleted)
        .animation(.easeInOut(duration: 0.4), value: hasShownSplash)
    }
}

// MARK: - スプラッシュ画面
struct SplashView: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            AppColor.onboardingGradient.ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColor.primaryLight)
                        .frame(width: 100, height: 100)
                    Text("🐷")
                        .font(.system(size: 52))
                }

                Text("やりくり")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject({
            let s = AppState()
            // デモデータを使う場合はコメントを外してください
            // s.loadDemoData()
            return s
        }())
}

// MARK: - デモ用プレビュー（ホーム画面から確認する場合）
#Preview("Demo - Home") {
    ContentView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
