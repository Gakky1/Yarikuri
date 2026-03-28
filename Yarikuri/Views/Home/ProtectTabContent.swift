import SwiftUI

// MARK: - 守るタブ コンテンツ
struct ProtectTabContent: View {
    @EnvironmentObject var appState: AppState

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        LazyVStack(spacing: 16) {
            // プロフィールに応じた優先カード（フル幅）
            if let fp = appState.userProfile?.financialProfile {
                personalizedCards(fp: fp)
            }

            // ── 支出を減らす ──────────────────
            sectionLabel("支出を減らす")
            LazyVGrid(columns: columns, spacing: 12) {
                ProtectGridCard(emoji: "📋", title: "固定費見直し", accentColor: AppColor.primary,
                    description: "毎月必ず出ていく固定費（家賃・保険・サブスク）を1つずつ確認しましょう。使っていないサービスを解約するだけで、月数千円の節約になることも。")
                ProtectGridCard(emoji: "📱", title: "サブスク整理", accentColor: AppColor.primary,
                    description: "動画・音楽・アプリなどのサブスクリプションを一覧にして、本当に使っているか確認を。3か月以上使っていないものは解約の候補です。")
                ProtectGridCard(emoji: "🍱", title: "食費を見直す", accentColor: Color.orange,
                    description: "食費は削りすぎず、でも工夫できる余地が大きい支出です。まとめ買い・作り置き・特売の活用など、無理なく続けられる方法を探してみましょう。")
                ProtectGridCard(emoji: "🛡️", title: "保険を見直す", accentColor: AppColor.secondary,
                    description: "「なんとなく入り続けている」保険はありませんか？公的保険（健康保険・雇用保険）でカバーできる範囲を確認してから、民間保険の必要性を見直しましょう。")
                ProtectGridCard(emoji: "📶", title: "格安SIMに乗り換え", accentColor: Color.teal.opacity(0.8),
                    description: "大手キャリアから格安SIMに乗り換えると、月々の通信費が3,000〜6,000円程度安くなることも。年間で最大7万円の節約に。通話品質を比較してから選びましょう。")
                ProtectGridCard(emoji: "🏠", title: "家賃交渉・引越し検討", accentColor: Color.indigo.opacity(0.75),
                    description: "更新時期に大家さんへ家賃交渉するのは意外と有効。1,000〜5,000円下げてもらえることも。また築年数が古い物件や駅から少し遠い場所への引越しで大幅節約も可能です。")
                ProtectGridCard(emoji: "💡", title: "電気代を節約する", accentColor: Color.orange.opacity(0.8),
                    description: "LED照明への切り替え・エアコンのフィルター掃除・設定温度を1度調整するだけで月数百〜千円の節約に。電力会社の乗り換えも比較してみましょう。")
                ProtectGridCard(emoji: "🚿", title: "水道代を節約する", accentColor: Color.blue.opacity(0.75),
                    description: "シャワーを1分短縮すると月約100円節約。食洗機は手洗いより水が少ない場合も。節水シャワーヘッドへの交換は初期費用2,000〜3,000円で1年以内に回収できます。")
                ProtectGridCard(emoji: "🚌", title: "交通費を見直す", accentColor: AppColor.secondary,
                    description: "定期券の区間や経路を見直したり、自転車通勤に切り替えるだけで月数千円の節約に。テレワーク可能な日数を増やすのも効果的です。")
                ProtectGridCard(emoji: "👗", title: "被服費・美容費を見直す", accentColor: Color.pink.opacity(0.75),
                    description: "シーズンに1回、クローゼットを整理してから不足分だけを購入する習慣で、衝動買いを防ぐ。美容院の頻度やメニューを見直すだけで年数万円変わります。")
                ProtectGridCard(emoji: "🎮", title: "娯楽費を賢く使う", accentColor: Color.purple.opacity(0.75),
                    description: "ゲームの課金・外食・旅行などの娯楽費は生活の質に直結するので無理に削らないことが大切。ただし月予算を決めてオーバーしないよう管理しましょう。")
                ProtectGridCard(emoji: "🏪", title: "コンビニ依存を減らす", accentColor: Color.orange.opacity(0.85),
                    description: "コンビニはスーパーより2〜3割割高。1日1回のコンビニ購入を減らすだけで月5,000〜8,000円の節約になります。まとめ買いとボトル持参で立ち寄る頻度を減らしましょう。")
            }

            // ── 借入を整理する ──────────────────
            sectionLabel("借入を整理する")
            LazyVGrid(columns: columns, spacing: 12) {
                ProtectGridCard(emoji: "💳", title: "リボ払い確認", accentColor: AppColor.danger,
                    description: "リボ払いは毎月の支払いが一定で楽に見えますが、実質年利15〜18%程度の高金利です。残高と毎月の利息を確認し、できるだけ早く完済を目指しましょう。")
                ProtectGridCard(emoji: "🎓", title: "奨学金を整理", accentColor: Color.indigo.opacity(0.8),
                    description: "奨学金の残高・月返済額・返済期間を確認しましょう。返済が苦しい場合は「減額返還制度」や「返還期限猶予」の申請ができる場合があります。")
                ProtectGridCard(emoji: "🏠", title: "住宅ローン見直し", accentColor: Color.teal.opacity(0.8),
                    description: "金利の種類（固定/変動）や残高を定期的に確認しましょう。金利が下がっている場合は借り換えで総返済額を減らせる可能性があります。")
            }

            // ── 使える補助金・制度 ──────────────────
            sectionLabel("使える補助金・制度")
            LazyVGrid(columns: columns, spacing: 12) {
                ProtectGridCard(emoji: "👶", title: "児童手当を確認", accentColor: Color.pink.opacity(0.8),
                    description: "中学校卒業まで支給される児童手当。2024年の改正で所得制限が撤廃され、高校生も対象に拡大されました。申請漏れがないか確認しましょう。")
                ProtectGridCard(emoji: "🏥", title: "高額療養費制度", accentColor: AppColor.secondary,
                    description: "1か月の医療費が一定の上限額（年収により約8〜26万円）を超えた場合、超えた分が返ってくる制度です。申請が必要なので、大きな医療費がかかったら忘れずに。")
                ProtectGridCard(emoji: "📋", title: "医療費控除を申請", accentColor: AppColor.primary,
                    description: "1年間の医療費（家族合算）が10万円を超えた場合、確定申告で医療費控除を受けられます。市販薬・交通費・歯科治療なども対象になる場合があります。")
                ProtectGridCard(emoji: "🎒", title: "教育費の無償化", accentColor: Color.orange,
                    description: "幼稚園・保育園の無償化（3〜5歳）、高校の授業料無償化（就学支援金）、大学の授業料減免（低所得世帯）など、教育費を軽減できる制度を確認しましょう。")
                ProtectGridCard(emoji: "🤝", title: "ひとり親支援", accentColor: Color.purple.opacity(0.8),
                    description: "児童扶養手当・ひとり親医療費助成・就業支援など、自治体ごとにさまざまな支援があります。お住まいの市区町村の窓口やウェブサイトで確認してみましょう。")
                ProtectGridCard(emoji: "🏘️", title: "非課税世帯の給付金", accentColor: AppColor.secondary,
                    description: "住民税非課税世帯や低所得世帯に対して、国や自治体から給付金が支給される場合があります。対象かどうか、お住まいの自治体のHPで確認してみましょう。")
                ProtectGridCard(emoji: "🤱", title: "産前産後・育児支援", accentColor: Color.pink.opacity(0.7),
                    description: "出産育児一時金（42万円〜）、育児休業給付金（給与の67%）、産前産後休業保険料免除など、出産・育児に関わる給付・免除制度を活用しましょう。")
                ProtectGridCard(emoji: "🏥", title: "傷病手当金を確認", accentColor: AppColor.danger,
                    description: "病気・ケガで仕事を休んだ時、健康保険から給与の約3分の2が最長1年6か月支給される制度です。会社員が対象で、連続3日以上の休業が条件。申請を忘れずに。")
                ProtectGridCard(emoji: "📦", title: "失業給付を確認する", accentColor: Color.orange.opacity(0.85),
                    description: "退職後はハローワークで雇用保険の失業給付（基本手当）を申請できます。自己都合でも2〜3か月の待機後に給付開始。在職中に加入期間を確認しておきましょう。")
                ProtectGridCard(emoji: "💊", title: "国民健康保険の軽減", accentColor: Color.teal.opacity(0.8),
                    description: "退職・収入減少時は国民健康保険料の軽減・減額制度が使える場合があります。自治体の窓口で申請が必要です。軽減されると保険料が2〜7割安くなることも。")
                ProtectGridCard(emoji: "📑", title: "年金保険料の免除", accentColor: Color.indigo.opacity(0.75),
                    description: "収入が少ない時期は国民年金保険料の「免除・猶予制度」を使えます。全額免除〜4分の1免除まで段階があり、将来の年金受給資格も守られます。市区町村窓口へ。")
                ProtectGridCard(emoji: "🏡", title: "住宅確保給付金", accentColor: Color.purple.opacity(0.75),
                    description: "離職・廃業・収入減少によって家賃の支払いが困難になった場合、最長9か月間、家賃相当額が自治体から支給される制度です。お住まいの市区町村の窓口に相談を。")
                ProtectGridCard(emoji: "♿", title: "障害者手帳・年金", accentColor: Color.gray.opacity(0.75),
                    description: "精神・身体・知的障害がある方は障害者手帳を取得することで様々な割引・支援が受けられます。障害年金は就労中でも受給できる場合があります。主治医に相談を。")
                ProtectGridCard(emoji: "👴", title: "介護保険サービス", accentColor: Color.teal.opacity(0.75),
                    description: "40歳以上が対象の介護保険。介護が必要になったとき、1〜3割の自己負担でヘルパー・デイサービス・施設入所などが使えます。要介護認定の申請は市区町村窓口で。")
                ProtectGridCard(emoji: "🌾", title: "農業・地方移住支援", accentColor: Color.green.opacity(0.8),
                    description: "地方移住者向けの移住支援金（最大100万円）や農業を始める方への就農給付金（最大年150万円）など、地方創生の補助金は意外と充実しています。検討中の方はぜひ調べを。")
            }
        }
    }

    @ViewBuilder
    private func personalizedCards(fp: UserFinancialProfile) -> some View {
        let hasAny = fp.spendingControlNeed > 0.7 || fp.debtCareNeed > 0.5
            || fp.emergencyFundNeed > 0.6 || fp.hasChildrenOrSupport
        if hasAny {
            sectionLabel("あなたへのアドバイス")
            LazyVGrid(columns: columns, spacing: 12) {
                if fp.spendingControlNeed > 0.7 {
                    ProtectGridCard(emoji: "⚠️", title: "まず支出を把握しよう", accentColor: AppColor.danger,
                        description: "何にいくら使っているかを知ることが節約の第一歩。固定費と変動費を分けてリスト化するだけで、見直しポイントが見えてきます。")
                }
                if fp.debtCareNeed > 0.5 {
                    ProtectGridCard(emoji: "🚨", title: "借入の返済を優先しよう", accentColor: AppColor.danger,
                        description: "金利の高い借入（リボ・カードローン）は、返済が遅れるほど利息が増えます。まず残高と金利を一覧にして、高金利のものから返していきましょう。")
                }
                if fp.emergencyFundNeed > 0.6 {
                    ProtectGridCard(emoji: "🆘", title: "緊急の備えが少ない", accentColor: Color.orange,
                        description: "急な出費（病気・失業・設備故障など）に備えるお金が少ない状態です。まずは1か月分の生活費を目標に、先取り貯蓄を始めてみましょう。")
                }
                if fp.hasChildrenOrSupport {
                    ProtectGridCard(emoji: "👨‍👩‍👧", title: "家族の備えも確認を", accentColor: Color.purple.opacity(0.8),
                        description: "お子さんや扶養家族がいる場合、教育費・医療費・介護費用など将来の大きな支出が予測されます。早めに準備を始めることで、余裕を持った計画が立てられます。")
                }
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColor.textTertiary)
            Rectangle()
                .fill(AppColor.textTertiary.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.top, 4)
    }
}

