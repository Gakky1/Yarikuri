import SwiftUI
import UIKit

// MARK: - やりくりん褒めポップアップを最前面ウィンドウで表示するマネージャー
@MainActor
final class PraiseWindowOverlay {
    static let shared = PraiseWindowOverlay()
    private var window: UIWindow?

    private init() {}

    func show(item: PraiseItem, appState: AppState) {
        guard window == nil,
              let scene = UIApplication.shared.connectedScenes
                  .compactMap({ $0 as? UIWindowScene })
                  .first(where: { $0.activationState == .foregroundActive })
        else { return }

        let win = UIWindow(windowScene: scene)
        win.windowLevel = UIWindow.Level.alert + 1
        win.backgroundColor = .clear

        let rootView = YarikurinPraiseView(item: item)
            .environmentObject(appState)
        let vc = UIHostingController(rootView: rootView)
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.makeKeyAndVisible()
        self.window = win
    }

    func hide() {
        window?.isHidden = true
        window?.resignKey()
        window = nil
    }
}
