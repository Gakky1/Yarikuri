import SwiftUI

// MARK: - 増やす部屋（着せ替え対応）
struct GrowAnimationView: View {
    @EnvironmentObject var appState: AppState
    @State private var showCustomize = false

    private var config: RoomConfig { appState.growRoom }

    private var roomLevel: Int {
        switch appState.growActionsTotal {
        case 0..<3:   return 1
        case 3..<7:   return 2
        case 7..<13:  return 3
        case 13..<21: return 4
        default:      return 5
        }
    }

    private var mascotLevel: Int {
        let c = appState.completedTaskIds.count
        switch c {
        case 0..<3:   return 1
        case 3..<7:   return 2
        case 7..<13:  return 3
        case 13..<21: return 4
        default:      return 5
        }
    }

    private var items: Set<String> { Set(config.activeItems) }

    private var speechText: String {
        let hasItem = { items.contains($0) }
        if hasItem("trophy") && hasItem("wine") { return "成功を祝えそう🥂" }
        if hasItem("bag")    && hasItem("art")  { return "センスいい生活できそう🎨" }
        if hasItem("dining") && hasItem("wine") { return "豪華ディナーできそう🍽️" }
        if hasItem("trophy") { return "目標達成できちゃいそう！" }
        if hasItem("bag")    { return "欲しいもの買えそう！👜" }
        switch roomLevel {
        case 1: return "もっと増やせそう！📈"
        case 2: return "いいもの食べれそう🍱"
        case 3: return "欲しいもの買えそう！👜"
        case 4: return "贅沢できちゃいそう🥩"
        default: return "夢の暮らしになれそう🥂"
        }
    }

    @State private var bobOffset: CGFloat = 0
    @State private var jumpOffset: CGFloat = 0
    @State private var bubbleOpacity: Double = 0
    @State private var glowPulse: CGFloat = 1.0

    private let floorTopY: CGFloat = 53

