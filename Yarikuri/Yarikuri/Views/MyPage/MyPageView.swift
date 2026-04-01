import SwiftUI
import AVFoundation

// MARK: - マイページ
struct MyPageView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showSettings = false
    @State private var showReport = false
    @State private var showNicknameEdit = false
    @State private var showDreamEdit = false
    @State private var showPrefectureSelect = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // 大見出し
                    HStack {
                        Text("設定")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
                        Button(action: { dismiss() }) {
                            Text("閉じる")
                                .font(.system(size: 15))
                                .foregroundColor(AppColor.primary)
                        }
                    }
                    .padding(.top, 8)

                    // プロフィールカード
                    profileCard

                    // レポートセクション
                    reportsSection

                    // クイック設定セクション
                    quickSettingsSection

                    // サポートセクション
                    supportSection

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showReport) { ReportContainerView().environmentObject(appState) }
        .sheet(isPresented: $showNicknameEdit) { NicknameEditSheet() }
        .sheet(isPresented: $showDreamEdit) { DreamSettingSheet() }
        .sheet(isPresented: $showPrefectureSelect) { PrefectureSelectSheet() }
    }

    // MARK: - プロフィールカード
    private var profileCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [AppColor.primaryLight, AppColor.accentLight],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 64, height: 64)
                CoronView(size: 42, emotion: .normal, animate: false)
                    .frame(width: 64, height: 54)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 4) {
                // ニックネーム行
                Button(action: { showNicknameEdit = true }) {
                    HStack(spacing: 5) {
                        Text(appState.nickname == "あなた" ? "ニックネームを設定" : "\(appState.nickname)さん")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(appState.nickname == "あなた" ? AppColor.textTertiary : AppColor.textPrimary)
                        Image(systemName: "pencil")
                            .font(.system(size: 11))
                            .foregroundColor(AppColor.primary)
                    }
                }
                .buttonStyle(.plain)

                if let profile = appState.userProfile {
                    Text("毎月\(profile.paydayDay)日が給料日")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textSecondary)
                    Text("手取り\(profile.incomeRange.shortText)")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textSecondary)
                    if !profile.concerns.isEmpty {
                        Text(profile.concerns.map { $0.emoji }.joined())
                            .font(.system(size: 16))
                    }
                    // 都道府県行
                    Button(action: { showPrefectureSelect = true }) {
                        HStack(spacing: 4) {
                            Text("📍")
                                .font(.system(size: 13))
                            Text(profile.prefecture.isEmpty ? "都道府県を設定" : profile.prefecture)
                                .font(.system(size: 12))
                                .foregroundColor(profile.prefecture.isEmpty ? AppColor.textTertiary : AppColor.textPrimary)
                            Image(systemName: "pencil")
                                .font(.system(size: 10))
                                .foregroundColor(AppColor.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColor.sectionBackground)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    // 夢タグ行
                    Button(action: { showDreamEdit = true }) {
                        HStack(spacing: 4) {
                            Text(profile.dreamText.isEmpty ? "✨" : profile.dreamEmoji)
                                .font(.system(size: 13))
                            Text(profile.dreamText.isEmpty ? "夢・目標を設定" : profile.dreamText)
                                .font(.system(size: 12))
                                .foregroundColor(profile.dreamText.isEmpty ? AppColor.textTertiary : AppColor.textPrimary)
                                .lineLimit(1)
                            Image(systemName: "pencil")
                                .font(.system(size: 10))
                                .foregroundColor(AppColor.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColor.accentLight)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("設定が完了していません")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                }
            }

            Spacer()

            Button(action: { showSettings = true }) {
                Text("編集")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColor.primaryLight)
                    .cornerRadius(8)
            }
        }
        .cardStyle()
    }

    // MARK: - レポートセクション
    private var reportsSection: some View {
        Button(action: { showReport = true }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppColor.primaryLight)
                        .frame(width: 44, height: 44)
                    Text("📊").font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("レポート")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    Text("週間・月間・年間の記録を確認")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    // MARK: - クイック設定
    private var quickSettingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("クイック確認")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            VStack(spacing: 0) {
                if let profile = appState.userProfile {
                    SettingsRow(icon: "calendar", label: "給料日", value: "毎月\(profile.paydayDay)日")
                    Divider().padding(.leading, 44)
                    SettingsRow(icon: "yensign.circle", label: "月の手取り", value: profile.incomeRange.shortText)
                    Divider().padding(.leading, 44)
                    SettingsRow(icon: "list.bullet.rectangle", label: "固定費合計", value: appState.totalFixedExpenses.yen)
                    Divider().padding(.leading, 44)
                    SettingsRow(icon: "creditcard", label: "借金件数", value: "\(appState.debts.count)件")
                }
            }
            .background(AppColor.cardBackground)
            .cornerRadius(14)
            .shadow(color: AppColor.shadowColor, radius: 4)
        }
    }

    // MARK: - サポートセクション
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("その他")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            VStack(spacing: 0) {
                BGMToggleRow()
                Divider().padding(.leading, 44)
                SettingsLinkRow(icon: "gearshape", label: "詳細設定", action: { showSettings = true })
            }
            .background(AppColor.cardBackground)
            .cornerRadius(14)
            .shadow(color: AppColor.shadowColor, radius: 4)

            // 通知設定セクション
            notificationSection
        }
    }

    // MARK: - 通知設定
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("通知設定")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            VStack(spacing: 0) {
                NotificationToggleRow(
                    icon: "yensign.circle",
                    label: "給料日前",
                    isOn: Binding(
                        get: { appState.notificationPrefs.payday },
                        set: { appState.notificationPrefs.payday = $0 }
                    )
                )
                Divider().padding(.leading, 44)
                NotificationToggleRow(
                    icon: "creditcard",
                    label: "引き落とし前",
                    isOn: Binding(
                        get: { appState.notificationPrefs.debit },
                        set: { appState.notificationPrefs.debit = $0 }
                    )
                )
                Divider().padding(.leading, 44)
                NotificationToggleRow(
                    icon: "arrow.clockwise.circle",
                    label: "サブスク更新前",
                    isOn: Binding(
                        get: { appState.notificationPrefs.subscription },
                        set: { appState.notificationPrefs.subscription = $0 }
                    )
                )
                Divider().padding(.leading, 44)
                NotificationToggleRow(
                    icon: "calendar.badge.clock",
                    label: "返済日前",
                    isOn: Binding(
                        get: { appState.notificationPrefs.repayment },
                        set: { appState.notificationPrefs.repayment = $0 }
                    )
                )
                Divider().padding(.leading, 44)
                NotificationToggleRow(
                    icon: "clock.badge.exclamationmark",
                    label: "制度締切前",
                    isOn: Binding(
                        get: { appState.notificationPrefs.deadline },
                        set: { appState.notificationPrefs.deadline = $0 }
                    )
                )
                Divider().padding(.leading, 44)
                NotificationToggleRow(
                    icon: "checkmark.circle",
                    label: "今日やること未完了",
                    isOn: Binding(
                        get: { appState.notificationPrefs.dailyTask },
                        set: { appState.notificationPrefs.dailyTask = $0 }
                    )
                )
            }
            .background(AppColor.cardBackground)
            .cornerRadius(14)
            .shadow(color: AppColor.shadowColor, radius: 4)
        }
    }
}

