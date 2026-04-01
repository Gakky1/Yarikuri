import Foundation

// MARK: - 初回6問の回答
struct FinancialQuizAnswers: Codable {
    var mainConcern: MainConcernChoice?
    var monthlySlack: MonthlySlackChoice?
    var existingPayments: ExistingPaymentsChoice?
    var emergencyFund: EmergencyFundChoice?
    var lifeStyle: LifeStyleChoice?
    var investmentExp: InvestmentExpChoice?
}

// MARK: - Q1: いちばん近い悩み
enum MainConcernChoice: String, Codable, CaseIterable {
    case noMoneyLeft
    case dontKnowSpending
    case futureAnxiety
    case investmentFear
    case haveSavings

    var displayText: String {
        switch self {
        case .noMoneyLeft: return "毎月あまり\nお金が残らない"
        case .dontKnowSpending: return "何に使っているか\n分からない"
        case .futureAnxiety: return "将来のお金が\nなんとなく不安"
        case .investmentFear: return "投資を始めたいけど\n怖い"
        case .haveSavings: return "貯金はあるが\n増やし方が分からない"
        }
    }
    var emoji: String {
        switch self {
        case .noMoneyLeft: return "💸"
        case .dontKnowSpending: return "🤔"
        case .futureAnxiety: return "😟"
        case .investmentFear: return "😰"
        case .haveSavings: return "🐷"
        }
    }
}

// MARK: - Q2: 毎月のお金の余裕
enum MonthlySlackChoice: String, Codable, CaseIterable {
    case almostNone
    case alittle
    case someAmount
    case quiteLot
    case dontKnow

    var displayText: String {
        switch self {
        case .almostNone: return "ほぼ残らない"
        case .alittle: return "少しだけ残る"
        case .someAmount: return "ある程度残る"
        case .quiteLot: return "かなり余裕がある"
        case .dontKnow: return "よく分からない"
        }
    }
    var emoji: String {
        switch self {
        case .almostNone: return "😔"
        case .alittle: return "🙂"
        case .someAmount: return "😊"
        case .quiteLot: return "😄"
        case .dontKnow: return "🤷"
        }
    }
}

// MARK: - Q3: 今ある支払い
enum ExistingPaymentsChoice: String, Codable, CaseIterable {
    case noPayments
    case mortgage
    case studentLoan
    case cardLoan
    case otherLoan
    case noAnswer

    var displayText: String {
        switch self {
        case .noPayments: return "特にない"
        case .mortgage: return "住宅ローンがある"
        case .studentLoan: return "奨学金がある"
        case .cardLoan: return "カードローン・\nリボ払いがある"
        case .otherLoan: return "その他の借入がある"
        case .noAnswer: return "答えたくない"
        }
    }
    var emoji: String {
        switch self {
        case .noPayments: return "✅"
        case .mortgage: return "🏠"
        case .studentLoan: return "🎓"
        case .cardLoan: return "💳"
        case .otherLoan: return "📝"
        case .noAnswer: return "🙈"
        }
    }
}

// MARK: - Q4: 急な出費に使えるお金
enum EmergencyFundChoice: String, Codable, CaseIterable {
    case almostNone
    case lessThanMonth
    case oneToThree
    case threeToSix
    case moreThanSix
    case dontKnow

    var displayText: String {
        switch self {
        case .almostNone: return "ほぼない"
        case .lessThanMonth: return "1か月分未満"
        case .oneToThree: return "1〜3か月分くらい"
        case .threeToSix: return "3〜6か月分くらい"
        case .moreThanSix: return "6か月分以上"
        case .dontKnow: return "よく分からない"
        }
    }
    var emoji: String {
        switch self {
        case .almostNone: return "😰"
        case .lessThanMonth: return "😟"
        case .oneToThree: return "🙂"
        case .threeToSix: return "😊"
        case .moreThanSix: return "😄"
        case .dontKnow: return "🤷"
        }
    }
}

// MARK: - Q5: 今の生活に近いもの
enum LifeStyleChoice: String, Codable, CaseIterable {
    case alone
    case withPartner
    case withChildren
    case supportFamily
    case withFamily
    case noAnswer

    var displayText: String {
        switch self {
        case .alone: return "一人暮らし"
        case .withPartner: return "パートナーと\n暮らしている"
        case .withChildren: return "子どもがいる"
        case .supportFamily: return "親や家族を\n支えている"
        case .withFamily: return "家族と同居している"
        case .noAnswer: return "答えたくない"
        }
    }
    var emoji: String {
        switch self {
        case .alone: return "🏠"
        case .withPartner: return "👫"
        case .withChildren: return "👶"
        case .supportFamily: return "🤝"
        case .withFamily: return "👨‍👩‍👧"
        case .noAnswer: return "🙈"
        }
    }
}

