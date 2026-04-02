import SwiftUI

// MARK: - アプリのエントリーポイント
@main
struct YarikuriApp: App {

    init() {
        // ナビゲーションバー
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(AppColor.background)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        // タブバー
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .white

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .black.withAlphaComponent(0.45)
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(0.45)]
        itemAppearance.selected.iconColor = UIColor(AppColor.primary)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppColor.primary)]
        tabAppearance.stackedLayoutAppearance = itemAppearance
        tabAppearance.inlineLayoutAppearance = itemAppearance
        tabAppearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    // AppStateをアプリ全体で共有するStateObject
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    // 通知許可をリクエスト
                    NotificationManager.shared.requestPermission()
                    // デバッグ用：データがない場合、またはデモデータのバージョンが古い場合はデモデータを自動ロード
                    #if DEBUG
                    let currentDemoVersion = "2.44"
                    let savedDemoVersion = UserDefaults.standard.string(forKey: "demoDataVersion") ?? ""
                    if appState.userProfile == nil || savedDemoVersion != currentDemoVersion {
                        appState.loadDemoData()
                        UserDefaults.standard.set(currentDemoVersion, forKey: "demoDataVersion")
                    }
                    #endif
                }
        }
    }
}