// MARK: - BGM トグル行 + スタイル選択
private struct BGMToggleRow: View {
    @ObservedObject private var bgm = BackgroundMusicPlayer.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: bgm.isEnabled ? "music.note" : "speaker.slash")
                    .foregroundColor(AppColor.primary)
                    .font(.system(size: 16))
                    .frame(width: 28)
                Text("バックグラウンド音楽")
                    .font(.system(size: 15))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                Toggle("", isOn: $bgm.isEnabled)
                    .labelsHidden()
                    .tint(AppColor.primary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            if bgm.isEnabled {
                Divider().padding(.leading, 54)

                VStack(alignment: .leading, spacing: 8) {
                    Text("音楽スタイル")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textTertiary)
                        .padding(.leading, 54)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(MusicStyle.allCases, id: \.rawValue) { style in
                                Button(action: { bgm.currentStyle = style }) {
                                    VStack(spacing: 3) {
                                        Text(style.displayName)
                                            .font(.system(size: 12, weight: bgm.currentStyle == style ? .bold : .regular))
                                            .foregroundColor(bgm.currentStyle == style ? AppColor.primary : AppColor.textSecondary)
                                        Text(style.description)
                                            .font(.system(size: 10))
                                            .foregroundColor(AppColor.textTertiary)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(
                                        bgm.currentStyle == style ? AppColor.primaryLight : AppColor.sectionBackground
                                    )
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(bgm.currentStyle == style ? AppColor.primary : Color.clear, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 14)
                    }
                }
                .padding(.vertical, 10)
            }
        }
    }
}

