import SwiftUI

// MARK: - 守る部屋（着せ替え対応）
struct ProtectAnimationView: View {
    @EnvironmentObject var appState: AppState
    @State private var showCustomize = false

    private var config: RoomConfig { appState.protectRoom }

    private var roomLevel: Int {
        switch appState.protectActionsTotal {
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
        if hasItem("coffee") && hasItem("suitcase") { return "旅先でもカフェできそう✈️" }
        if hasItem("book")   && hasItem("candle")   { return "ゆっくり読書できそう📚" }
        if hasItem("frame")  && hasItem("suitcase") { return "旅の思い出増えそう🗼" }
        if hasItem("coffee")   { return "カフェ行けそうかも☕" }
        if hasItem("suitcase") { return "旅行できちゃいそう✈️" }
        switch roomLevel {
        case 1: return "節約できそう！💪"
        case 2: return "カフェ行けそうかも☕"
        case 3: return "旅行できちゃいそう✈️"
        case 4: return "どこでも行けそう〜🗺️"
        default: return "夢、全部叶いそう！✨"
        }
    }

    @State private var bobOffset: CGFloat = 0
    @State private var bubbleOpacity: Double = 0

    private let floorTopY: CGFloat = 53

    private var wallGradient: LinearGradient {
        let colors: [Color]
        switch config.wallStyle {
        case 1:  colors = [Color(red: 0.88, green: 0.94, blue: 1.00), Color(red: 0.80, green: 0.89, blue: 0.98)]
        case 2:  colors = [Color(red: 0.88, green: 0.96, blue: 0.88), Color(red: 0.80, green: 0.91, blue: 0.80)]
        case 3:  colors = [Color(red: 0.94, green: 0.90, blue: 0.98), Color(red: 0.88, green: 0.84, blue: 0.96)]
        default: colors = [Color(red: 0.99, green: 0.96, blue: 0.88), Color(red: 0.96, green: 0.91, blue: 0.80)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var floorGradient: LinearGradient {
        let colors: [Color]
        switch config.floorStyle {
        case 1:  colors = [Color(red: 0.88, green: 0.86, blue: 0.84), Color(red: 0.80, green: 0.78, blue: 0.76)]
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
                    .fill(Color(red: 0.84, green: 0.70, blue: 0.52).opacity(0.25))
                    .frame(height: 2)
                    .padding(.top, 14)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // 幅木
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color(red: 0.84, green: 0.70, blue: 0.52))
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
            windowView.offset(x: 88, y: -58)

            // アイテム
            if items.contains("frame") {
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.60, green: 0.42, blue: 0.22))
                        .frame(width: 30, height: 24)
                    Text("🗼").font(.system(size: 13))
                }
                .offset(x: -60, y: -50)
            }

            if items.contains("plant") {
                Text("🪴").font(.system(size: 26))
                    .offset(x: -82, y: floorTopY - 16)
            }

            if items.contains("coffee") {
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.55, green: 0.38, blue: 0.22))
                        .frame(width: 34, height: 6)
                        .offset(y: 9)
                    Rectangle()
                        .fill(Color(red: 0.50, green: 0.33, blue: 0.18))
                        .frame(width: 3, height: 12)
                        .offset(y: 16)
                    Text("☕").font(.system(size: 18))
                        .offset(y: 1)
                }
                .offset(x: -50, y: floorTopY - 20)
            }

            if items.contains("suitcase") {
                Text("🧳").font(.system(size: 30))
                    .offset(x: 100, y: floorTopY - 18)
            }

            if items.contains("book") {
                Text("📚").font(.system(size: 22))
                    .offset(x: 48, y: floorTopY - 14)
            }

            if items.contains("candle") {
                Text("🕯️").font(.system(size: 18))
                    .offset(x: 70, y: floorTopY - 14)
            }

            // やりくりん
            CoronView(size: 50, emotion: .cheer, animate: true, level: mascotLevel)
                .frame(width: 68, height: 76)
                .offset(x: -10, y: floorTopY - 76/2 + bobOffset)

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
        .shadow(color: Color(red: 0.78, green: 0.60, blue: 0.40).opacity(0.20), radius: 10, x: 0, y: 4)
        .onAppear { startAnimations() }
        .sheet(isPresented: $showCustomize) {
            RoomCustomizeSheet(isProtect: true)
                .environmentObject(appState)
        }
    }

    private var doorView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.44, green: 0.28, blue: 0.12))
                .frame(width: 36, height: 60)
            RoundedRectangle(cornerRadius: 2)
                .fill(LinearGradient(
                    colors: [Color(red: 0.56, green: 0.38, blue: 0.20),
                             Color(red: 0.48, green: 0.30, blue: 0.14)],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(width: 32, height: 56)
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(red: 0.35, green: 0.22, blue: 0.08).opacity(0.6), lineWidth: 1)
                .frame(width: 24, height: 20).offset(y: -10)
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(red: 0.35, green: 0.22, blue: 0.08).opacity(0.6), lineWidth: 1)
                .frame(width: 24, height: 18).offset(y: 12)
            Circle()
                .fill(Color(red: 0.85, green: 0.72, blue: 0.38))
                .frame(width: 6, height: 6).offset(x: 11, y: 2)
        }
    }

    private var windowView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(LinearGradient(
                    colors: [Color(red: 1.00, green: 0.97, blue: 0.80),
                             Color(red: 1.00, green: 0.92, blue: 0.68)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: 38, height: 44)
            Rectangle()
                .fill(Color(red: 0.72, green: 0.58, blue: 0.40))
                .frame(width: 1.5, height: 44)
            Rectangle()
                .fill(Color(red: 0.72, green: 0.58, blue: 0.40))
                .frame(width: 38, height: 1.5)
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color(red: 0.72, green: 0.58, blue: 0.40), lineWidth: 2)
                .frame(width: 38, height: 44)
        }
    }

    private var speechBubble: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(speechText)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(red: 0.30, green: 0.18, blue: 0.06))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 0.85, green: 0.70, blue: 0.52).opacity(0.4), lineWidth: 1)
                )
            TriangleShape()
                .fill(Color.white.opacity(0.95))
                .frame(width: 9, height: 5)
                .rotationEffect(.degrees(180))
                .offset(x: 9, y: -1)
        }
    }

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
            bobOffset = -5
        }
        withAnimation(.easeInOut(duration: 0.6)) {
            bubbleOpacity = 1
        }
    }
}
