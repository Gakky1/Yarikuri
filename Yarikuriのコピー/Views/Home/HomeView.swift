import SwiftUI

// MARK: - ホーム画面
// 毎日10秒で状況がわかる「ダッシュボード」です
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSafetyDetail = false
    @State private var showPaymentDetail = false
    @State private var showTaskDetail = false
    @State private var showWeeklyReport = false
    @State private var showMonthlyReport = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // ヘッダー
                    headerSection

                    // 今日のひとこと
                    TodayMessageCard()

                    // 今日やること
                    TodayTaskCard(onTap: { showTaskDetail = true })

                    // 安全度カード（予算・給料日まで）
                    SafetyCard(onDetailTap: { showSafetyDetail = true })

                    // 次の支払い
                    NextPaymentsCard(onDetailTap: { showPaymentDetail = true })

                    // 今週守れたお金
                    WeeklySavingsCard(onReportTap: { showWeeklyReport = true })

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle("やりくり")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showMonthlyReport = true }) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(AppColor.primary)
                }
            }
        }
        .sheet(isPresented: $showSafetyDetail) { SafetyDetailView() }
        .sheet(isPresented: $showPaymentDetail) { PaymentDetailView() }
        .sheet(isPresented: $showTaskDetail) { TodayTaskDetailView() }
        .sheet(isPresented: $showWeeklyReport) { WeeklyReportView() }
        .sheet(isPresented: $showMonthlyReport) { MonthlyReportView() }
    }

    // MARK: - ヘッダー
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingText)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textSecondary)
                Text(todayDateText)
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "おはようございます" }
        if hour < 17 { return "こんにちは" }
        return "お疲れさまです"
    }

    private var todayDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日（E）"
        return formatter.string(from: Date())
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject({
        let s = AppState()
        s.loadDemoData()
        return s
    }())
}