// MARK: - 通知トグル行
private struct NotificationToggleRow: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColor.primary)
                .font(.system(size: 16))
                .frame(width: 28)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(AppColor.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppColor.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

// MARK: - コンポーネント

private struct SettingsRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColor.primary)
                .font(.system(size: 16))
                .frame(width: 28)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(AppColor.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(AppColor.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct SettingsLinkRow: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppColor.primary)
                    .font(.system(size: 16))
                    .frame(width: 28)
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - ニックネーム編集シート
private struct NicknameEditSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var inputText: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                VStack(spacing: 28) {
                    // やりくりんプレビュー
                    VStack(spacing: 8) {
                        CoronView(size: 72, emotion: .happy, animate: true)
                            .frame(height: 90)
                        Text(inputText.isEmpty ? "なんて呼べばいい？" : "\(inputText)さん、よろしくね！")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)
                            .animation(.easeInOut(duration: 0.2), value: inputText)
                    }
                    .padding(.top, 12)

                    // 入力フィールド
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ニックネーム")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColor.textSecondary)
                        TextField("例：たろう、みく、さくら", text: $inputText)
                            .focused($focused)
                            .font(.system(size: 17))
                            .padding(14)
                            .background(AppColor.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focused ? AppColor.primary : Color.clear, lineWidth: 1.5)
                            )
                            .onChange(of: inputText) { _, new in
                                if new.count > 10 { inputText = String(new.prefix(10)) }
                            }
                        Text("10文字以内")
                            .font(.system(size: 11))
                            .foregroundColor(AppColor.textTertiary)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle("ニックネーム設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        appState.updateNickname(inputText.trimmingCharacters(in: .whitespaces))
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
        .onAppear {
            inputText = appState.userProfile?.nickname ?? ""
            focused = true
        }
    }
}

// MARK: - 夢・目標設定シート
private struct DreamSettingSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var dreamText: String = ""
    @State private var dreamEmoji: String = "✨"
    @FocusState private var focused: Bool

    private let emojiOptions = ["✨", "🌍", "✈️", "🏠", "🎓", "💍", "🚗", "🎸", "🏋️", "🌸", "💼", "🎯"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 28) {
                        // やりくりんプレビュー
                        VStack(spacing: 10) {
                            CoronView(size: 72, emotion: .happy, animate: true)
                                .frame(height: 90)
                            Text(dreamText.isEmpty
                                 ? "夢、教えてね！"
                                 : "\(dreamEmoji)\(dreamText)、一緒に叶えよう！")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColor.textPrimary)
                                .multilineTextAlignment(.center)
                                .animation(.easeInOut(duration: 0.2), value: dreamText)
                        }
                        .padding(.top, 12)

                        // 絵文字セレクター
                        VStack(alignment: .leading, spacing: 8) {
                            Text("絵文字")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(emojiOptions, id: \.self) { emoji in
                                        Text(emoji)
                                            .font(.system(size: 26))
                                            .frame(width: 48, height: 48)
                                            .background(dreamEmoji == emoji
                                                        ? AppColor.primaryLight
                                                        : AppColor.cardBackground)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(dreamEmoji == emoji
                                                            ? AppColor.primary
                                                            : Color.clear, lineWidth: 2)
                                            )
                                            .onTapGesture { dreamEmoji = emoji }
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                        }
                        .padding(.horizontal, 20)

                        // テキスト入力
                        VStack(alignment: .leading, spacing: 8) {
                            Text("夢・目標")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)
                            TextField("例：ヨーロッパ旅行、マイホーム購入", text: $dreamText)
                                .focused($focused)
                                .font(.system(size: 17))
                                .padding(14)
                                .background(AppColor.cardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focused ? AppColor.primary : Color.clear, lineWidth: 1.5)
                                )
                                .onChange(of: dreamText) { _, new in
                                    if new.count > 20 { dreamText = String(new.prefix(20)) }
                                }
                            Text("20文字以内")
                                .font(.system(size: 11))
                                .foregroundColor(AppColor.textTertiary)
                        }
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 20)
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button(action: {
                    appState.userProfile?.dreamText = dreamText.trimmingCharacters(in: .whitespaces)
                    appState.userProfile?.dreamEmoji = dreamEmoji
                    dismiss()
                }) {
                    Text("保存")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColor.primary)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppColor.background)
            }
            .navigationTitle("夢・目標を設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { dismiss() }
                        .transaction { $0.animation = nil }
                }
            }
        }
        .onAppear {
            dreamText = appState.userProfile?.dreamText ?? ""
            dreamEmoji = appState.userProfile?.dreamEmoji ?? "✨"
            DispatchQueue.main.async { focused = true }
        }
    }
}

#Preview {
    NavigationStack {
        MyPageView()
    }
    .environmentObject({
        let s = AppState()
        s.loadDemoData()
        return s
    }())
}
