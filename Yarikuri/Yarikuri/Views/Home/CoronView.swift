import SwiftUI

// MARK: - コロンの感情
enum CoronEmotion {
    case normal    // 通常：穏やかな笑顔
    case happy     // 嬉しい：目が三日月、口が大きく開く
    case cheer     // 応援：片手を上げる
    case worry     // 心配：眉が八の字、口がへの字
    case celebrate // 喜び：両手を上げる、目がキラキラ
}

// MARK: - やりくりんキャラクタービュー
struct CoronView: View {
    var size: CGFloat = 80
    var emotion: CoronEmotion = .normal
    var animate: Bool = true
    var level: Int = 1   // 1〜5、レベルに応じて外見が変わる

    @State private var bobOffset: CGFloat = 0
    @State private var squishY: CGFloat = 1.0
    @State private var squishX: CGFloat = 1.0
    @State private var blinkScale: CGFloat = 1.0
    @State private var cheekOpacity: Double = 0.50
    @State private var handLeftAngle: Double = 0
    @State private var handRightAngle: Double = 0
    @State private var auraScale: CGFloat = 1.0
    @State private var starOpacity: Double = 0.5

    private var bodyW: CGFloat { size * 1.0 }
    private var bodyH: CGFloat { size * 0.88 }
    private var eyeSize: CGFloat { size * 0.135 }
    private var coinSize: CGFloat { size * 0.22 }