// MARK: - 守る グリッドカード（3列用）
struct ProtectGridCard: View {
    @EnvironmentObject var appState: AppState
    let emoji: String
    let title: String
    let accentColor: Color
    let description: String
    @State private var showDetail = false

    var body: some View {
        Button(action: {
            showDetail = true
            appState.recordCardView(emoji: emoji, title: title, category: .protect)
        }) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 34))
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, minHeight: 108)
            .background(AppColor.cardBackground)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentColor.opacity(0.2), lineWidth: 1.2))
            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        }
        .sheet(isPresented: $showDetail) {
            InfoDetailSheet(emoji: emoji, title: title, description: description, accentColor: accentColor)
        }
    }
}

// MARK: - 守る フル幅カード（パーソナライズ用）
struct ProtectInfoCard: View {
    @EnvironmentObject var appState: AppState
    let emoji: String
    let title: String
    let accentColor: Color
    let description: String
    @State private var showDetail = false

    var body: some View {
        Button(action: {
            showDetail = true
            appState.recordCardView(emoji: emoji, title: title, category: .protect)
        }) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 38))
                    .frame(width: 48)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColor.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppColor.cardBackground)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentColor.opacity(0.18), lineWidth: 1.2))
            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        }
        .sheet(isPresented: $showDetail) {
            InfoDetailSheet(emoji: emoji, title: title, description: description, accentColor: accentColor)
        }
    }
}
