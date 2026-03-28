import SwiftUI

// MARK: - メインタブビュー（4タブ構成）
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // ホームタブ
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("ホーム", systemImage: selectedTab == 0 ? "house.fill" : "house")
            }
            .tag(0)

            // 守るタブ
            NavigationStack {
                ProtectView()
            }
            .tabItem {
                Label("守る", systemImage: selectedTab == 1 ? "shield.fill" : "shield")
            }
            .tag(1)

            // 立て直すタブ
            NavigationStack {
                RecoverView()
            }
            .tabItem {
                Label("立て直す", systemImage: selectedTab == 2 ? "arrow.up.circle.fill" : "arrow.up.circle")
            }
            .tag(2)

            // マイページタブ
            NavigationStack {
                MyPageView()
            }
            .tabItem {
                Label("マイページ", systemImage: selectedTab == 3 ? "person.fill" : "person")
            }
            .tag(3)
        }
        .tint(AppColor.primary)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToTab"))) { notification in
            if let tab = notification.object as? Int {
                selectedTab = tab
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
