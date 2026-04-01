import SwiftUI

// MARK: - レポート統合ビュー（週間・月間・年間タブ切り替え）
struct ReportContainerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: ReportTab = .weekly

    enum ReportTab: CaseIterable {
        case weekly, monthly, annual

        var label: String {
            switch self {
            case .weekly:  return "週間"
            case .monthly: return "月間"
            case .annual:  return "年間"
            }
        }
        var emoji: String {
            switch self {
            case .weekly:  return "📊"
            case .monthly: return "📈"
            case .annual:  return "🗓️"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: タブバー
                HStack(spacing: 0) {
                    ForEach(ReportTab.allCases, id: \.label) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.18)) { selectedTab = tab }
                        }) {
                            VStack(spacing: 3) {
                                Text(tab.emoji).font(.system(size: 20))
                                Text(tab.label)
                                    .font(.system(size: 12, weight: selectedTab == tab ? .bold : .regular))
                                    .foregroundColor(selectedTab == tab ? AppColor.primary : AppColor.textTertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                selectedTab == tab ? AppColor.primaryLight : Color.clear
                            )
                            .overlay(
                                Rectangle()
                                    .fill(selectedTab == tab ? AppColor.primary : Color.clear)
                                    .frame(height: 2),
                                alignment: .bottom
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(AppColor.cardBackground)
                .shadow(color: AppColor.shadowColor, radius: 2, x: 0, y: 1)

                // MARK: コンテンツ
                if selectedTab == .weekly {
                    WeeklyReportView(embedded: true)
                        .environmentObject(appState)
                        .id(ReportTab.weekly)
                } else if selectedTab == .monthly {
                    MonthlyReportView(embedded: true)
                        .environmentObject(appState)
                        .id(ReportTab.monthly)
                } else {
                    AnnualReportView(embedded: true)
                        .environmentObject(appState)
                        .id(ReportTab.annual)
                }
            }
            .navigationTitle("レポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
    }
}

#Preview {
    ReportContainerView()
        .environmentObject({ let s = AppState(); s.loadDemoData(); return s }())
}
