import SwiftUI

// MARK: - 副収入候補画面
struct SideIncomeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedDifficulty: IncomeDifficulty? = nil

    private var filteredIdeas: [SideIncomeIdea] {
        let all = SideIncomeIdea.sampleData
        guard let diff = selectedDifficulty else { return all }
        return all.filter { $0.difficulty == diff }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        introCard
                        difficultyFilter
                        ForEach(filteredIdeas) { idea in
                            SideIncomeIdeaCard(idea: idea)
                        }
                        disclaimerCard
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("副収入の候補")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("まずは月1〜3万円を目標に")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppColor.textPrimary)
            Text("大きく稼ごうとしなくてOKです。\n少しでも収入の柱を増やすことで、心の余裕が生まれます。")
                .font(.system(size: 13))
                .foregroundColor(AppColor.textSecondary)
                .lineSpacing(3)
        }
        .padding(14)
        .background(AppColor.primaryLight)
        .cornerRadius(12)
    }

    private var difficultyFilter: some View {
        HStack(spacing: 8) {
            FilterButton(title: "すべて", isSelected: selectedDifficulty == nil) {
                selectedDifficulty = nil
            }
            ForEach(IncomeDifficulty.allCases, id: \.rawValue) { diff in
                FilterButton(title: diff.displayText, isSelected: selectedDifficulty == diff) {
                    selectedDifficulty = selectedDifficulty == diff ? nil : diff
                }
            }
        }
    }

    private var disclaimerCard: some View {
        Text("💡 副収入は状況や環境によって成果が異なります。詐欺や過度なリスクには十分注意してください。")
            .font(.system(size: 12))
            .foregroundColor(AppColor.textTertiary)
            .padding(12)
            .background(AppColor.sectionBackground)
            .cornerRadius(10)
    }
}

// MARK: - 副収入カード
private struct SideIncomeIdeaCard: View {
    let idea: SideIncomeIdea
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.spring(response: 0.3)) { isExpanded.toggle() } }) {
                HStack(spacing: 12) {
                    Text(idea.emoji)
                        .font(.system(size: 28))
                        .frame(width: 52, height: 52)
                        .background(AppColor.accentLight)
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(idea.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)
                        Text(idea.description)
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(idea.incomeRange)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColor.secondary)
                        DifficultyBadge(difficulty: idea.difficulty)
                    }
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().padding(.horizontal, 14)
                VStack(alignment: .leading, spacing: 10) {
                    Text(idea.howToStart)
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textPrimary)
                        .lineSpacing(3)

                    HStack(spacing: 12) {
                        InfoBadge(icon: "clock", text: idea.timeRequired)
                        InfoBadge(icon: "yensign.circle", text: "初期費用: \(idea.initialCost)")
                    }

                    if !idea.requiredSkills.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("向いている方").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColor.textSecondary)
                            ForEach(idea.requiredSkills, id: \.self) { skill in
                                HStack(spacing: 6) {
                                    Circle().fill(AppColor.accent).frame(width: 5, height: 5)
                                    Text(skill).font(.system(size: 13)).foregroundColor(AppColor.textPrimary)
                                }
                            }
                        }
                    }
                }
                .padding(14)
                .transition(.opacity)
            }
        }
        .background(AppColor.cardBackground)
        .cornerRadius(14)
        .shadow(color: AppColor.shadowColor, radius: 5)
    }
}

// MARK: - バッジ・コンポーネント
private struct DifficultyBadge: View {
    let difficulty: IncomeDifficulty

    var body: some View {
        Text(difficulty.displayText)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(difficulty.color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(difficulty.color.opacity(0.12))
            .cornerRadius(4)
    }
}

private struct InfoBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 11)).foregroundColor(AppColor.textTertiary)
            Text(text).font(.system(size: 12)).foregroundColor(AppColor.textSecondary)
        }
    }
}

private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : AppColor.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppColor.primary : AppColor.cardBackground)
                .cornerRadius(20)
        }
    }
}

// MARK: - 副収入データモデル（ダミー）
struct SideIncomeIdea: Identifiable {
    var id = UUID()
    var title: String
    var emoji: String
    var description: String
    var incomeRange: String
    var difficulty: IncomeDifficulty
    var howToStart: String
    var timeRequired: String
    var initialCost: String
    var requiredSkills: [String]

    static let sampleData: [SideIncomeIdea] = [
        SideIncomeIdea(
            title: "フリマアプリ出品",
            emoji: "👗",
            description: "不用品を売って即収入",
            incomeRange: "月1〜5万円",
            difficulty: .easy,
            howToStart: "メルカリ・ラクマなどのアプリをダウンロードして、家にある不用品を撮影・出品するだけ。最初は服や本など小物から始めると簡単です。",
            timeRequired: "スキマ時間",
            initialCost: "なし",
            requiredSkills: ["家に不用品がある方", "スマホで写真を撮れる方"]
        ),
        SideIncomeIdea(
            title: "ポイ活",
            emoji: "💰",
            description: "日常の買い物でポイントを効率よく貯める",
            incomeRange: "月3,000〜1万円",
            difficulty: .easy,
            howToStart: "楽天経済圏、PayPayなど自分が使いやすいポイントサービスを1〜2つに絞って、日常の支払いをまとめましょう。",
            timeRequired: "日常の隙間",
            initialCost: "なし",
            requiredSkills: ["スマホを使っている方", "クレジットカードを持っている方"]
        ),
        SideIncomeIdea(
            title: "クラウドソーシング",
            emoji: "💻",
            description: "スキルを活かして在宅でお仕事",
            incomeRange: "月1〜10万円",
            difficulty: .medium,
            howToStart: "クラウドワークスやランサーズに登録し、データ入力・文章作成・翻訳など自分のスキルに合った案件から始めましょう。",
            timeRequired: "週5〜10時間",
            initialCost: "なし",
            requiredSkills: ["文章を書くのが得意", "パソコン作業が苦にならない"]
        ),
        SideIncomeIdea(
            title: "ハンドメイド販売",
            emoji: "🎨",
            description: "作ることが好きならアクセサリーや雑貨を販売",
            incomeRange: "月5,000〜5万円",
            difficulty: .medium,
            howToStart: "minne（ミンネ）やCreemaに登録して、作品を出品しましょう。最初は材料費を抑えてアクセサリー系から始めるのがおすすめ。",
            timeRequired: "週3〜10時間",
            initialCost: "材料費のみ",
            requiredSkills: ["ものを作るのが好き", "丁寧な梱包・発送ができる"]
        ),
        SideIncomeIdea(
            title: "アンケートモニター",
            emoji: "📝",
            description: "スキマ時間に手軽に稼ぐ",
            incomeRange: "月1,000〜5,000円",
            difficulty: .easy,
            howToStart: "マクロミルやリサーチパネルなどに登録して、空き時間にアンケートに答えるだけ。大きく稼ぐのは難しいですが、隙間時間の活用に。",
            timeRequired: "スキマ時間",
            initialCost: "なし",
            requiredSkills: ["スマホを持っている方"]
        ),
    ]
}

enum IncomeDifficulty: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"

    var displayText: String {
        switch self {
        case .easy: return "🟢 始めやすい"
        case .medium: return "🟡 少し準備が必要"
        case .hard: return "🔴 スキル必要"
        }
    }

    var color: Color {
        switch self {
        case .easy: return AppColor.secondary
        case .medium: return AppColor.caution
        case .hard: return AppColor.danger
        }
    }
}

#Preview {
    SideIncomeView()
        .environmentObject(AppState())
}
