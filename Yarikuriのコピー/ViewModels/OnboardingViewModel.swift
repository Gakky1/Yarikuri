import Foundation
import SwiftUI
import Combine

// MARK: - オンボーディングの状態管理
// 初回登録フローの入力データを管理します

final class OnboardingViewModel: ObservableObject {

    // MARK: - 現在のステップ
    @Published var currentStep: OnboardingStep = .welcome

    // MARK: - 給料日入力
    @Published var paydayDay: Int = 25

    // MARK: - 手取り感入力
    @Published var incomeRange: IncomeRange = .range200to250k
    @Published var useCustomAmount: Bool = false
    @Published var customAmountText: String = ""

    // MARK: - 固定費入力
    @Published var fixedExpenses: [FixedExpense] = []
    @Published var newExpenseName: String = ""
    @Published var newExpenseAmountText: String = ""
    @Published var newExpenseCategory: FixedExpenseCategory = .other
    @Published var useTotalAmount: Bool = false      // ざっくり合計で入力モード
    @Published var totalFixedExpenseText: String = ""

    // MARK: - 借金入力
    @Published var hasDebt: Bool = false
    @Published var debts: [Debt] = []
    @Published var newDebtName: String = ""
    @Published var newDebtBalanceText: String = ""
    @Published var newDebtMonthlyText: String = ""
    @Published var newDebtRateText: String = ""
    @Published var newDebtType: DebtType = .other
    @Published var newDebtPaymentDay: Int = 27

    // MARK: - 支払い予定入力
    @Published var scheduledPayments: [ScheduledPayment] = []
    @Published var hasNextPayment: Bool = false
    @Published var newPaymentName: String = ""
    @Published var newPaymentAmountText: String = ""
    @Published var newPaymentDate: Date = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()

    // MARK: - 困りごと診断
    @Published var selectedConcerns: Set<ConcernType> = []

    // MARK: - 任意項目
    @Published var hasDependents: Bool = false
    @Published var hasChildren: Bool = false
    @Published var hasRent: Bool = true
    @Published var occupation: OccupationType? = nil

    // MARK: - 計算プロパティ

    var canProceedFromStep: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .payday:
            return paydayDay >= 1 && paydayDay <= 31
        case .income:
            if useCustomAmount {
                return (Int(customAmountText) ?? 0) > 0
            }
            return true
        case .fixedExpense:
            return useTotalAmount ? (Int(totalFixedExpenseText) ?? 0) > 0 : !fixedExpenses.isEmpty || true
        case .debt:
            if hasDebt {
                return !debts.isEmpty || true
            }
            return true
        case .nextPayment:
            return true
        case .concern:
            return !selectedConcerns.isEmpty
        }
    }

    var totalFixedAmount: Int {
        if useTotalAmount {
            return Int(totalFixedExpenseText) ?? 0
        }
        return fixedExpenses.reduce(0) { $0 + $1.amount }
    }

    // MARK: - ステップ進行
    func nextStep() {
        switch currentStep {
        case .welcome: currentStep = .payday
        case .payday: currentStep = .income
        case .income: currentStep = .fixedExpense
        case .fixedExpense: currentStep = .debt
        case .debt: currentStep = .nextPayment
        case .nextPayment: currentStep = .concern
        case .concern: break
        }
    }

    func previousStep() {
        switch currentStep {
        case .welcome: break
        case .payday: currentStep = .welcome
        case .income: currentStep = .payday
        case .fixedExpense: currentStep = .income
        case .debt: currentStep = .fixedExpense
        case .nextPayment: currentStep = .debt
        case .concern: currentStep = .nextPayment
        }
    }

    var stepProgress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }

    var isFirstStep: Bool { currentStep == .welcome }
    var isLastStep: Bool { currentStep == .concern }

    // MARK: - 固定費追加
    func addFixedExpense() {
        guard !newExpenseName.isEmpty,
              let amount = Int(newExpenseAmountText.replacingOccurrences(of: ",", with: "")),
              amount > 0 else { return }

        let expense = FixedExpense(
            name: newExpenseName,
            amount: amount,
            category: newExpenseCategory
        )
        fixedExpenses.append(expense)
        newExpenseName = ""
        newExpenseAmountText = ""
        newExpenseCategory = .other
    }

    func removeFixedExpense(at offsets: IndexSet) {
        fixedExpenses.remove(atOffsets: offsets)
    }

    // MARK: - 借金追加
    func addDebt() {
        guard !newDebtName.isEmpty,
              let balance = Int(newDebtBalanceText.replacingOccurrences(of: ",", with: "")),
              let monthly = Int(newDebtMonthlyText.replacingOccurrences(of: ",", with: "")),
              balance > 0, monthly > 0 else { return }

        let rate = Double(newDebtRateText)
        let debt = Debt(
            lenderName: newDebtName,
            remainingBalance: balance,
            monthlyPayment: monthly,
            interestRate: rate,
            debtType: newDebtType,
            paymentDay: newDebtPaymentDay
        )
        debts.append(debt)
        newDebtName = ""
        newDebtBalanceText = ""
        newDebtMonthlyText = ""
        newDebtRateText = ""
        newDebtType = .other
    }

    func removeDebt(at offsets: IndexSet) {
        debts.remove(atOffsets: offsets)
    }

    // MARK: - 支払い予定追加
    func addScheduledPayment() {
        guard !newPaymentName.isEmpty,
              let amount = Int(newPaymentAmountText.replacingOccurrences(of: ",", with: "")),
              amount > 0 else { return }

        let payment = ScheduledPayment(
            name: newPaymentName,
            amount: amount,
            dueDate: newPaymentDate
        )
        scheduledPayments.append(payment)
        newPaymentName = ""
        newPaymentAmountText = ""
    }

    // MARK: - プロフィール生成
    func buildUserProfile() -> UserProfile {
        let customAmount = useCustomAmount ? Int(customAmountText) : nil
        return UserProfile(
            paydayDay: paydayDay,
            incomeRange: incomeRange,
            customIncomeAmount: customAmount,
            totalFixedExpenses: totalFixedAmount,
            hasDebt: hasDebt,
            concerns: Array(selectedConcerns),
            hasDependents: hasDependents,
            hasChildren: hasChildren,
            hasRent: hasRent,
            occupation: occupation,
            isOnboardingCompleted: false,
            createdAt: Date()
        )
    }
}

// MARK: - オンボーディングステップ
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case payday = 1
    case income = 2
    case fixedExpense = 3
    case debt = 4
    case nextPayment = 5
    case concern = 6

    var title: String {
        switch self {
        case .welcome: return "はじめまして"
        case .payday: return "給料日を教えてください"
        case .income: return "月の手取りはどのくらいですか？"
        case .fixedExpense: return "毎月の固定費を入力してください"
        case .debt: return "借金はありますか？"
        case .nextPayment: return "近いうちの大きな支払いは？"
        case .concern: return "お金の悩みを選んでください"
        }
    }

    var subtitle: String {
        switch self {
        case .welcome: return "まずは簡単な質問に答えてください"
        case .payday: return "毎月何日に給料が入りますか？"
        case .income: return "ざっくりで大丈夫です"
        case .fixedExpense: return "家賃・保険・サブスクなど、毎月必ず出ていくお金です"
        case .debt: return "ローン・リボ・消費者金融など"
        case .nextPayment: return "あれば入力してください（後で追加もできます）"
        case .concern: return "複数選んでOKです"
        }
    }
}
