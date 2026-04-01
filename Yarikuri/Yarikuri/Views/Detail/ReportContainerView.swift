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
                // MARK: スライドグラス風タブ
                Picker("期間", selection: $selectedTab) {
                    ForEach(ReportTab.allCases, id: \.label) { tab in
                        Text(tab.label).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

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
                ToolbarItem(placement: .navigationBarTrailing) {
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
