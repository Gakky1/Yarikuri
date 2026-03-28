import SwiftUI

// MARK: - ルートビュー
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var hasShownSplash = false

    var body: some View {
        Group {
            if !hasShownSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                            withAnimation(.easeInOut(duration: 0.5)) {
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
        .animation(.easeInOut(duration: 0.5), value: hasShownSplash)
    }
}

// MARK: - スプラッシュ画面（やりくりんが卵から生まれる）
struct SplashView: View {
    @State private var coronScale: CGFloat = 0.1
    @State private var coronOpacity: Double = 0.0
    @State private var coronY: CGFloat = 30
    @State private var burstScale: CGFloat = 0.2
    @State private var burstOpacity: Double = 0.85
    @State private var particlesVisible = false

    var body: some View {
        ZStack {
            AppColor.onboardingGradient.ignoresSafeArea()

            if particlesVisible {
                SplashParticlesView()
            }

            ZStack {
                // バースト光（卵が弾ける）
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.72), Color.white.opacity(0)],
                            center: .center, startRadius: 0, endRadius: 90
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(burstScale)
                    .opacity(burstOpacity)

                // やりくりん
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColor.primaryLight, AppColor.accentLight],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: AppColor.primary.opacity(0.32), radius: 18, x: 0, y: 8)
                    CoronView(size: 70, emotion: .celebrate, animate: true)
                }
                .scaleEffect(coronScale)
                .opacity(coronOpacity)
                .offset(y: coronY)
            }
            .frame(width: 200, height: 200)
        }
        .onAppear { startAnimation() }
    }

    private func startAnimation() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.52)) {
            burstScale = 1.35
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.spring(response: 0.48, dampingFraction: 0.48)) {
                coronScale = 1.22
                coronOpacity = 1.0
                coronY = -12
                burstOpacity = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.60) {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.42)) {
                coronScale = 0.90
                coronY = 8
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.82) {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.52)) {
                coronScale = 1.0
                coronY = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.82) {
            particlesVisible = true
        }
    }
}

// MARK: - スプラッシュパーティクル
private struct SplashParticlesView: View {
    struct Particle: Identifiable {
        let id = UUID()
        let angle: Double
        let distance: CGFloat
        let size: CGFloat
        let color: Color
    }

    @State private var progress: Double = 0

    private let particles: [Particle] = (0..<22).map { i in
        let palette: [Color] = [
            Color(red: 0.52, green: 0.36, blue: 0.88),
            Color(red: 0.36, green: 0.72, blue: 0.92),
            Color(red: 1.00, green: 0.84, blue: 0.28),
            Color(red: 0.92, green: 0.52, blue: 0.74),
        ]
        return Particle(
            angle: Double(i) * (360.0 / 22) + Double.random(in: -9...9),
            distance: CGFloat.random(in: 75...145),
            size: CGFloat.random(in: 5...12),
            color: palette[i % palette.count].opacity(Double.random(in: 0.60...0.90))
        )
    }

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Circle()
                    .fill(p.color)
                    .frame(
                        width:  p.size * CGFloat(1 - progress * 0.35),
                        height: p.size * CGFloat(1 - progress * 0.35)
                    )
                    .offset(
                        x: CGFloat(cos(p.angle * .pi / 180)) * p.distance * CGFloat(progress),
                        y: CGFloat(sin(p.angle * .pi / 180)) * p.distance * CGFloat(progress)
                    )
                    .opacity(progress < 0.45 ? progress * 2.2 : (1.0 - progress) * 1.9)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                progress = 1.0
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject({
            let s = AppState()
            return s
        }())
}

#Preview("Demo - Home") {
    ContentView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
