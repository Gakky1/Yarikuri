import SwiftUI

// MARK: - 部屋着せ替えシート
struct RoomCustomizeSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let isProtect: Bool

    private var config: RoomConfig {
        isProtect ? appState.protectRoom : appState.growRoom
    }

    private func update(_ newConfig: RoomConfig) {
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
                                    var c = config; c.wallStyle = i; update(c)
                                }) {
                                    VStack(spacing: 6) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(opt.1)
                                            .frame(width: 56, height: 40)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(config.wallStyle == i ? AppColor.primary : Color.clear, lineWidth: 2.5)
                                            )
                                        Text(opt.0)
                                            .font(.system(size: 11))
                                            .foregroundColor(config.wallStyle == i ? AppColor.primary : AppColor.textTertiary)
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
                                    var c = config; c.floorStyle = i; update(c)
                                }) {
                                    VStack(spacing: 6) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(opt.1)
                                            .frame(width: 80, height: 32)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(config.floorStyle == i ? AppColor.primary : Color.clear, lineWidth: 2.5)
                                            )
                                        Text(opt.0)
                                            .font(.system(size: 11))
                                            .foregroundColor(config.floorStyle == i ? AppColor.primary : AppColor.textTertiary)
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
                                let isSelected = config.activeItems.contains(item.0)
                                Button(action: {
                                    var c = config
                                    if isSelected {
                                        c.activeItems.removeAll { $0 == item.0 }
                                    } else if c.activeItems.count < 3 {
                                        c.activeItems.append(item.0)
                                    }
                                    update(c)
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

                        Text("選択中: \(config.activeItems.count)/3")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textTertiary)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)

                    Spacer().frame(height: 20)
                }
                .padding(.top, 16)
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle(isProtect ? "守る部屋を着せ替え" : "増やす部屋を着せ替え")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }
}
