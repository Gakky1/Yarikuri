import SwiftUI

// MARK: - アプリのエントリーポイント
@main
struct YarikuriApp: App {

    // AppStateをアプリ全体で共有するStateObject
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    // 通知許可をリクエスト
                    NotificationManager.shared.requestPermission()
                    // デバッグ用：データがない場合はデモデータを自動ロード
                    #if DEBUG
                    if appState.userProfile == nil {
                        appState.loadDemoData()
                    }
                    #endif
                }
        }
    }
}
