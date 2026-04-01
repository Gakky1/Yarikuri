import SwiftUI

// MARK: - 褒めアイテムモデル
struct PraiseItem: Identifiable, Equatable {
    let id: UUID = UUID()
    let text: String
    let emotion: CoronEmotion

    static func == (lhs: PraiseItem, rhs: PraiseItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - やりくりんが褒める中央ポップアップ
struct YarikurinPraiseView: View {
    let item: PraiseItem
    @EnvironmentObject var appState: AppState

    @State private var cardScale: CGFloat    = 0.4
    @State private var cardOpacity: Double   = 0
    @State private var backdropOpacity: Double = 0
    @State private var particleOffset: CGFloat = 0
    @State private var particleOpacity: Double = 0
    @State private var coronBounce: CGFloat  = 0

    // 周囲に浮かぶ絵文字パーティクル
    private struct Particle {
        let emoji: String
        let x: CGFloat
        let y: CGFloat
        let rotation: Double
        let delay: Double
    }
    private let particles: [Particle] = [
        .init(emoji: "✨", x: -88, y: -108, rotation: -20, delay: 0.10),
        .init(emoji: "🌟", x:  82, y: -102, rotation:  15, delay: 0.14),
        .init(emoji: "🎉", x: -58, y:  -68, rotation: -30, delay: 0.18),
        .init(emoji: "⭐",  x:  98, y:  -58, rotation:  22, delay: 0.12),
        .init(emoji: "✨", x:  36, y: -124, rotation:  10, delay: 0.20),
        .init(emoji: "🌟", x: -108, y: -48, rotation: -12, delay: 0.16),
        .init(emoji: "🎊", x:   2, y: -132, rotation:   5, delay: 0.08),
    ]

    var body: some View {
        ZStack {
            // ── 暗転バックドロップ ────────────────────
            Color.black.opacity(0.42)
                .ignoresSafeArea()
                .opacity(backdropOpacity)
                .onTapGesture { animateOut() }

            // ── 中央カード ─────────────────────────────
            VStack(spacing: 0) {

                // パーティクル + やりくりん ゾーン
                ZStack {
                    // グロー
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppColor.primary.opacity(0.18), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 72
                            )
                        )
                        .frame(width: 144, height: 144)

                    // パーティクル
                    ForEach(particles.indices, id: \.self) { i in
                        let p = particles[i]
                        Text(p.emoji)
                            .font(.system(size: 20))
                            .offset(
                                x: p.x * particleOffset,
                                y: p.y * particleOffset
                            )
                            .rotationEffect(.degrees(p.rotation))
                            .opacity(particleOpacity)
                            .animation(
                                .spring(response: 0.55, dampingFraction: 0.58)
                                    .delay(p.delay),
                                value: particleOffset
                            )
                    }

                    // やりくりん本体（上下バウンス）
                    CoronView(size: 80, emotion: item.emotion, animate: true)
                        .frame(width: 96, height: 104)
                        .offset(y: coronBounce)
                        .animation(
                            .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                            value: coronBounce
                        )
                }
                .frame(height: 148)

                // 褒めテキスト
                Text(item.text)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 20)

                // 閉じるボタン
                Button(action: { animateOut() }) {
                    Text("閉じる")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColor.sectionBackground)
                        .cornerRadius(14)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white)
                    .shadow(color: AppColor.primary.opacity(0.22), radius: 28, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(AppColor.primary.opacity(0.14), lineWidth: 1.5)
            )
            .padding(.horizontal, 36)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
        }
        .onAppear { animateIn() }
    }

    // MARK: - アニメーション
    private func animateIn() {
        // カード飛び出し
        withAnimation(.spring(response: 0.48, dampingFraction: 0.62)) {
            cardScale      = 1.0
            cardOpacity    = 1.0
            backdropOpacity = 1.0
        }
        // パーティクルバースト
        withAnimation(.spring(response: 0.55, dampingFraction: 0.55).delay(0.05)) {
            particleOffset  = 1.0
            particleOpacity = 1.0
        }
        // やりくりんバウンス開始
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            coronBounce = -6
        }
    }

    private func animateOut() {
        withAnimation(.easeOut(duration: 0.22)) {
            cardScale       = 0.88
            cardOpacity     = 0
            backdropOpacity = 0
            particleOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            appState.currentPraise = nil
        }
    }
}
