import Foundation

// MARK: - ローカルデータ保存クラス
// UserDefaultsにJSONエンコードしてデータを保存します
// 将来的にSupabase等のクラウドに差し替えやすい設計にしています

final class LocalDataStore {
    static let shared = LocalDataStore()
    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - キー定数
    private enum Key {
        static let userProfile = "yarikuri.userProfile"
        static let fixedExpenses = "yarikuri.fixedExpenses"
        static let debts = "yarikuri.debts"
        static let scheduledPayments = "yarikuri.scheduledPayments"
        static let completedTaskIds = "yarikuri.completedTaskIds"
    }

    // MARK: - ユーザープロフィール

    func saveUserProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: Key.userProfile)
        }
    }

    func loadUserProfile() -> UserProfile? {
        guard let data = defaults.data(forKey: Key.userProfile) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    // MARK: - 固定費

    func saveFixedExpenses(_ expenses: [FixedExpense]) {
        if let data = try? JSONEncoder().encode(expenses) {
            defaults.set(data, forKey: Key.fixedExpenses)
        }
    }

    func loadFixedExpenses() -> [FixedExpense] {
        guard let data = defaults.data(forKey: Key.fixedExpenses) else { return [] }
        return (try? JSONDecoder().decode([FixedExpense].self, from: data)) ?? []
    }

    // MARK: - 借金

    func saveDebts(_ debts: [Debt]) {
        if let data = try? JSONEncoder().encode(debts) {
            defaults.set(data, forKey: Key.debts)
        }
    }

    func loadDebts() -> [Debt] {
        guard let data = defaults.data(forKey: Key.debts) else { return [] }
        return (try? JSONDecoder().decode([Debt].self, from: data)) ?? []
    }

    // MARK: - 支払い予定

    func saveScheduledPayments(_ payments: [ScheduledPayment]) {
        if let data = try? JSONEncoder().encode(payments) {
            defaults.set(data, forKey: Key.scheduledPayments)
        }
    }

    func loadScheduledPayments() -> [ScheduledPayment] {
        guard let data = defaults.data(forKey: Key.scheduledPayments) else { return [] }
        return (try? JSONDecoder().decode([ScheduledPayment].self, from: data)) ?? []
    }

    // MARK: - 完了済みタスクID

    func saveCompletedTaskIds(_ ids: [String]) {
        defaults.set(ids, forKey: Key.completedTaskIds)
    }

    func loadCompletedTaskIds() -> [String] {
        defaults.stringArray(forKey: Key.completedTaskIds) ?? []
    }

    // MARK: - 全データ削除（デバッグ用）

    func clearAll() {
        defaults.removeObject(forKey: Key.userProfile)
        defaults.removeObject(forKey: Key.fixedExpenses)
        defaults.removeObject(forKey: Key.debts)
        defaults.removeObject(forKey: Key.scheduledPayments)
        defaults.removeObject(forKey: Key.completedTaskIds)
    }
}
