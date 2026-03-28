import SwiftUI

// MARK: - アプリ全体のカラー定義
// やわらかい中間色を中心に、安心感を演出するカラーパレット

struct AppColor {
    // MARK: - 背景色
    static let background = Color(red: 0.98, green: 0.96, blue: 0.93)        // 温かみのあるオフホワイト
    static let cardBackground = Color.white
    static let sectionBackground = Color(red: 0.96, green: 0.94, blue: 0.91) // カードの外側
    static let inputBackground = Color(red: 0.97, green: 0.95, blue: 0.92)

    // MARK: - ブランドカラー
    static let primary = Color(red: 0.91, green: 0.65, blue: 0.59)    // ソフトサーモン
    static let primaryLight = Color(red: 0.97, green: 0.87, blue: 0.84)
    static let secondary = Color(red: 0.65, green: 0.78, blue: 0.71)  // セージグリーン
    static let secondaryLight = Color(red: 0.87, green: 0.93, blue: 0.89)
    static let accent = Color(red: 0.96, green: 0.90, blue: 0.63)     // ソフトイエロー
    static let accentLight = Color(red: 0.99, green: 0.96, blue: 0.85)
    static let tertiary = Color(red: 0.72, green: 0.79, blue: 0.90)   // ソフトブルー
    static let tertiaryLight = Color(red: 0.89, green: 0.92, blue: 0.97)

    // MARK: - ステータスカラー
    static let safe = Color(red: 0.56, green: 0.77, blue: 0.65)       // 安全（緑）
    static let safeLight = Color(red: 0.85, green: 0.94, blue: 0.89)
    static let caution = Color(red: 0.96, green: 0.75, blue: 0.40)    // 注意（アンバー）
    static let cautionLight = Color(red: 0.99, green: 0.93, blue: 0.82)
    static let danger = Color(red: 0.91, green: 0.45, blue: 0.45)     // 危険（コーラル）
    static let dangerLight = Color(red: 0.98, green: 0.87, blue: 0.87)

    // MARK: - テキストカラー
    static let textPrimary = Color(red: 0.24, green: 0.21, blue: 0.19)    // 温かみのある濃いグレー
    static let textSecondary = Color(red: 0.55, green: 0.50, blue: 0.47)  // ミディアムグレー
    static let textTertiary = Color(red: 0.72, green: 0.68, blue: 0.65)   // ライトグレー
    static let textOnPrimary = Color.white

    // MARK: - 借金・注意表示
    static let debtHigh = Color(red: 0.91, green: 0.40, blue: 0.40)   // 高金利：赤
    static let debtMid = Color(red: 0.96, green: 0.65, blue: 0.30)    // 中金利：オレンジ
    static let debtLow = Color(red: 0.60, green: 0.78, blue: 0.67)    // 低金利：緑

    // MARK: - シャドウ
    static let shadowColor = Color(red: 0.70, green: 0.65, blue: 0.60).opacity(0.12)
}

// MARK: - グラデーション定義
extension AppColor {
    static let onboardingGradient = LinearGradient(
        colors: [
            Color(red: 0.99, green: 0.95, blue: 0.92),
            Color(red: 0.96, green: 0.90, blue: 0.95)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryGradient = LinearGradient(
        colors: [primary, Color(red: 0.87, green: 0.60, blue: 0.72)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let safeGradient = LinearGradient(
        colors: [safe, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
