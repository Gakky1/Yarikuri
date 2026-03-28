import SwiftUI

// MARK: - 設定画面
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var paydayDay: Int = 25
    @State private var incomeRange: IncomeRange = .range200to250k
    @State private var showResetAlert = false
    @State private var notificationsEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                // 基本設定
                Section(header: Text("基本設定")) {
                    Picker("給料日", selection: $paydayDay) {
                        ForEach(1...31, id: \.self) { day in
                            Text("毎月\(day)日").tag(day)
                        }
                    }

                    Picker("月の手取り", selection: $incomeRange) {
                        ForEach(IncomeRange.allCases, id: \.rawValue) { range in
                            Text(range.displayText).tag(range)
                        }
                    }
                }

                // 通知設定
                Section(header: Text("通知設定")) {
                    Toggle("通知を受け取る", isOn: $notificationsEnabled)
                        .tint(AppColor.primary)

                    if notificationsEnabled {
                        HStack {
                            Text("通知タイミング")
                            Spacer()
                            Text("支払い前日・返済日3日前")
                                .font(.system(size: 13))
                                .foregroundColor(AppColor.textSecondary)
                        }
                    }
                }

                // アプリについて
                Section(header: Text("アプリについて")) {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0").foregroundColor(AppColor.textSecondary)
                    }
                }

                // リセット
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Text("すべてのデータを削除する")
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveSettings()
                        dismiss()
                    }
                    .foregroundColor(AppColor.primary)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let profile = appState.userProfile {
                    paydayDay = profile.paydayDay
                    incomeRange = profile.incomeRange
                }
            }
            .alert("データを削除しますか？", isPresented: $showResetAlert) {
                Button("削除する", role: .destructive) {
                    appState.resetAllData()
                    dismiss()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("すべての設定・データが削除されます。この操作は元に戻せません。")
            }
        }
    }

    private func saveSettings() {
        guard var profile = appState.userProfile else { return }
        profile.paydayDay = paydayDay
        profile.incomeRange = incomeRange
        appState.userProfile = profile
    }
}

#Preview {
    SettingsView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