    // ── レベル別 ボディグラデーション ──────────────────
    private var bodyGradient: LinearGradient {
        let colors: [Color]
        switch level {
        case 1, 2:
            colors = [Color(red: 0.99, green: 0.96, blue: 0.88),
                      Color(red: 0.97, green: 0.91, blue: 0.76)]
        case 3:
            colors = [Color(red: 0.99, green: 0.97, blue: 0.80),
                      Color(red: 0.97, green: 0.93, blue: 0.65)]
        case 4:
            colors = [Color(red: 0.88, green: 0.98, blue: 0.82),
                      Color(red: 0.78, green: 0.94, blue: 0.68)]
        default: // 5
            colors = [Color(red: 1.00, green: 0.96, blue: 0.74),
                      Color(red: 0.99, green: 0.91, blue: 0.58)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // ── レベル別 影の色 ─────────────────────────────
    private var shadowColor: Color {
        switch level {
        case 4:  return Color(red: 0.35, green: 0.82, blue: 0.45).opacity(0.5)
        case 5:  return Color(red: 0.95, green: 0.85, blue: 0.48).opacity(0.40)
        default: return Color(red: 0.88, green: 0.75, blue: 0.50).opacity(0.35)
        }
    }

    // ── レベル別 頬の基本透明度 ──────────────────────
    private var cheekBase: Double {
        switch level {
        case 1: return 0.42
        case 2: return 0.55
        default: return 0.68
        }
    }

    // ── レベル別 足の色 ────────────────────────────
    private var footColor: Color {
        switch level {
        case 4:  return Color(red: 0.62, green: 0.88, blue: 0.60)
        case 5:  return Color(red: 0.98, green: 0.90, blue: 0.60)
        default: return Color(red: 0.93, green: 0.82, blue: 0.62)
        }
    }

    var body: some View {
        ZStack {
            // ── Lv5：黄金オーラ（最背面）──────────────
            if level >= 5 {
                Ellipse()
                    .fill(Color(red: 0.99, green: 0.94, blue: 0.65).opacity(0.18))
                    .frame(width: bodyW * 1.7, height: bodyH * 1.7)
                    .blur(radius: 16)
                    .scaleEffect(auraScale)
                    .offset(y: bobOffset)
            }

            // ── Lv4+：浮かぶ星 ──────────────────────
            if level >= 4 {
                Text("✦")
                    .font(.system(size: size * 0.12, weight: .bold))
                    .foregroundColor(level >= 5
                                     ? Color(red: 0.99, green: 0.91, blue: 0.56)
                                     : Color(red: 0.35, green: 0.80, blue: 0.48))
                    .opacity(starOpacity)
                    .offset(x: -size * 0.60, y: -size * 0.30 + bobOffset * 0.5)
                Text("✦")
                    .font(.system(size: size * 0.09, weight: .bold))
                    .foregroundColor(level >= 5
                                     ? Color(red: 0.99, green: 0.91, blue: 0.56)
                                     : Color(red: 0.35, green: 0.80, blue: 0.48))
                    .opacity(starOpacity)
                    .offset(x: size * 0.56, y: -size * 0.22 + bobOffset * 0.5)
            }

            // ── 足 ──────────────────────────────────
            HStack(spacing: size * 0.16) {
                footShape
                footShape
            }
            .offset(y: bodyH * 0.44 + bobOffset)

            // ── 体 ──────────────────────────────────
            ZStack {
                Ellipse()
                    .fill(bodyGradient)
                    .frame(width: bodyW * squishX, height: bodyH * squishY)
                    .shadow(color: shadowColor, radius: 8, x: 0, y: 5)

                // ハイライト
                Ellipse()
                    .fill(Color.white.opacity(0.38))
                    .frame(width: bodyW * 0.58 * squishX, height: bodyH * 0.28 * squishY)
                    .offset(y: -bodyH * 0.22)

                // コインマーク
                coinMark

                // 頬
                HStack(spacing: bodyW * 0.44) {
                    cheekShape
                    cheekShape
                }
                .offset(y: -bodyH * 0.06)
                .opacity(cheekOpacity)

                // 目
                HStack(spacing: bodyW * 0.26) {
                    eyeView(isLeft: true)
                    eyeView(isLeft: false)
                }
                .offset(y: -bodyH * 0.2)

                // 口
                mouthView.offset(y: -bodyH * 0.03)
            }
            .offset(y: bobOffset)

            // ── Lv3-4：ミニベレー帽 ─────────────────
            if level == 3 || level == 4 {
                miniHat
                    .offset(y: bobOffset - bodyH * 0.47)
            }

            // ── Lv5：王冠 ───────────────────────────
            if level >= 5 {
                crownView
                    .offset(y: bobOffset - bodyH * 0.52)
            }

            // ── 手 ──────────────────────────────────
            handLeft
                .offset(x: -bodyW * 0.52, y: -bodyH * 0.05 + bobOffset)
            handRight
                .offset(x: bodyW * 0.52, y: -bodyH * 0.05 + bobOffset)
        }
        .frame(width: size * 1.5, height: size * 1.65)
        .onAppear {
            cheekOpacity = cheekBase
            if animate { startAnimations() }
        }
    }

    // MARK: - 足
    private var footShape: some View {
        Ellipse()
            .fill(footColor)
            .frame(width: size * 0.22, height: size * 0.14)
    }

    // MARK: - 頬
    private var cheekShape: some View {
        Ellipse()
            .fill(Color(red: 1.0, green: 0.72, blue: 0.68))
            .frame(width: size * 0.16, height: size * 0.10)
            .blur(radius: size * 0.025)
    }

    // MARK: - コインマーク（レベル別）
    private var coinMark: some View {
        ZStack {
            Circle()
                .fill(level >= 5
                      ? Color(red: 0.99, green: 0.85, blue: 0.45)
                      : Color(red: 0.98, green: 0.82, blue: 0.32))
                .frame(width: coinSize, height: coinSize)
            Circle()
                .fill(level >= 5
                      ? Color(red: 1.00, green: 0.92, blue: 0.62)
                      : Color(red: 0.98, green: 0.88, blue: 0.48))
                .frame(width: coinSize * 0.72, height: coinSize * 0.72)
            Text("¥")
                .font(.system(size: coinSize * 0.52, weight: .black))
                .foregroundColor(level >= 5
                                 ? Color(red: 0.60, green: 0.35, blue: 0.02)
                                 : Color(red: 0.72, green: 0.44, blue: 0.08))
        }
        .offset(y: bodyH * 0.1)
    }

    // MARK: - ミニベレー帽（Lv3-4）
    private var miniHat: some View {
        let hatColor = Color(red: 0.55, green: 0.36, blue: 0.16)
        let brimColor = Color(red: 0.48, green: 0.30, blue: 0.12)
        return ZStack {
            // つば（ブリム）
            Capsule()
                .fill(brimColor)
                .frame(width: size * 0.50, height: size * 0.07)
            // ドーム部分
            Ellipse()
                .fill(hatColor)
                .frame(width: size * 0.34, height: size * 0.20)
                .offset(y: -size * 0.10)
            // Lv4はリボン
            if level >= 4 {
                Capsule()
                    .fill(Color(red: 0.95, green: 0.82, blue: 0.20))
                    .frame(width: size * 0.36, height: size * 0.045)
                    .offset(y: -size * 0.005)
            }
        }
    }

    // MARK: - 王冠（Lv5）
    private var crownView: some View {
        let gold = Color(red: 0.99, green: 0.90, blue: 0.55)
        let deepGold = Color(red: 0.95, green: 0.82, blue: 0.40)
        return ZStack {
            // 台座
            RoundedRectangle(cornerRadius: 2)
                .fill(gold)
                .frame(width: size * 0.50, height: size * 0.10)
            // 3つのピーク
            HStack(spacing: size * 0.05) {
                TriangleShape()
                    .fill(gold)
                    .frame(width: size * 0.10, height: size * 0.13)
                TriangleShape()
                    .fill(gold)
                    .frame(width: size * 0.10, height: size * 0.17)
                    .offset(y: -size * 0.02)
                TriangleShape()
                    .fill(gold)
                    .frame(width: size * 0.10, height: size * 0.13)
            }
            .offset(y: -size * 0.11)
            // 宝石
            HStack(spacing: size * 0.10) {
                Circle().fill(Color(red: 0.92, green: 0.30, blue: 0.30))
                    .frame(width: size * 0.055, height: size * 0.055)
                Circle().fill(Color(red: 0.28, green: 0.50, blue: 0.95))
                    .frame(width: size * 0.055, height: size * 0.055)
                    .offset(y: -size * 0.01)
                Circle().fill(Color(red: 0.92, green: 0.30, blue: 0.30))
                    .frame(width: size * 0.055, height: size * 0.055)
            }
            .offset(y: -size * 0.035)
            // 台座の下ライン
            Rectangle()
                .fill(deepGold)
                .frame(width: size * 0.50, height: size * 0.012)
                .offset(y: size * 0.044)
        }
    }

    // MARK: - 目
    @ViewBuilder
    private func eyeView(isLeft: Bool) -> some View {
        switch emotion {
        case .happy, .celebrate:
            CrescentEye(size: eyeSize)
        case .worry:
            ZStack {
                Ellipse()
                    .fill(Color(red: 0.15, green: 0.12, blue: 0.1))
                    .frame(width: eyeSize * 0.8, height: eyeSize * blinkScale)
                Circle()
                    .fill(Color.white)
                    .frame(width: eyeSize * 0.28, height: eyeSize * 0.28)
                    .offset(x: eyeSize * 0.15, y: -eyeSize * 0.18)
            }
            .rotationEffect(.degrees(isLeft ? 10 : -10))
        default:
            ZStack {
                Ellipse()
                    .fill(Color(red: 0.15, green: 0.12, blue: 0.1))
                    .frame(width: eyeSize * 0.82, height: eyeSize * blinkScale)
                Circle()
                    .fill(Color.white)
                    .frame(width: eyeSize * 0.30, height: eyeSize * 0.30)
                    .offset(x: eyeSize * 0.16, y: -eyeSize * 0.20)
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: eyeSize * 0.14, height: eyeSize * 0.14)
                    .offset(x: -eyeSize * 0.08, y: eyeSize * 0.10)
            }
        }
    }

    // MARK: - 口
    @ViewBuilder
    private var mouthView: some View {
        switch emotion {
        case .happy, .celebrate:
            BigSmileMouth(width: bodyW * 0.38, height: bodyH * 0.12)
                .stroke(Color(red: 0.55, green: 0.3, blue: 0.15),
                        style: StrokeStyle(lineWidth: size * 0.028, lineCap: .round))
        case .worry:
            WorryMouth(width: bodyW * 0.28, height: bodyH * 0.06)
                .stroke(Color(red: 0.55, green: 0.3, blue: 0.15),
                        style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))
        default:
            SmileMouth(width: bodyW * 0.32, height: bodyH * 0.09)
                .stroke(Color(red: 0.55, green: 0.3, blue: 0.15),
                        style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))
        }
    }

