import SwiftUI

// MARK: - 設定画面
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var paydayDay: Int = 25
    @State private var incomeRange: IncomeRange = .range200to250k
    @State private var showResetAlert = false
    @State private var notificationsEnabled = true
    @State private var appIconStyle: Int = 0
    @State private var themeColorStyle: Int = 0
    @State private var monthStartDay: Int = 1

    var body: some View {
        NavigationStack {
            Form {
                // 基本設定
                Section(header: Text("基本設定")) {
                    Picker("給料日", selection: $paydayDay) {
                        ForEach(1...31, id: \.self) { day in
                            Text("毎月\(day)日").tag(day)
                        }
                    }

                    Picker("月の手取り", selection: $incomeRange) {
                        ForEach(IncomeRange.allCases, id: \.rawValue) { range in
                            Text(range.displayText).tag(range)
                        }
                    }
                }

                // テーマ・アイコン
                Section(header: Text("デザイン設定")) {
                    NavigationLink(destination: ThemeColorSettingsView(themeColorStyle: $themeColorStyle)) {
                        HStack {
                            Text("テーマカラー")
                            Spacer()
                            Circle()
                                .fill(SettingsThemeColors.themeColor(themeColorStyle))
                                .frame(width: 20, height: 20)
                            Text(SettingsThemeColors.themeName(themeColorStyle))
                                .foregroundColor(AppColor.textSecondary)
                                .font(.system(size: 14))
                        }
                    }
                    NavigationLink(destination: AppIconSettingsView(appIconStyle: $appIconStyle)) {
                        HStack {
                            Text("アイコンデザイン")
                            Spacer()
                            Text(SettingsIconStyles.iconName(appIconStyle))
                                .foregroundColor(AppColor.textSecondary)
                                .font(.system(size: 14))
                        }
                    }
                }

                // 月度設定
                Section(header: Text("集計期間")) {
                    NavigationLink(destination: MonthStartDaySettingsView(monthStartDay: $monthStartDay)) {
                        HStack {
                            Text("月度の開始日")
                            Spacer()
                            Text("毎月\(monthStartDay)日")
                                .foregroundColor(AppColor.textSecondary)
                                .font(.system(size: 14))
                        }
                    }
                }

                // 通知設定
                Section(header: Text("通知設定")) {
                    Toggle("通知を受け取る", isOn: $notificationsEnabled)
                        .tint(AppColor.primary)

                    if notificationsEnabled {
                        HStack {
                            Text("通知タイミング")
                            Spacer()
                            Text("支払い前日・返済日3日前")
                                .font(.system(size: 13))
                                .foregroundColor(AppColor.textSecondary)
                        }
                    }
                }

                // アプリについて
                Section(header: Text("アプリについて")) {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0").foregroundColor(AppColor.textSecondary)
                    }
                }

                // リセット
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Text("すべてのデータを削除する")
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        saveSettings()
                        dismiss()
                    }
                    .foregroundColor(AppColor.primary)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
            .onAppear {
                if let profile = appState.userProfile {
                    paydayDay = profile.paydayDay
                    incomeRange = profile.incomeRange
                    appIconStyle = profile.appIconStyle
                    themeColorStyle = profile.themeColorStyle
                    monthStartDay = profile.monthStartDay
                }
            }
            .alert("データを削除しますか？", isPresented: $showResetAlert) {
                Button("削除する", role: .destructive) {
                    appState.resetAllData()
                    dismiss()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("すべての設定・データが削除されます。この操作は元に戻せません。")
            }
        }
    }

    private func saveSettings() {
        guard var profile = appState.userProfile else { return }
        profile.paydayDay = paydayDay
        profile.incomeRange = incomeRange
        profile.appIconStyle = appIconStyle
        profile.themeColorStyle = themeColorStyle
        profile.monthStartDay = monthStartDay
        appState.userProfile = profile
    }
}

