import Foundation
import UserNotifications

// MARK: - 通知管理
// お金が動く日だけ通知を出す設計です
// 不要な通知は出しません

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - 通知許可リクエスト
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("通知が許可されました")
            }
        }
    }

    // MARK: - 全通知をスケジュール
    func scheduleAll(for profile: UserProfile, payments: [ScheduledPayment], debts: [Debt]) {
        // 既存通知を全削除
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // 給料日前通知
        schedulePaydayReminder(paydayDay: profile.paydayDay)

        // 支払い前通知
        for payment in payments where !payment.isPaid {
            schedulePaymentReminder(payment: payment)
        }

        // 借金返済日通知
        for debt in debts {
            scheduleDebtPaymentReminder(debt: debt)
        }
    }

    // MARK: - 給料日前通知（2日前）
    private func schedulePaydayReminder(paydayDay: Int) {
        let content = UNMutableNotificationContent()
        content.title = "もうすぐ給料日です"
        content.body = "給料日2日前です。今月の支出を確認しておきましょう。"
        content.sound = .default

        var components = DateComponents()
        components.day = paydayDay - 2
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "payday_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 支払い前通知（前日）
    private func schedulePaymentReminder(payment: ScheduledPayment) {
        let content = UNMutableNotificationContent()
        content.title = "明日は支払い日です"
        content.body = "「\(payment.name)」\(payment.amount.yen)の支払いが明日です。"
        content.sound = .default

        let calendar = Calendar.current
        guard let reminderDate = calendar.date(byAdding: .day, value: -1, to: payment.dueDate) else { return }

        var components = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "payment_\(payment.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 借金返済日通知（3日前）
    private func scheduleDebtPaymentReminder(debt: Debt) {
        let content = UNMutableNotificationContent()
        content.title = "返済日が近づいています"
        content.body = "「\(debt.lenderName)」\(debt.monthlyPayment.yen)の返済日が3日後です。"
        content.sound = .default

        var components = DateComponents()
        components.day = max(1, debt.paymentDay - 3)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "debt_\(debt.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
