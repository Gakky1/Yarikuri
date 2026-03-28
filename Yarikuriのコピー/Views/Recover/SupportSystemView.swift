import SwiftUI

// MARK: - 制度・給付・支援画面
struct SupportSystemView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: SystemCategory? = nil

    private var systems: [SupportSystem] {
        SupportSystem.sampleData(for: appState.userProfile)
    }

    private var filteredSystems: [SupportSystem] {
        guard let cat = selectedCategory else { return systems }
        return systems.filter { $0.category == cat }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // フィルター
                        categoryFilter

                        // 制度リスト
                        ForEach(filteredSystems) { system in
                            SupportSystemCard(system: system)
                        }

                        // 注意書き
                        disclaimerCard

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("使える制度・支援")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "すべて", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(SystemCategory.allCases, id: \.rawValue) { cat in
                    FilterChip(title: "\(cat.emoji) \(cat.displayText)", isSelected: selectedCategory == cat) {
                        selectedCategory = selectedCategory == cat ? nil : cat
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var disclaimerCard: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundColor(AppColor.textTertiary)
                .font(.system(size: 13))
                .padding(.top, 1)
            Text("制度の内容は変わることがあります。詳細は各自治体や公式サイトでご確認ください。")
                .font(.system(size: 12))
                .foregroundColor(AppColor.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(AppColor.sectionBackground)
        .cornerRadius(10)
    }
}

// MARK: - 制度カード
private struct SupportSystemCard: View {
    let system: SupportSystem
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.spring(response: 0.3)) { isExpanded.toggle() } }) {
                HStack(spacing: 12) {
                    Text(system.emoji)
                        .font(.system(size: 24))
                        .frame(width: 44, height: 44)
                        .background(AppColor.tertiaryLight)
                        .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(system.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColor.textPrimary)
                            Text(system.category.displayText)
                                .font(.system(size: 10))
                                .foregroundColor(AppColor.tertiary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColor.tertiaryLight)
                                .cornerRadius(4)
                        }
                        Text(system.summary)
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(system.benefit)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppColor.secondary)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textTertiary)
                    }
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().padding(.horizontal, 14)

                VStack(alignment: .leading, spacing: 10) {
                    Text(system.detail)
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)

                    if !system.eligibility.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("対象となる方")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)
                            ForEach(system.eligibility, id: \.self) { item in
                                HStack(spacing: 6) {
                                    Circle().fill(AppColor.secondary).frame(width: 5, height: 5)
                                    Text(item).font(.system(size: 13)).foregroundColor(AppColor.textPrimary)
                                }
                            }
                        }
                    }

                    HStack {
                        Text("問い合わせ先: \(system.contact)")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textTertiary)
                        Spacer()
                    }
                }
                .padding(14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppColor.cardBackground)
        .cornerRadius(14)
        .shadow(color: AppColor.shadowColor, radius: 5)
    }
}

// MARK: - フィルターチップ
private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? AppColor.primary : AppColor.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppColor.primaryLight : AppColor.cardBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? AppColor.primary : AppColor.sectionBackground, lineWidth: 1)
                )
        }
    }
}

// MARK: - 制度データモデル（ダミー）
struct SupportSystem: Identifiable {
    var id = UUID()
    var name: String
    var emoji: String
    var summary: String
    var detail: String
    var benefit: String
    var category: SystemCategory
    var eligibility: [String]
    var contact: String

    static func sampleData(for profile: UserProfile?) -> [SupportSystem] {
        var systems: [SupportSystem] = []

        systems.append(SupportSystem(
            name: "住民税非課税世帯給付",
            emoji: "🏛️",
            summary: "低所得世帯への給付金",
            detail: "住民税が非課税の世帯に対して、自治体から給付金が支給されます。金額や条件は自治体によって異なります。",
            benefit: "数万円〜",
            category: .livingSupport,
            eligibility: ["住民税非課税の世帯", "一定の所得以下の世帯"],
            contact: "お住まいの市区町村窓口"
        ))

        systems.append(SupportSystem(
            name: "高額療養費制度",
            emoji: "🏥",
            summary: "医療費が高額になった場合に払い戻し",
            detail: "1ヶ月の医療費が一定額を超えた場合、超えた分が払い戻されます。限度額は収入によって異なります。",
            benefit: "医療費の一部",
            category: .medical,
            eligibility: ["健康保険の加入者", "1ヶ月の医療費が上限を超えた方"],
            contact: "加入している健康保険"
        ))

        systems.append(SupportSystem(
            name: "生活福祉資金貸付制度",
            emoji: "💰",
            summary: "低所得世帯向けの無利子・低利子貸付",
            detail: "生活費や教育費など、さまざまな目的のために低利子または無利子でお金を借りられる制度です。",
            benefit: "無利子〜低利子",
            category: .loan,
            eligibility: ["低所得者世帯", "高齢者世帯", "障害者世帯"],
            contact: "社会福祉協議会"
        ))

        systems.append(SupportSystem(
            name: "傷病手当金",
            emoji: "💊",
            summary: "病気・怪我で働けない時の生活支援",
            detail: "業務外の病気や怪我で連続して3日以上仕事を休んだ場合、4日目から最大1年6ヶ月、標準報酬日額の2/3が支給されます。",
            benefit: "給与の約2/3",
            category: .medical,
            eligibility: ["健康保険の被保険者（社会保険加入者）", "業務外の病気・怪我"],
            contact: "加入している健康保険組合"
        ))

        if profile?.hasChildren == true {
            systems.append(SupportSystem(
                name: "児童手当",
                emoji: "👶",
                summary: "子どもがいる世帯への手当",
                detail: "中学校修了まで（15歳になった後の最初の3月31日まで）の児童を養育する方に支給されます。",
                benefit: "月1〜1.5万円",
                category: .childcare,
                eligibility: ["中学生以下の子どもがいる世帯"],
                contact: "お住まいの市区町村窓口"
            ))
        }

        systems.append(SupportSystem(
            name: "ハローワーク職業訓練",
            emoji: "📚",
            summary: "無料・格安でスキルを習得",
            detail: "ハローワークを通じて、ITや医療介護などのスキルを無料または格安で学べる職業訓練があります。",
            benefit: "受講料無料〜低額",
            category: .employment,
            eligibility: ["求職中の方", "ハローワークに登録している方"],
            contact: "最寄りのハローワーク"
        ))

        return systems
    }
}

enum SystemCategory: String, CaseIterable {
    case livingSupport = "livingSupport"
    case medical = "medical"
    case childcare = "childcare"
    case employment = "employment"
    case loan = "loan"
    case tax = "tax"

    var displayText: String {
        switch self {
        case .livingSupport: return "生活支援"
        case .medical: return "医療"
        case .childcare: return "子育て"
        case .employment: return "就労・スキル"
        case .loan: return "貸付"
        case .tax: return "税制"
        }
    }

    var emoji: String {
        switch self {
        case .livingSupport: return "🏛️"
        case .medical: return "🏥"
        case .childcare: return "👶"
        case .employment: return "💼"
        case .loan: return "💰"
        case .tax: return "📑"
        }
    }
}

#Preview {
    SupportSystemView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