    private var wallGradient: LinearGradient {
        let colors: [Color]
        switch config.wallStyle {
        case 1:  colors = [Color(red: 0.88, green: 0.94, blue: 1.00), Color(red: 0.80, green: 0.89, blue: 0.98)]
        case 2:  colors = [Color(red: 0.88, green: 0.96, blue: 0.88), Color(red: 0.80, green: 0.91, blue: 0.80)]
        case 3:  colors = [Color(red: 0.94, green: 0.90, blue: 0.98), Color(red: 0.88, green: 0.84, blue: 0.96)]
        default: colors = [Color(red: 0.99, green: 0.97, blue: 0.88), Color(red: 0.97, green: 0.93, blue: 0.78)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var floorGradient: LinearGradient {
        let colors: [Color]
        switch config.floorStyle {
        case 1:  colors = [Color(red: 0.82, green: 0.80, blue: 0.78), Color(red: 0.72, green: 0.70, blue: 0.68)]
        default: colors = [Color(red: 0.72, green: 0.54, blue: 0.36), Color(red: 0.62, green: 0.45, blue: 0.28)]
        }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        ZStack {
            // 壁
            RoundedRectangle(cornerRadius: 20)
                .fill(wallGradient)

            // 天井ライン
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(red: 0.88, green: 0.76, blue: 0.50).opacity(0.30))
                    .frame(height: 2)
                    .padding(.top, 14)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // Lv5: 黄金オーラ
            if roomLevel >= 5 {
                Ellipse()
                    .fill(Color(red: 1.0, green: 0.90, blue: 0.40).opacity(0.18))
                    .frame(width: 160, height: 100)
                    .blur(radius: 20)
                    .scaleEffect(glowPulse)
                    .offset(y: -30)
            }

            // 幅木
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color(red: 0.90, green: 0.82, blue: 0.62))
                    .frame(height: 3)
                    .padding(.bottom, 52)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // 床
            VStack(spacing: 0) {
                Spacer()
                RoundedRectangle(cornerRadius: 20)
                    .fill(floorGradient)
                    .frame(height: 52)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // ドア（常時）
            doorView.offset(x: -100, y: floorTopY - 28)

            // 窓（常時）
            luxuryWindowView.offset(x: 88, y: -58)

            // アイテム
            if items.contains("art") {
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.88, green: 0.78, blue: 0.50))
                        .frame(width: 30, height: 24)
                    Text("🎨").font(.system(size: 13))
                }
                .offset(x: -62, y: -50)
            }

            if items.contains("trophy") {
                Text("🏆").font(.system(size: 22))
                    .offset(x: 56, y: -60)
            }

            if items.contains("plant") {
                Text("🌿").font(.system(size: 26))
                    .offset(x: -82, y: floorTopY - 16)
            }

            if items.contains("dining") {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.94, green: 0.93, blue: 0.91))
                        .frame(width: 38, height: 7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(red: 0.82, green: 0.80, blue: 0.76), lineWidth: 1)
                        )
                        .offset(y: 10)
                    Rectangle()
                        .fill(Color(red: 0.82, green: 0.80, blue: 0.76))
                        .frame(width: 3, height: 12)
                        .offset(y: 18)
                    Text(roomLevel >= 4 ? "🥩" : "🍱").font(.system(size: 18))
                        .offset(y: 1)
                }
                .offset(x: -48, y: floorTopY - 22)
            }

            if items.contains("bag") {
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.88, green: 0.78, blue: 0.50))
                        .frame(width: 34, height: 5)
                        .offset(y: 18)
                    Rectangle()
                        .fill(Color(red: 0.88, green: 0.78, blue: 0.50))
                        .frame(width: 3, height: 20)
                        .offset(y: 28)
                    Text("👜").font(.system(size: 22))
                        .offset(y: 4)
                }
                .offset(x: 96, y: floorTopY - 26)
            }

            if items.contains("wine") {
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.94, green: 0.93, blue: 0.91))
                        .frame(width: 32, height: 6)
                        .offset(y: 10)
                    Rectangle()
                        .fill(Color(red: 0.82, green: 0.80, blue: 0.76))
                        .frame(width: 3, height: 12)
                        .offset(y: 17)
                    Text("🥂").font(.system(size: 18))
                        .offset(y: 1)
                }
                .offset(x: 42, y: floorTopY - 22)
            }

            // やりくりん
            CoronView(size: 50, emotion: .happy, animate: true, level: mascotLevel)
                .frame(width: 68, height: 76)
                .offset(x: -10, y: floorTopY - 76/2 + jumpOffset)
                .onTapGesture { bounce() }

            // 吹き出し
            speechBubble
                .offset(x: 50, y: floorTopY - 88 + bobOffset * 0.4)
                .opacity(bubbleOpacity)

            // 着せ替えボタン
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showCustomize = true }) {
                        HStack(spacing: 3) {
                            Image(systemName: "tshirt")
                                .font(.system(size: 9))
                            Text("着せ替え")
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .foregroundColor(AppColor.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.82))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.08), radius: 3)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
                }
            }
        }
        .frame(height: 210)
        .shadow(color: Color(red: 0.88, green: 0.78, blue: 0.48).opacity(0.22), radius: 10, x: 0, y: 4)
        .onAppear { startAnimations() }
        .sheet(isPresented: $showCustomize) {
            RoomCustomizeSheet(isProtect: false)
                .environmentObject(appState)
        }
    }

    // MARK: - ドア（豪華ゴールド）
    private var doorView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.75, green: 0.62, blue: 0.35))
                .frame(width: 36, height: 60)
            RoundedRectangle(cornerRadius: 2)
                .fill(LinearGradient(
                    colors: [Color(red: 0.96, green: 0.92, blue: 0.75),
                             Color(red: 0.90, green: 0.84, blue: 0.62)],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(width: 32, height: 56)
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(red: 0.82, green: 0.70, blue: 0.42).opacity(0.8), lineWidth: 1.5)
                .frame(width: 24, height: 20).offset(y: -10)
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(red: 0.82, green: 0.70, blue: 0.42).opacity(0.8), lineWidth: 1.5)
                .frame(width: 24, height: 18).offset(y: 12)
            Circle()
                .fill(Color(red: 0.92, green: 0.78, blue: 0.30))
                .frame(width: 6, height: 6).offset(x: 11, y: 2)
        }
    }

    // MARK: - 豪華な窓
    private var luxuryWindowView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(LinearGradient(
                    colors: [Color(red: 0.88, green: 0.97, blue: 1.00),
                             Color(red: 0.75, green: 0.90, blue: 1.00)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: 38, height: 44)
            Rectangle()
                .fill(Color(red: 0.88, green: 0.78, blue: 0.50))
                .frame(width: 1.5, height: 44)
            Rectangle()
                .fill(Color(red: 0.88, green: 0.78, blue: 0.50))
                .frame(width: 38, height: 1.5)
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color(red: 0.88, green: 0.78, blue: 0.50), lineWidth: 2)
                .frame(width: 38, height: 44)
        }
    }

    // MARK: - 吹き出し
    private var speechBubble: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(speechText)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(red: 0.28, green: 0.18, blue: 0.04))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.92, green: 0.80, blue: 0.42).opacity(0.5), lineWidth: 1)
                )
            TriangleShape()
                .fill(Color.white.opacity(0.95))
                .frame(width: 11, height: 6)
                .rotationEffect(.degrees(180))
                .offset(x: 11, y: -1)
        }
    }

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
            bobOffset = -5
        }
        withAnimation(.easeInOut(duration: 0.6)) {
            bubbleOpacity = 1
        }
        if roomLevel >= 5 {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                glowPulse = 1.18
            }
        }
    }

    private func bounce() {
        withAnimation(.interpolatingSpring(stiffness: 400, damping: 8)) {
            jumpOffset = -34
        }
        withAnimation(.interpolatingSpring(stiffness: 180, damping: 12).delay(0.13)) {
            jumpOffset = 0
        }
    }
}
