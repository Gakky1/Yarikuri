import SwiftUI

// MARK: - カスタマイズステップ（オンボーディング最終ステップ）
struct CustomizeStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    let onComplete: () -> Void
    @State private var showComplete = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // ヘッダー
                VStack(spacing: 8) {
                    Text("🎨")
                        .font(.system(size: 52))
                    Text("アプリをカスタマイズしよう")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppColor.textPrimary)
                    Text("あとで設定から変更できます")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                }
                .padding(.top, 24)

                // テーマカラー選択
                ThemeColorSection(selected: $vm.themeColorStyle)

                Divider().padding(.horizontal, 24)

                // アイコンデザイン選択
                AppIconStyleSection(selected: $vm.appIconStyle)

                Divider().padding(.horizontal, 24)

                // 月度開始日
                MonthStartDaySection(monthStartDay: $vm.monthStartDay)

                Spacer().frame(height: 12)

                // はじめるボタン
                Button(action: { showComplete = true }) {
                    Text("やりくりをはじめる 🚀")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColor.primary)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
        .fullScreenCover(isPresented: $showComplete) {
            OnboardingCompleteView(onComplete: onComplete)
        }
    }
}

// MARK: - テーマカラーセクション
private struct ThemeColorSection: View {
    @Binding var selected: Int

    let themes: [(String, Color, Color)] = [
        ("サーモン",   Color(red: 0.91, green: 0.65, blue: 0.59), Color(red: 0.97, green: 0.87, blue: 0.84)),
        ("ミント",     Color(red: 0.49, green: 0.78, blue: 0.68), Color(red: 0.84, green: 0.94, blue: 0.90)),
        ("スカイ",     Color(red: 0.46, green: 0.68, blue: 0.89), Color(red: 0.84, green: 0.91, blue: 0.97)),
        ("ラベンダー", Color(red: 0.72, green: 0.61, blue: 0.88), Color(red: 0.91, green: 0.86, blue: 0.97)),
        ("ゴールド",   Color(red: 0.85, green: 0.67, blue: 0.26), Color(red: 0.97, green: 0.92, blue: 0.80)),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("🎨 テーマカラー")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                Text(themes[selected].0)
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
            }
            .padding(.horizontal, 24)

            HStack(spacing: 14) {
                ForEach(themes.indices, id: \.self) { i in
                    Button(action: { selected = i }) {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(themes[i].1)
                                    .frame(width: 46, height: 46)
                                if selected == i {
                                    Circle()
                                        .stroke(themes[i].1, lineWidth: 3)
                                        .frame(width: 54, height: 54)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            Text(themes[i].0)
                                .font(.system(size: 10))
                                .foregroundColor(selected == i ? themes[i].1 : AppColor.textTertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)

            // プレビュー
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(themes[selected].1)
                    .frame(height: 36)
                RoundedRectangle(cornerRadius: 10)
                    .fill(themes[selected].2)
                    .frame(height: 36)
                RoundedRectangle(cornerRadius: 10)
                    .fill(themes[selected].1.opacity(0.4))
                    .frame(height: 36)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - アイコンデザインセクション
private struct AppIconStyleSection: View {
    @Binding var selected: Int

    let icons: [(String, String, Color)] = [
        ("スタンダード", "💰", Color(red: 0.91, green: 0.65, blue: 0.59)),
        ("シンプル",     "📊", Color(red: 0.46, green: 0.68, blue: 0.89)),
        ("ポップ",       "🌈", Color(red: 0.85, green: 0.67, blue: 0.26)),
        ("ダーク",       "🌙", Color(red: 0.28, green: 0.26, blue: 0.35)),
        ("ナチュラル",   "🌿", Color(red: 0.49, green: 0.72, blue: 0.58)),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("📱 アイコンデザイン")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                Text(icons[selected].0)
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
            }
            .padding(.horizontal, 24)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 5),
                spacing: 12
            ) {
                ForEach(icons.indices, id: \.self) { i in
                    Button(action: { selected = i }) {
                        VStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(icons[i].2)
                                    .frame(width: 52, height: 52)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(selected == i ? Color.white : Color.clear, lineWidth: 3)
                                    )
                                    .shadow(color: selected == i ? icons[i].2.opacity(0.5) : Color.clear, radius: 6, x: 0, y: 3)
                                Text(icons[i].1)
                                    .font(.system(size: 24))
                            }
                            Text(icons[i].0)
                                .font(.system(size: 9))
                                .foregroundColor(selected == i ? AppColor.textPrimary : AppColor.textTertiary)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Text("※ アイコンデザインはアプリ内の表示に反映されます")
                .font(.system(size: 11))
                .foregroundColor(AppColor.textTertiary)
                .padding(.horizontal, 24)
        }
    }
}

// MARK: - 月度開始日セクション
private struct MonthStartDaySection: View {
    @Binding var monthStartDay: Int

    private let days = Array(1...28)
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var endDay: String {
        if monthStartDay == 1 { return "月末" }
        return "\(monthStartDay - 1)日"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("📅 月度の開始日")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                Text("毎月\(monthStartDay)日〜\(endDay)")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
            }
            .padding(.horizontal, 24)

            Text("収支の集計期間を設定します。給料日と合わせるのがおすすめです。")
                .font(.system(size: 12))
                .foregroundColor(AppColor.textSecondary)
                .padding(.horizontal, 24)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days, id: \.self) { day in
                    Button(action: { monthStartDay = day }) {
                        Text("\(day)")
                            .font(.system(size: 13, weight: monthStartDay == day ? .bold : .regular))
                            .foregroundColor(monthStartDay == day ? .white : AppColor.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(monthStartDay == day ? AppColor.primary : AppColor.sectionBackground)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
