import SwiftUI

// MARK: - アプリアイコン用ビュー（1024×1024 で書き出して Assets に登録）
// Xcode の Preview でこのファイルを開き、iPhone フレームを非表示にした状態で
// 右クリック → "Save Preview As Image" でPNGを取得してください。
struct AppIconView: View {
    var body: some View {
        ZStack {
            // 背景グラデーション（ミントグリーン → 黄緑）
            LinearGradient(
                colors: [
                    Color(red: 0.30, green: 0.78, blue: 0.52),
                    Color(red: 0.55, green: 0.88, blue: 0.40)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // やわらかい光彩（中央）
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 520, height: 520)
                .blur(radius: 60)

            // やりくりん（大きく中央配置）
            VStack(spacing: 0) {
                CoronView(size: 310, emotion: .happy, animate: false, level: 5)
                    .offset(y: 20)

                // アプリ名
                Text("やりくり")
                    .font(.system(size: 88, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color(red: 0.15, green: 0.50, blue: 0.25).opacity(0.5), radius: 8, x: 0, y: 4)
                    .offset(y: -10)
            }
            .offset(y: -30)
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 224)) // iOS アイコン角丸の参考用
    }
}

// MARK: - ホーム画面に置く小サイズプレビュー
struct AppIconSmallPreview: View {
    var body: some View {
        AppIconView()
            .scaleEffect(0.1)
            .frame(width: 102.4, height: 102.4)
            .clipShape(RoundedRectangle(cornerRadius: 22.4))
    }
}

#Preview("1024x1024 アイコン") {
    AppIconView()
        .ignoresSafeArea()
}

#Preview("60pt ホーム画面サイズ") {
    AppIconSmallPreview()
        .padding(40)
        .background(Color(red: 0.92, green: 0.92, blue: 0.94))
}
