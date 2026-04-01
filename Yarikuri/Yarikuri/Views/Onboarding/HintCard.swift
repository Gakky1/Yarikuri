import SwiftUI

// MARK: - ヒントカード（オンボーディング全体で使う共通コンポーネント）
struct HintCard: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(AppColor.accent)
                .font(.system(size: 14))
                .padding(.top, 1)

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(AppColor.accentLight)
        .cornerRadius(12)
    }
}
