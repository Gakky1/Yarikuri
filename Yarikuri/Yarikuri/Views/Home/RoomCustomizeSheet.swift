import SwiftUI

// MARK: - 部屋着せ替えシート
struct RoomCustomizeSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let isProtect: Bool

    @State private var wallStyle: Int = 0
    @State private var floorStyle: Int = 0
    @State private var selectedItems: [String] = []
    @State private var didInitialize = false

    private var currentConfig: RoomConfig {
        isProtect ? appState.protectRoom : appState.growRoom
    }

    // 壁・床のみ即時反映（アイテム選択は完了ボタンで保存）
    private func saveWallFloor() {
        let newConfig = RoomConfig(wallStyle: wallStyle, floorStyle: floorStyle, activeItems: currentConfig.activeItems)
        if isProtect { appState.protectRoom = newConfig }
        else          { appState.growRoom   = newConfig }
    }

    private func saveAll() {
        let newConfig = RoomConfig(wallStyle: wallStyle, floorStyle: floorStyle, activeItems: selectedItems)
        if isProtect { appState.protectRoom = newConfig }
        else          { appState.growRoom   = newConfig }
    }

    private let wallOptions: [(String, Color)] = [
        ("クリーム", Color(red: 0.99, green: 0.96, blue: 0.88)),
        ("そら",     Color(red: 0.88, green: 0.94, blue: 1.00)),
        ("もり",     Color(red: 0.88, green: 0.96, blue: 0.88)),
        ("すみれ",   Color(red: 0.94, green: 0.90, blue: 0.98)),
    ]

    private let floorOptions: [(String, Color)] = [
        ("木目", Color(red: 0.72, green: 0.54, blue: 0.36)),
        ("石材", Color(red: 0.84, green: 0.82, blue: 0.80)),
    ]

    private var protectItems: [(String, String, String)] {
        [
            ("plant",    "🪴", "観葉植物"),
            ("coffee",   "☕", "コーヒーテーブル"),
            ("suitcase", "🧳", "スーツケース"),
            ("book",     "📚", "本棚"),
            ("frame",    "🖼️", "写真フレーム"),
            ("candle",   "🕯️", "キャンドル"),
        ]
    }
    private var growItems: [(String, String, String)] {
        [
            ("plant",   "🌿", "観葉植物"),
            ("dining",  "🍱", "ダイニングテーブル"),
            ("bag",     "👜", "ブランドバッグ"),
            ("art",     "🎨", "アートパネル"),
            ("trophy",  "🏆", "トロフィー"),
            ("wine",    "🥂", "シャンパン"),
        ]
    }

    private var items: [(String, String, String)] {
        isProtect ? protectItems : growItems
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 壁の色
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🎨 壁の色")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)
                        HStack(spacing: 12) {
                            ForEach(Array(wallOptions.enumerated()), id: \.offset) { i, opt in
                                Button(action: {
                                    wallStyle = i
                                    saveWallFloor()
                                }) {
                                    VStack(spacing: 6) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(opt.1)
                                            .frame(width: 56, height: 40)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(wallStyle == i ? AppColor.primary : Color.clear, lineWidth: 2.5)
                                            )
                                        Text(opt.0)
                                            .font(.system(size: 11))
                                            .foregroundColor(wallStyle == i ? AppColor.primary : AppColor.textTertiary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    Divider().padding(.horizontal, 16)

                    // 床の素材
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🪵 床の素材")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)
                        HStack(spacing: 12) {
                            ForEach(Array(floorOptions.enumerated()), id: \.offset) { i, opt in
                                Button(action: {
                                    floorStyle = i
                                    saveWallFloor()
                                }) {
                                    VStack(spacing: 6) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(opt.1)
                                            .frame(width: 80, height: 32)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(floorStyle == i ? AppColor.primary : Color.clear, lineWidth: 2.5)
                                            )
                                        Text(opt.0)
                                            .font(.system(size: 11))
                                            .foregroundColor(floorStyle == i ? AppColor.primary : AppColor.textTertiary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    Divider().padding(.horizontal, 16)

                    // おきたいもの
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🛋️ おきたいもの（3つまで）")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(items, id: \.0) { item in
                                let isSelected = selectedItems.contains(item.0)
                                Button(action: {
                                    if selectedItems.contains(item.0) {
                                        selectedItems.removeAll { $0 == item.0 }
                                    } else if selectedItems.count < 3 {
                                        selectedItems.append(item.0)
                                    }
                                    // アイテム変更は完了ボタンで保存（即時save()は@EnvironmentObject更新で状態干渉を起こすため除外）
                                }) {
                                    VStack(spacing: 6) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(isSelected ? AppColor.primaryLight : AppColor.sectionBackground)
                                                .frame(width: 60, height: 52)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(isSelected ? AppColor.primary : Color.clear, lineWidth: 2)
                                                )
                                            Text(item.1).font(.system(size: 26))
                                            if isSelected {
                                                Circle()
                                                    .fill(AppColor.primary)
                                                    .frame(width: 16, height: 16)
                                                    .overlay(Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundColor(.white))
                                                    .offset(x: 20, y: -18)
                                            }
                                        }
                                        Text(item.2)
                                            .font(.system(size: 10))
                                            .foregroundColor(isSelected ? AppColor.primary : AppColor.textTertiary)
                                            .lineLimit(1)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 4)

                        Text("選択中: \(selectedItems.count)/3")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textTertiary)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)

                    // おきたいものの説明
                    if !isProtect {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "bubble.left.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColor.safe.opacity(0.8))
                                Text("やりくりんのひとことが変わるりん！")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppColor.safe)
                            }
                            Text("「おきたいもの」の組み合わせによって、収入を増やすタブに表示されるやりくりんの吹き出しのセリフが変わります。いろんな組み合わせを試してみてりん✨")
                                .font(.system(size: 12))
                                .foregroundColor(AppColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(3)

                            VStack(alignment: .leading, spacing: 4) {
                                comboHint(items: "🏆 + 🍷", text: "成功、祝えそうりん🥂")
                                comboHint(items: "👜 + 🎨", text: "センスいい生活できそうりん🎨")
                                comboHint(items: "🍽️ + 🍷", text: "豪華ディナーできそうりん🍽️")
                                comboHint(items: "🏆 のみ",  text: "目標達成できちゃいそうりん！")
                                comboHint(items: "👜 のみ",  text: "欲しいもの買えそうりん👜")
                            }
                            .padding(.top, 4)
                        }
                        .padding(14)
                        .background(AppColor.safeLight.opacity(0.6))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                    }

                    if isProtect {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "bubble.left.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColor.primary.opacity(0.7))
                                Text("やりくりんのひとことが変わるりん！")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppColor.primary)
                            }
                            Text("「おきたいもの」の組み合わせによって、支出を減らすタブに表示されるやりくりんの吹き出しのセリフが変わります。いろんな組み合わせを試してみてりん✨")
                                .font(.system(size: 12))
                                .foregroundColor(AppColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(3)

                            VStack(alignment: .leading, spacing: 4) {
                                comboHint(items: "☕ + 🧳", text: "旅先でもカフェできそうりん✈️")
                                comboHint(items: "📚 + 🕯️", text: "ゆっくり読書できそうりん📚")
                                comboHint(items: "🖼️ + 🧳", text: "旅の思い出、増えそうりん🗼")
                                comboHint(items: "☕ のみ",   text: "カフェ行けそうりん☕")
                                comboHint(items: "🧳 のみ",   text: "旅行できちゃいそうりん✈️")
                            }
                            .padding(.top, 4)
                        }
                        .padding(14)
                        .background(AppColor.primaryLight.opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.top, 16)
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle(isProtect ? "支出の部屋を着せ替え" : "収入の部屋を着せ替え")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") { saveAll(); dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
            .onAppear {
                guard !didInitialize else { return }
                didInitialize = true
                wallStyle = currentConfig.wallStyle
                floorStyle = currentConfig.floorStyle
                selectedItems = currentConfig.activeItems
            }
        }
    }

    private func comboHint(items: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(items)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppColor.primary)
                .frame(width: 90, alignment: .leading)
            Text("→ \"\(text)\"")
                .font(.system(size: 11))
                .foregroundColor(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