    // MARK: - 手（左）
    private var handLeft: some View {
        let angle: Double = {
            switch emotion {
            case .cheer:     return -100 + handLeftAngle
            case .celebrate: return -110 + handLeftAngle
            default:         return  -30 + handLeftAngle
            }
        }()
        let handColor = level >= 5
            ? Color(red: 0.99, green: 0.94, blue: 0.70)
            : Color(red: 0.99, green: 0.93, blue: 0.80)
        return Capsule()
            .fill(handColor)
            .frame(width: size * 0.14, height: size * 0.36)
            .rotationEffect(.degrees(angle), anchor: .bottom)
            .overlay(
                Ellipse()
                    .fill(handColor.opacity(0.8))
                    .frame(width: size * 0.12, height: size * 0.12)
                    .offset(y: -size * 0.12),
                alignment: .top
            )
    }

    // MARK: - 手（右）
    private var handRight: some View {
        let angle: Double = {
            switch emotion {
            case .cheer:     return  30 + handRightAngle
            case .celebrate: return 110 + handRightAngle
            default:         return  30 + handRightAngle
            }
        }()
        let handColor = level >= 5
            ? Color(red: 0.99, green: 0.94, blue: 0.70)
            : Color(red: 0.99, green: 0.93, blue: 0.80)
        return Capsule()
            .fill(handColor)
            .frame(width: size * 0.14, height: size * 0.36)
            .rotationEffect(.degrees(angle), anchor: .bottom)
            .overlay(
                Ellipse()
                    .fill(handColor.opacity(0.8))
                    .frame(width: size * 0.12, height: size * 0.12)
                    .offset(y: -size * 0.12),
                alignment: .top
            )
    }

