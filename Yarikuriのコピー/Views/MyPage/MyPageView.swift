import SwiftUI

// MARK: - マイページ
struct MyPageView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    @State private var showWeeklyReport = false
    @State private var showMonthlyReport = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
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
        .navigationTitle("マイページ")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(AppColor.primary)
                }
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showWeeklyReport) { WeeklyReportView() }
        .sheet(isPresented: $showMonthlyReport) { MonthlyReportView() }
    }

    // MARK: - プロフィールカード
    private var profileCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColor.primaryLight)
                    .frame(width: 64, height: 64)
                Text("🐷").font(.system(size: 32))
            }

            VStack(alignment: .leading, spacing: 4) {
                if let profile = appState.userProfile {
                    Text("毎月\(profile.paydayDay)日が給料日")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    Text("手取り\(profile.incomeRange.shortText)")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textSecondary)
                    if !profile.concerns.isEmpty {
                        Text(profile.concerns.map { $0.emoji }.joined())
                            .font(.system(size: 16))
                    }
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
        VStack(alignment: .leading, spacing: 10) {
            Text("レポート")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)

            HStack(spacing: 12) {
                ReportMenuButton(title: "今週のレポート", emoji: "📊", color: AppColor.primary) {
                    showWeeklyReport = true
                }
                ReportMenuButton(title: "今月のレポート", emoji: "📈", color: AppColor.secondary) {
                    showMonthlyReport = true
                }
            }
        }
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
                SettingsLinkRow(icon: "bell.badge", label: "通知設定", action: {})
                Divider().padding(.leading, 44)
                SettingsLinkRow(icon: "gearshape", label: "詳細設定", action: { showSettings = true })
            }
            .background(AppColor.cardBackground)
            .cornerRadius(14)
            .shadow(color: AppColor.shadowColor, radius: 4)
        }
    }
}

// MARK: - コンポーネント
private struct ReportMenuButton: View {
    let title: String
    let emoji: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji).font(.system(size: 28))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1))
            .cornerRadius(14)
        }
    }
}

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