// MARK: - テーマカラーヘルパー
enum SettingsThemeColors {
    static let themes: [(String, Color)] = [
        ("サーモン",   Color(red: 0.91, green: 0.65, blue: 0.59)),
        ("ミント",     Color(red: 0.49, green: 0.78, blue: 0.68)),
        ("スカイ",     Color(red: 0.46, green: 0.68, blue: 0.89)),
        ("ラベンダー", Color(red: 0.72, green: 0.61, blue: 0.88)),
        ("ゴールド",   Color(red: 0.85, green: 0.67, blue: 0.26)),
    ]
    static func themeName(_ idx: Int) -> String { themes[safe: idx]?.0 ?? themes[0].0 }
    static func themeColor(_ idx: Int) -> Color  { themes[safe: idx]?.1 ?? themes[0].1 }
}

// MARK: - アイコンスタイルヘルパー
enum SettingsIconStyles {
    static let icons: [(String, String, Color)] = [
        ("スタンダード", "💰", Color(red: 0.91, green: 0.65, blue: 0.59)),
        ("シンプル",     "📊", Color(red: 0.46, green: 0.68, blue: 0.89)),
        ("ポップ",       "🌈", Color(red: 0.85, green: 0.67, blue: 0.26)),
        ("ダーク",       "🌙", Color(red: 0.28, green: 0.26, blue: 0.35)),
        ("ナチュラル",   "🌿", Color(red: 0.49, green: 0.72, blue: 0.58)),
    ]
    static func iconName(_ idx: Int) -> String  { icons[safe: idx]?.0 ?? icons[0].0 }
    static func iconEmoji(_ idx: Int) -> String { icons[safe: idx]?.1 ?? icons[0].1 }
    static func iconColor(_ idx: Int) -> Color  { icons[safe: idx]?.2 ?? icons[0].2 }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - テーマカラー設定画面
struct ThemeColorSettingsView: View {
    @Binding var themeColorStyle: Int

    var body: some View {
        Form {
            Section(header: Text("テーマカラーを選んでください")) {
                ForEach(SettingsThemeColors.themes.indices, id: \.self) { i in
                    Button(action: { themeColorStyle = i }) {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(SettingsThemeColors.themes[i].1)
                                .frame(width: 32, height: 32)
                            Text(SettingsThemeColors.themes[i].0)
                                .foregroundColor(AppColor.textPrimary)
                            Spacer()
                            if themeColorStyle == i {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColor.primary)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            Section(header: Text("プレビュー")) {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(SettingsThemeColors.themes[themeColorStyle].1)
                        .frame(height: 44)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(SettingsThemeColors.themes[themeColorStyle].1.opacity(0.3))
                        .frame(height: 44)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("テーマカラー")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - アイコンデザイン設定画面
struct AppIconSettingsView: View {
    @Binding var appIconStyle: Int

    var body: some View {
        Form {
            Section(header: Text("アイコンデザインを選んでください")) {
                ForEach(SettingsIconStyles.icons.indices, id: \.self) { i in
                    Button(action: { appIconStyle = i }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(SettingsIconStyles.icons[i].2)
                                    .frame(width: 40, height: 40)
                                Text(SettingsIconStyles.icons[i].1)
                                    .font(.system(size: 20))
                            }
                            Text(SettingsIconStyles.icons[i].0)
                                .foregroundColor(AppColor.textPrimary)
                            Spacer()
                            if appIconStyle == i {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColor.primary)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("アイコンデザイン")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 月度開始日設定画面
struct MonthStartDaySettingsView: View {
    @Binding var monthStartDay: Int
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let days = Array(1...28)

    var endDay: String {
        monthStartDay == 1 ? "月末" : "\(monthStartDay - 1)日"
    }

    var body: some View {
        Form {
            Section(header: Text("月度の開始日")) {
                Text("収支の集計期間を設定します。給料日に合わせるのがおすすめです。")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
                    .padding(.vertical, 4)

                HStack {
                    Text("現在の設定")
                    Spacer()
                    Text("毎月\(monthStartDay)日〜\(endDay)")
                        .foregroundColor(AppColor.primary)
                        .fontWeight(.semibold)
                }
            }

            Section(header: Text("開始日を選ぶ")) {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(days, id: \.self) { day in
                        Button(action: { monthStartDay = day }) {
                            Text("\(day)")
                                .font(.system(size: 14, weight: monthStartDay == day ? .bold : .regular))
                                .foregroundColor(monthStartDay == day ? .white : AppColor.textPrimary)
                                .frame(width: 38, height: 38)
                                .background(monthStartDay == day ? AppColor.primary : AppColor.sectionBackground)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("月度の開始日")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