    // MARK: - アニメーション
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            bobOffset = -size * 0.07
        }
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            squishY = 0.97; squishX = 1.03
        }
        Timer.scheduledTimer(withTimeInterval: 2.8, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.08)) { blinkScale = 0.08 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) { blinkScale = 1.0 }
            }
        }
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
            cheekOpacity = cheekBase + 0.18
        }
        withAnimation(.easeInOut(duration: 0.72).repeatForever(autoreverses: true)) {
            handLeftAngle = 8
        }
        withAnimation(.easeInOut(duration: 0.72).delay(0.18).repeatForever(autoreverses: true)) {
            handRightAngle = -8
        }
        // Lv4+：星の明滅
        if level >= 4 {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                starOpacity = 1.0
            }
        }
        // Lv5：オーラの脈動
        if level >= 5 {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                auraScale = 1.18
            }
        }
    }
}

// MARK: - 三角形 Shape（王冠のピーク用）
struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - 口のShapes

struct SmileMouth: Shape {
    let width: CGFloat; let height: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        p.move(to: CGPoint(x: cx - width / 2, y: cy))
        p.addQuadCurve(to: CGPoint(x: cx + width / 2, y: cy),
                       control: CGPoint(x: cx, y: cy + height))
        return p
    }
}

struct BigSmileMouth: Shape {
    let width: CGFloat; let height: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        p.move(to: CGPoint(x: cx - width / 2, y: cy - height * 0.2))
        p.addCurve(to: CGPoint(x: cx + width / 2, y: cy - height * 0.2),
                   control1: CGPoint(x: cx - width * 0.25, y: cy + height * 1.2),
                   control2: CGPoint(x: cx + width * 0.25, y: cy + height * 1.2))
        return p
    }
}

struct WorryMouth: Shape {
    let width: CGFloat; let height: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        p.move(to: CGPoint(x: cx - width / 2, y: cy + height * 0.5))
        p.addQuadCurve(to: CGPoint(x: cx + width / 2, y: cy + height * 0.5),
                       control: CGPoint(x: cx, y: cy - height * 0.5))
        return p
    }
}

// MARK: - 三日月目（^形）
struct CrescentEye: View {
    let size: CGFloat
    var body: some View {
        Path { p in
            let w = size * 0.85, h = size * 0.55
            p.move(to: CGPoint(x: 0, y: h * 0.85))
            p.addQuadCurve(to: CGPoint(x: w, y: h * 0.85),
                           control: CGPoint(x: w / 2, y: 0))
        }
        .stroke(Color(red: 0.15, green: 0.12, blue: 0.1),
                style: StrokeStyle(lineWidth: size * 0.28, lineCap: .round))
        .frame(width: size * 0.85, height: size * 0.55)
    }
}

// MARK: - Preview（全レベル確認用）
#Preview("全レベル") {
    VStack(spacing: 8) {
        HStack(spacing: 12) {
            ForEach(1...5, id: \.self) { lv in
                VStack(spacing: 4) {
                    CoronView(size: 58, emotion: .normal, animate: false, level: lv)
                    Text("Lv\(lv)").font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
        }
        HStack(spacing: 12) {
            CoronView(size: 68, emotion: .happy, animate: false, level: 3)
            CoronView(size: 68, emotion: .cheer, animate: false, level: 4)
            CoronView(size: 68, emotion: .celebrate, animate: false, level: 5)
        }
    }
    .padding(20)
    .background(Color(red: 0.97, green: 0.97, blue: 0.95))
}