// MARK: - Q6: 投資経験
enum InvestmentExpChoice: String, Codable, CaseIterable {
    case noneAtAll
    case interestedNotStarted
    case accumulationOnly
    case someExperience
    case experienced

    var displayText: String {
        switch self {
        case .noneAtAll: return "まったくない"
        case .interestedNotStarted: return "興味はあるが\nまだ始めていない"
        case .accumulationOnly: return "積立だけしている"
        case .someExperience: return "投資信託を\n少ししている"
        case .experienced: return "ある程度慣れている"
        }
    }
    var emoji: String {
        switch self {
        case .noneAtAll: return "🌱"
        case .interestedNotStarted: return "🤔"
        case .accumulationOnly: return "📈"
        case .someExperience: return "💹"
        case .experienced: return "📊"
        }
    }
}

// MARK: - パーソナライズ用スコア（0.0〜1.0）
struct UserFinancialProfile: Codable {
    var protectPriority: Double       // 守ることの優先度
    var spendingControlNeed: Double   // 支出管理の必要性
    var debtCareNeed: Double          // 借入管理の必要性
    var emergencyFundNeed: Double     // 生活防衛資金の必要性
    var growReadiness: Double         // 増やす準備度
    var investmentConfidence: Double  // 投資への自信度
    var hasChildrenOrSupport: Bool    // 子どもあり or 家族を支えている

    // MARK: - 回答からスコアを計算
    static func from(answers: FinancialQuizAnswers) -> UserFinancialProfile {
        var protect = 0.5
        var spending = 0.5
        var debt = 0.0
        var emergency = 0.5
        var grow = 0.5
        var investment = 0.5

        switch answers.mainConcern {
        case .noMoneyLeft:
            spending = min(1.0, spending + 0.3); protect = min(1.0, protect + 0.3)
        case .dontKnowSpending:
            spending = min(1.0, spending + 0.4); protect = min(1.0, protect + 0.2)
        case .futureAnxiety:
            grow = min(1.0, grow + 0.2); emergency = min(1.0, emergency + 0.2)
        case .investmentFear:
            grow = min(1.0, grow + 0.3); investment = max(0.0, investment - 0.1)
        case .haveSavings:
            grow = min(1.0, grow + 0.4); investment = min(1.0, investment + 0.2)
        case nil: break
        }

        switch answers.monthlySlack {
        case .almostNone:
            protect = min(1.0, protect + 0.3); emergency = min(1.0, emergency + 0.3); grow = max(0.0, grow - 0.2)
        case .alittle:
            protect = min(1.0, protect + 0.1)
        case .someAmount:
            grow = min(1.0, grow + 0.1)
        case .quiteLot:
            grow = min(1.0, grow + 0.3); protect = max(0.0, protect - 0.1)
        case .dontKnow:
            spending = min(1.0, spending + 0.3)
        case nil: break
        }

        switch answers.existingPayments {
        case .noPayments, .noAnswer: break
        case .mortgage:
            debt = min(1.0, debt + 0.3)
        case .studentLoan:
            debt = min(1.0, debt + 0.4)
        case .cardLoan:
            debt = 1.0; protect = min(1.0, protect + 0.3); grow = max(0.0, grow - 0.3)
        case .otherLoan:
            debt = min(1.0, debt + 0.5)
        case nil: break
        }

        switch answers.emergencyFund {
        case .almostNone:
            emergency = 1.0; grow = max(0.0, grow - 0.3)
        case .lessThanMonth:
            emergency = min(1.0, emergency + 0.3)
        case .oneToThree:
            emergency = min(1.0, emergency + 0.1)
        case .threeToSix:
            emergency = max(0.0, emergency - 0.1); grow = min(1.0, grow + 0.2)
        case .moreThanSix:
            emergency = 0.0; grow = min(1.0, grow + 0.3)
        case .dontKnow:
            emergency = min(1.0, emergency + 0.2)
        case nil: break
        }

        switch answers.investmentExp {
        case .noneAtAll:            investment = 0.1
        case .interestedNotStarted: investment = 0.3
        case .accumulationOnly:     investment = 0.5
        case .someExperience:       investment = 0.7
        case .experienced:          investment = 0.9
        case nil: break
        }

        let hasChildrenOrSupport = answers.lifeStyle == .withChildren || answers.lifeStyle == .supportFamily

        return UserFinancialProfile(
            protectPriority: protect,
            spendingControlNeed: spending,
            debtCareNeed: debt,
            emergencyFundNeed: emergency,
            growReadiness: grow,
            investmentConfidence: investment,
            hasChildrenOrSupport: hasChildrenOrSupport
        )
    }
}
