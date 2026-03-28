import SwiftUI

// MARK: - 立て直すタブ（制度・給付・副収入）
struct RecoverView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSupportSystem = false
    @State private var showSideIncome = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    headerCard

                    // 使える制度・給付・支援
                    supportSystemCard

                    // 副収入候補
                    sideIncomeCard

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle("立て直す")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showSupportSystem) {
            SupportSystemView()
        }
        .sheet(isPresented: $showSideIncome) {
            SideIncomeView()
        }
    }

    private var headerCard: some View {
        HStack(spacing: 12) {
            Text("🌱").font(.system(size: 28))
            VStack(alignment: .leading, spacing: 3) {
                Text("収入と支援を増やす")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Text("使える制度を確認し、副収入の種を探す")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
            }
        }
        .padding(16)
        .background(AppColor.primaryLight)
        .cornerRadius(14)
    }

    // MARK: - 制度・給付カード
    private var supportSystemCard: some View {
        Button(action: { showSupportSystem = true }) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("使える制度・給付・支援")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Text("あなたの状況に合った支援を確認する")
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColor.textTertiary)
                }

                // 制度サンプル表示
                VStack(spacing: 8) {
                    let systems = SupportSystem.sampleData(for: appState.userProfile)
                    ForEach(systems.prefix(3)) { system in
                        SupportSystemMiniRow(system: system)
                    }
                    if systems.count > 3 {
                        Text("他\(systems.count - 3)件の制度を確認する →")
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.primary)
                    }
                }
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    // MARK: - 副収入候補カード
    private var sideIncomeCard: some View {
        Button(action: { showSideIncome = true }) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("副収入の候補")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Text("スキルや時間を活かして収入を増やす")
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColor.textTertiary)
                }

                // 副収入サンプル表示
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(SideIncomeIdea.sampleData.prefix(4)) { idea in
                            SideIncomeMiniCard(idea: idea)
                        }
                    }
                }
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 制度ミニ行
private struct SupportSystemMiniRow: View {
    let system: SupportSystem

    var body: some View {
        HStack(spacing: 10) {
            Text(system.emoji)
                .font(.system(size: 18))
                .frame(width: 32, height: 32)
                .background(AppColor.tertiaryLight)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 1) {
                Text(system.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Text(system.summary)
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }
            Spacer()
            Text(system.benefit)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppColor.secondary)
        }
        .padding(10)
        .background(AppColor.sectionBackground)
        .cornerRadius(10)
    }
}

// MARK: - 副収入ミニカード
private struct SideIncomeMiniCard: View {
    let idea: SideIncomeIdea

    var body: some View {
        VStack(spacing: 6) {
            Text(idea.emoji).font(.system(size: 28))
            Text(idea.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(idea.incomeRange)
                .font(.system(size: 11))
                .foregroundColor(AppColor.secondary)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(AppColor.sectionBackground)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        RecoverView()
    }
    .environmentObject({
        let s = AppState()
        s.loadDemoData()
        return s
    }())
}
