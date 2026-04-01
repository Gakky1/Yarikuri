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

// MARK: - 守る カード関連コンテンツデータ
extension FukugyouRelatedContent {
    static let protectData: [String: FukugyouRelatedContent] = [

        // ── 支出を減らす ──
        "固定費見直し": .init(avgIncome: nil, news: [
            .init(icon: "📋", headline: "固定費の見直しで月3万円を削減した家計改善術", source: "東洋経済"),
            .init(icon: "📰", headline: "固定費チェックリスト｜今すぐ確認すべき10項目", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "固定費を削るだけで年間30万円が浮く仕組み", source: "Forbes Japan"),
            .init(icon: "📊", headline: "家計の固定費割合の理想は収入の50%以下？目安を解説", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "固定費vs変動費｜削りやすいのはどちらかを徹底分析", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "固定費見直しで住宅費・保険・通信費を一気に削った体験", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "固定費を月3万円削減した家計改善の全手順", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "固定費の見直しで最初にやること10選", channel: "家計TV"),
            .init(platformIcon: "🎥", title: "住居費・保険・通信費を一気に削減する方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "固定費チェックリストの使い方と見直し順序", channel: "家計改善TV"),
            .init(platformIcon: "▶️", title: "年収300万円台で固定費を削って貯金した方法", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "固定費見直しで年間50万円を貯めた主婦の話", channel: "お金の教室"),
        ]),
        "サブスク整理": .init(avgIncome: nil, news: [
            .init(icon: "📱", headline: "サブスク地獄から脱出｜月5,000円の節約に成功した方法", source: "東洋経済"),
            .init(icon: "📰", headline: "日本人が契約しているサブスク平均数は6.8件", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "使っていないサブスクを一括管理できるアプリ5選", source: "Forbes Japan"),
            .init(icon: "📊", headline: "NetflixをやめてもYouTube Premiumは続けるべき理由", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "サブスク断捨離で年間6万円を削減した実例", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "月1回のサブスク棚卸しで無駄な出費をゼロにする方法", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "サブスクを整理して月5,000円を節約する方法", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "サブスク管理アプリの使い方と解約手順", channel: "家計TV"),
            .init(platformIcon: "🎥", title: "本当に必要なサブスクの選び方と優先順位", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "サブスク断捨離で年間8万円節約した体験談", channel: "節約攻略TV"),
            .init(platformIcon: "▶️", title: "サブスクの棚卸し方法と解約判断の基準", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "家族のサブスク共有で個人コストを下げる方法", channel: "家計改善TV"),
        ]),
        "食費を見直す": .init(avgIncome: nil, news: [
            .init(icon: "🍱", headline: "食費2万円台を実現した一人暮らしの献立術", source: "東洋経済"),
            .init(icon: "📰", headline: "スーパーの使い分けで食費が月1万円減った方法", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "作り置き週1回で食費と時間を同時に節約する", source: "Forbes Japan"),
            .init(icon: "📊", headline: "物価高時代の食費節約術｜削りすぎない7つのルール", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "業務スーパー活用で食費を30%削減した実例", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "4人家族で食費月4万円を実現した買い物ルーティン", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "食費を月1万円削減する買い物術と献立管理", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "業務スーパーで食費を下げるコスパ最強商品10選", channel: "食費節約TV"),
            .init(platformIcon: "🎥", title: "週1作り置きで食費と時間を節約する方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "一人暮らしの食費2万円台を実現する方法", channel: "節約攻略TV"),
            .init(platformIcon: "▶️", title: "スーパーの使い分けと特売日の活用術", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "家族4人の食費月4万円を実現した買い物方法", channel: "家計TV"),
        ]),
        "保険を見直す": .init(avgIncome: nil, news: [
            .init(icon: "🛡️", headline: "保険の見直しで年間15万円を節約した事例を解説", source: "東洋経済"),
            .init(icon: "📰", headline: "公的保険で実は十分｜民間保険を削れる範囲の真実", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "ライフステージ別・本当に必要な保険の種類と金額", source: "Forbes Japan"),
            .init(icon: "📊", headline: "保険料の平均支払額｜日本人は払いすぎている？", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "保険を見直す際に絶対に確認すべき3つのポイント", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "無駄な特約を外すだけで保険料が月5,000円下がった話", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "保険の見直しで年間15万円を節約する方法", channel: "保険TV"),
            .init(platformIcon: "▶️", title: "公的保険でカバーできる範囲と民間保険の必要性", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "保険の特約を整理して保険料を下げる手順", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "ライフステージ別に必要な保険を選ぶ方法", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "FPに相談せずに保険を自分で見直す方法", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "独身・既婚・子あり別に必要な保険の違い", channel: "お金の教室"),
        ]),
        "格安SIMに乗り換え": .init(avgIncome: nil, news: [
            .init(icon: "📶", headline: "格安SIM乗り換えで月5,000円節約｜手順と注意点", source: "東洋経済"),
            .init(icon: "📰", headline: "ahamoとpovo2.0どちらが自分に合うか比較した", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "格安SIM10社を比較｜通信速度と料金の実測データ", source: "Forbes Japan"),
            .init(icon: "📊", headline: "家族4人で大手キャリア→格安SIM切替で年24万円節約", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "MNP乗り換えの流れ｜番号そのままで最短1日で完了", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "格安SIMで失敗しないための事前確認チェックリスト", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "格安SIMへの乗り換え手順と選び方を解説", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "ahamoへの乗り換え方法【画面操作で解説】", channel: "スマホTV"),
            .init(platformIcon: "🎥", title: "格安SIM比較10社の通信速度と料金を徹底比較", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "MNP転出から新SIM開通まで全手順を解説", channel: "節約攻略TV"),
            .init(platformIcon: "▶️", title: "格安SIMで損しないための選び方と注意点", channel: "家計TV"),
            .init(platformIcon: "🎥", title: "家族4人を格安SIMにして年24万円を節約した方法", channel: "お金の教室"),
        ]),
        "家賃交渉・引越し検討": .init(avgIncome: nil, news: [
            .init(icon: "🏠", headline: "家賃交渉に成功した人の共通点｜下げ方とタイミング", source: "東洋経済"),
            .init(icon: "📰", headline: "更新時に家賃を3,000円下げた交渉術と実例", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "引越しで家賃月2万円削減｜住み替えのコスト計算方法", source: "Forbes Japan"),
            .init(icon: "📊", headline: "家賃交渉の成功率は約30%｜断られた場合の対処法", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "築古物件・駅遠物件で家賃を下げながら快適に住む方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "引越し費用の相場と安くする交渉術まとめ", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "家賃交渉で成功するための伝え方と準備", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "更新時の家賃値下げ交渉の具体的なセリフと手順", channel: "住まいTV"),
            .init(platformIcon: "🎥", title: "引越しで家賃を月2万円削減する物件の選び方", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "引越し費用を半額にする業者比較と交渉術", channel: "節約攻略TV"),
            .init(platformIcon: "▶️", title: "築古物件のメリット・デメリットと見るべきポイント", channel: "家計TV"),
            .init(platformIcon: "🎥", title: "住居費を収入の25%以下に抑える住まい選びの基準", channel: "お金の教室"),
        ]),
        "電気代を節約する": .init(avgIncome: nil, news: [
            .init(icon: "💡", headline: "電気代高騰の今こそ｜月3,000円節電する方法まとめ", source: "東洋経済"),
            .init(icon: "📰", headline: "電力会社の切り替えで年間1.5万円安くなった事例", source: "ダイヤモンドオンライン"),
            .init(icon: "🌿", headline: "エアコンの設定温度1度変えると電気代がいくら変わるか", source: "Forbes Japan"),
            .init(icon: "📊", headline: "LED切り替え費用の回収期間と長期節電効果を計算", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "電気代を高くする家電ランキングと節電の優先順位", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "スマートプラグで待機電力をゼロにする節電術", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "電気代を月3,000円下げる節電テクニック10選", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "電力会社を切り替えて年間1.5万円節約する方法", channel: "光熱費TV"),
            .init(platformIcon: "🎥", title: "エアコンの電気代を最小化する正しい使い方", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "LED照明に全部替えた場合の節約効果を試算", channel: "節約攻略TV"),
            .init(platformIcon: "▶️", title: "電気代を高くしている家電の見直しと対策", channel: "家電チャンネル"),
            .init(platformIcon: "🎥", title: "太陽光パネルで電気代ゼロを実現した家庭の話", channel: "お金の教室"),
        ]),
        "水道代を節約する": .init(avgIncome: nil, news: [
            .init(icon: "🚿", headline: "節水シャワーヘッドの効果｜1年で元が取れる計算", source: "東洋経済"),
            .init(icon: "📰", headline: "シャワーを1分短くすると年間でいくら節約できるか", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "食洗機は節水か？手洗いとのコスト比較結果", source: "Forbes Japan"),
            .init(icon: "📊", headline: "水道代を月500円下げた家庭の節水テクニック一覧", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "お風呂の残り湯を洗濯に使う節水効果と方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "節水コマの設置で水道代が年2万円安くなった事例", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "水道代を月500円節約する方法まとめ", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "節水シャワーヘッドの選び方と取り付け方法", channel: "節水TV"),
            .init(platformIcon: "🎥", title: "お風呂・洗濯・食器洗いの節水テクニック", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "食洗機の電気代・水道代コスト比較結果を公開", channel: "家電チャンネル"),
            .init(platformIcon: "▶️", title: "年間2万円の節水を実現した家庭の取り組み", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "節水コマ設置で水道代を下げる方法と効果", channel: "お金の教室"),
        ]),
        "交通費を見直す": .init(avgIncome: nil, news: [
            .init(icon: "🚌", headline: "自転車通勤に切り替えて交通費月1万円を節約した話", source: "東洋経済"),
            .init(icon: "📰", headline: "定期券の区間見直しで年間5万円節約できるケース", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "テレワーク週3日で交通費定期代が実質ゼロになった", source: "Forbes Japan"),
            .init(icon: "📊", headline: "通勤手段別コスト比較｜電車・バス・自転車・徒歩", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "カーシェアに切り替えてマイカー維持費を年50万円削減", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "ICカードのポイント還元で交通費を実質節約する方法", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "交通費を月1万円削減する方法と通勤コスト比較", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "自転車通勤のメリット・デメリットと始め方", channel: "通勤TV"),
            .init(platformIcon: "🎥", title: "定期券の見直しで浮いた交通費の運用方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "マイカーをやめてカーシェアに変えた場合のコスト差", channel: "節約攻略TV"),
            .init(platformIcon: "▶️", title: "テレワーク活用で交通費を削減する交渉方法", channel: "家計TV"),
            .init(platformIcon: "🎥", title: "交通費節約で年間12万円を貯めた会社員の体験", channel: "お金の教室"),
        ]),
        "被服費・美容費を見直す": .init(avgIncome: nil, news: [
            .init(icon: "👗", headline: "クローゼットの断捨離で衝動買いが減った体験談", source: "東洋経済"),
            .init(icon: "📰", headline: "ミニマリストの被服費年間3万円を実現した買い物ルール", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "美容院の頻度を変えずに美容費を月3,000円減らす方法", source: "Forbes Japan"),
            .init(icon: "📊", headline: "メルカリ活用で洋服代をほぼゼロにした実例", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "ユニクロ・GUをベースに年間被服費を5万円以下に", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "セルフカラー・セルフネイルで美容費を年5万円削減", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "被服費・美容費を年間10万円削減する方法", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "クローゼット断捨離で衝動買いをなくす方法", channel: "整理整頓TV"),
            .init(platformIcon: "🎥", title: "メルカリを使って洋服代をほぼゼロにする方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "美容費を下げながら見た目を保つミニマル美容術", channel: "節約攻略TV"),
            .init(platformIcon: "▶️", title: "ユニクロGUで年間被服費5万円以下を実現する方法", channel: "ファッションTV"),
            .init(platformIcon: "🎥", title: "セルフカラーの方法と失敗しないコツ", channel: "お金の教室"),
        ]),
        "娯楽費を賢く使う": .init(avgIncome: nil, news: [
            .init(icon: "🎮", headline: "娯楽費の予算管理｜削らずに満足度を上げる方法", source: "東洋経済"),
            .init(icon: "📰", headline: "「楽しいお金の使い方」で生活満足度が上がった事例", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "映画・旅行・外食の娯楽費を賢く削る3つのルール", source: "Forbes Japan"),
            .init(icon: "📊", headline: "娯楽費の月予算の決め方｜収入の何%が適切か", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "無料・格安で楽しめるエンタメの探し方まとめ", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "旅行費を半額にするポイント活用と格安予約のコツ", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "娯楽費の予算管理で生活の質を下げない節約術", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "無料で楽しめるエンタメ・趣味の探し方", channel: "家計TV"),
            .init(platformIcon: "🎥", title: "旅行費を半額にするポイント活用術", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "娯楽費の月予算の決め方と使い方のルール", channel: "節約攻略TV"),
            .init(platformIcon: "▶️", title: "外食を賢く楽しむ割引・クーポン活用術", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "ゲーム課金を月1,000円以内に抑える管理方法", channel: "家計改善TV"),
        ]),
        "コンビニ依存を減らす": .init(avgIncome: nil, news: [
            .init(icon: "🏪", headline: "コンビニに月2万円を使っていた人が節約した方法", source: "東洋経済"),
            .init(icon: "📰", headline: "コンビニvsスーパー価格比較｜実は2〜3割高い理由", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "コンビニに立ち寄らない生活習慣の作り方", source: "Forbes Japan"),
            .init(icon: "📊", headline: "週5コンビニ利用者が月いくら余分に払っているか計算", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "コンビニ代わりに使えるスーパーの活用術と時短テク", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "コンビニ依存をやめて月8,000円を節約した体験談", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "コンビニ依存をやめて月1万円を節約する方法", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "コンビニに寄らない買い物習慣の作り方", channel: "家計TV"),
            .init(platformIcon: "🎥", title: "コンビニ依存からスーパー活用へ切り替える方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "弁当・水筒持参でコンビニ利用ゼロにした体験談", channel: "節約攻略TV"),
            .init(platformIcon: "▶️", title: "コンビニ代わりに使えるドラッグストア活用術", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "週5コンビニ利用をやめて年間12万円を節約した話", channel: "家計改善TV"),
        ]),

        // ── 借入を整理する ──
        "リボ払い確認": .init(avgIncome: nil, news: [
            .init(icon: "💳", headline: "リボ払いの実態｜年利15〜18%で知らずに大損している人が続出", source: "東洋経済"),
            .init(icon: "📰", headline: "リボ払いを一括返済に切り替える方法と手順", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "リボ払いで払っている利息の計算方法と総額", source: "Forbes Japan"),
            .init(icon: "📊", headline: "カード会社別リボ払い金利比較と解約手順", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "リボ払い地獄からの脱出｜毎月の支払額を増やす戦略", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "リボ払いをやめて年間10万円の利息を節約した体験談", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "リボ払いの仕組みと怖さをわかりやすく解説", channel: "借金返済TV"),
            .init(platformIcon: "▶️", title: "リボ払いを一括返済に切り替える具体的な手順", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "リボ払いの金利計算｜知ると怖い総支払額の仕組み", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "リボ払い地獄から脱出した人の返済戦略を公開", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "クレジットカードのリボ払い設定を解除する方法", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "リボ払いをやめてから資産が増え始めた体験談", channel: "お金の教室"),
        ]),
        "奨学金を整理": .init(avgIncome: nil, news: [
            .init(icon: "🎓", headline: "奨学金の返済が苦しい人が使える救済制度一覧2024", source: "東洋経済"),
            .init(icon: "📰", headline: "減額返還制度の申請方法と審査に通るための条件", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "奨学金の返還猶予制度の種類と申請タイミング", source: "Forbes Japan"),
            .init(icon: "📊", headline: "奨学金の繰り上げ返済は得か損か？計算して比較した", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "奨学金返済中に転職・副業で返済を早める方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "奨学金返済を10年短縮した節約＋繰り上げ返済戦略", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "奨学金の返済が苦しい人が使える制度を全解説", channel: "奨学金TV"),
            .init(platformIcon: "▶️", title: "減額返還制度の申請手順を丁寧に解説", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "奨学金の繰り上げ返済のメリット・デメリット", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "奨学金を返しながら貯金する家計管理術", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "奨学金返還猶予の申請方法と注意点", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "奨学金返済を10年短縮した繰り上げ返済術", channel: "お金の教室"),
        ]),
        "住宅ローン見直し": .init(avgIncome: nil, news: [
            .init(icon: "🏠", headline: "住宅ローン借り換えで総返済額が300万円減った事例", source: "東洋経済"),
            .init(icon: "📰", headline: "固定金利vs変動金利｜2024年の金利環境での正しい選択", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "住宅ローン借り換えの手順とかかる費用の全体像", source: "Forbes Japan"),
            .init(icon: "📊", headline: "借り換えメリットが出る金利差の目安と計算方法", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "住宅ローンの繰り上げ返済の効果と最適なタイミング", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "金利上昇時代に固定金利へ切り替えるべきか判断基準", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "住宅ローンの借り換えで300万円節約した方法", channel: "住宅ローンTV"),
            .init(platformIcon: "▶️", title: "固定金利と変動金利どちらを選ぶべきか解説", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "住宅ローン借り換えの手順と注意点まとめ", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "繰り上げ返済の効果をシミュレーションで解説", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "住宅ローン審査に通るための準備と注意点", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "金利上昇時代の住宅ローン対策を専門家が解説", channel: "お金の教室"),
        ]),

        // ── 使える補助金・制度 ──
        "児童手当を確認": .init(avgIncome: nil, news: [
            .init(icon: "👶", headline: "2024年改正児童手当｜高校生まで拡大の申請方法", source: "東洋経済"),
            .init(icon: "📰", headline: "児童手当の所得制限撤廃で受け取れる人が大幅増加", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "児童手当の申請漏れを防ぐ手続きのタイミング", source: "Forbes Japan"),
            .init(icon: "📊", headline: "児童手当の支給額｜子どもの年齢別・人数別早見表", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "児童手当と他の子育て給付金を合わせた受取総額", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "児童手当を全額積立投資すると18年後にいくらになるか", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "2024年改正児童手当の申請方法と変更点を解説", channel: "子育て制度TV"),
            .init(platformIcon: "▶️", title: "児童手当の受取漏れをなくす申請チェックリスト", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "児童手当を積立投資で教育費を作る方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "高校生まで拡大された児童手当の詳細を解説", channel: "子育てTV"),
            .init(platformIcon: "▶️", title: "児童手当と保育料無償化のW活用で節約する方法", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "子育て支援制度を全部使って家計を助ける方法", channel: "お金の教室"),
        ]),
        "高額療養費制度": .init(avgIncome: nil, news: [
            .init(icon: "🏥", headline: "高額療養費制度の申請方法と戻ってくる金額の計算", source: "東洋経済"),
            .init(icon: "📰", headline: "限度額適用認定証を事前に取得する方法と手順", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "入院費が100万円でも8万円で済む仕組みを解説", source: "Forbes Japan"),
            .init(icon: "📊", headline: "年収別の高額療養費自己負担上限額一覧表", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "高額療養費と民間の医療保険はどちらが得か比較", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "高額療養費の申請を知らずに100万円損した人の話", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "高額療養費制度の仕組みと申請方法を解説", channel: "医療費TV"),
            .init(platformIcon: "▶️", title: "限度額適用認定証の取り方と使い方", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "手術・入院費の自己負担を最小化する制度活用術", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "年収別の高額療養費上限額と計算方法を解説", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "高額療養費の申請手順と時効に注意する点", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "医療保険不要論と高額療養費の関係を解説", channel: "お金の教室"),
        ]),
        "医療費控除を申請": .init(avgIncome: nil, news: [
            .init(icon: "📋", headline: "医療費控除の対象になるもの・ならないものの全リスト", source: "東洋経済"),
            .init(icon: "📰", headline: "家族合算で医療費控除を申請する方法と注意点", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "歯科矯正・レーシック・不妊治療も医療費控除の対象", source: "Forbes Japan"),
            .init(icon: "📊", headline: "医療費控除で還付される金額の計算シミュレーション", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "e-Taxで医療費控除を申請する際の領収書の扱い", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "通院交通費も対象！見落としがちな医療費控除の費用", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "医療費控除の申請方法を画面で丁寧に解説", channel: "節税TV"),
            .init(platformIcon: "▶️", title: "家族合算で医療費控除を最大化する方法", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "e-Taxで医療費控除を申請する全手順", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "医療費控除の対象費用と領収書の管理方法", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "セルフメディケーション税制との使い分け方", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "医療費控除で年間3万円の還付を受けた体験談", channel: "お金の教室"),
        ]),
        "教育費の無償化": .init(avgIncome: nil, news: [
            .init(icon: "🎒", headline: "2024年最新｜教育費無償化制度の対象と申請方法", source: "東洋経済"),
            .init(icon: "📰", headline: "大学授業料無償化の条件と低所得世帯の支援拡充", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "高校無償化（就学支援金）の申請手順と所得要件", source: "Forbes Japan"),
            .init(icon: "📊", headline: "保育料無償化で年間いくら節約できるか計算した", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "私立高校・大学でも使える教育費補助制度まとめ", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "教育費支援制度を活用して子ども一人当たり300万円節約", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "教育費無償化制度の種類と申請方法を解説", channel: "教育制度TV"),
            .init(platformIcon: "▶️", title: "高校の就学支援金の申請手順を画面で解説", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "大学授業料無償化の対象と手続き方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "保育料無償化で年間いくら節約できるか計算", channel: "子育てTV"),
            .init(platformIcon: "▶️", title: "教育費支援制度を全部活用して300万円節約した話", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "私立学校でも使える教育費補助制度の探し方", channel: "お金の教室"),
        ]),
        "ひとり親支援": .init(avgIncome: nil, news: [
            .init(icon: "🤝", headline: "ひとり親が使える公的支援制度一覧2024年版", source: "東洋経済"),
            .init(icon: "📰", headline: "児童扶養手当の受給条件と申請方法を詳しく解説", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "ひとり親医療費助成制度で医療費の自己負担をゼロに", source: "Forbes Japan"),
            .init(icon: "📊", headline: "ひとり親向け就業支援・職業訓練の活用方法", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "自治体ごとに異なるひとり親支援を調べる方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "支援制度をフル活用してひとり親でも貯金できた体験", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "ひとり親が使える支援制度を全部解説", channel: "子育て制度TV"),
            .init(platformIcon: "▶️", title: "児童扶養手当の申請方法と受給額の計算", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "ひとり親医療費助成の対象と申請手続き", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "ひとり親向け就業支援制度の活用事例", channel: "子育てTV"),
            .init(platformIcon: "▶️", title: "自治体のひとり親支援制度の調べ方と申請方法", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "支援制度を全部使ってひとり親でも貯金した方法", channel: "お金の教室"),
        ]),
        "非課税世帯の給付金": .init(avgIncome: nil, news: [
            .init(icon: "🏘️", headline: "住民税非課税世帯に支給される給付金の対象条件2024", source: "東洋経済"),
            .init(icon: "📰", headline: "非課税世帯給付金の申請期限と手続き方法を解説", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "住民税非課税の基準額と対象かどうかの確認方法", source: "Forbes Japan"),
            .init(icon: "📊", headline: "給付金を見逃した人が多い理由と自治体への確認方法", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "非課税世帯以外にも支給される低所得向け給付金一覧", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "給付金を受け取り損ねないためのチェックリスト", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "非課税世帯給付金の対象条件と申請方法", channel: "給付金TV"),
            .init(platformIcon: "▶️", title: "住民税非課税かどうかを確認する方法", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "見落としがちな給付金・補助金の探し方", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "自治体の給付金・支援制度の調べ方ガイド", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "給付金の申請期限に間に合わせるための準備", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "給付金を受け取れる全制度をまとめて解説", channel: "お金の教室"),
        ]),
        "産前産後・育児支援": .init(avgIncome: nil, news: [
            .init(icon: "🤱", headline: "出産育児一時金が50万円に引き上げ｜申請方法を解説", source: "東洋経済"),
            .init(icon: "📰", headline: "育休中にもらえるお金の全種類と金額を解説", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "育児休業給付金の計算方法｜手取りは給与の何%か", source: "Forbes Japan"),
            .init(icon: "📊", headline: "産前産後の社会保険料免除で年間いくら浮くか計算", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "パパ育休の給付金と産後パパ育休の活用方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "出産にかかる費用と受け取れる給付金の全体像まとめ", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "出産・育児でもらえる給付金を全部解説", channel: "子育て制度TV"),
            .init(platformIcon: "▶️", title: "出産育児一時金の申請方法と直接支払制度", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "育児休業給付金の計算方法と受け取り手順", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "産前産後休業の社会保険料免除を申請する方法", channel: "子育てTV"),
            .init(platformIcon: "▶️", title: "パパ育休の取得方法と給付金の仕組みを解説", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "出産費用と給付金の差額を最小化する方法", channel: "お金の教室"),
        ]),
        "傷病手当金を確認": .init(avgIncome: nil, news: [
            .init(icon: "🏥", headline: "傷病手当金の申請方法｜給与の3分の2を最長1.5年受給", source: "東洋経済"),
            .init(icon: "📰", headline: "傷病手当金の申請を知らずに損した人が多い理由", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "傷病手当金の計算式と実際の受取額シミュレーション", source: "Forbes Japan"),
            .init(icon: "📊", headline: "傷病手当金の申請に必要な書類と手続きの流れ", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "傷病手当金受給中に気をつけること・できないこと", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "うつ病・パニック障害でも受け取れた傷病手当金の体験談", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "傷病手当金の仕組みと申請方法を完全解説", channel: "社会保険TV"),
            .init(platformIcon: "▶️", title: "傷病手当金の申請書類の書き方と提出方法", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "病気・ケガで休職した場合に受け取れるお金の全体像", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "傷病手当金と有給・休業補償の違いを解説", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "うつ病で傷病手当金を申請した実体験を公開", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "傷病手当金受給中の確定申告と税金の扱い", channel: "お金の教室"),
        ]),
        "失業給付を確認する": .init(avgIncome: nil, news: [
            .init(icon: "📦", headline: "失業給付（基本手当）の受給期間と金額の計算方法", source: "東洋経済"),
            .init(icon: "📰", headline: "自己都合退職でも3ヶ月後に受け取れる失業給付のしくみ", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "ハローワークでの失業給付申請手順を詳しく解説", source: "Forbes Japan"),
            .init(icon: "📊", headline: "在職中に確認すべき雇用保険の加入期間と要件", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "会社都合退職と自己都合退職の給付日数の違い", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "失業給付を受給しながら転職活動した人の体験談", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "失業給付の申請方法と受給額の計算を解説", channel: "ハローワークTV"),
            .init(platformIcon: "▶️", title: "ハローワークで失業給付を申請する全手順", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "退職後にもらえるお金の種類と手続き方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "失業給付の受給期間中にできること・できないこと", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "雇用保険の加入期間の確認方法と注意点", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "失業給付をもらいながら転職活動を成功させた方法", channel: "お金の教室"),
        ]),
        "国民健康保険の軽減": .init(avgIncome: nil, news: [
            .init(icon: "💊", headline: "退職後の国民健康保険料が高い理由と軽減制度", source: "東洋経済"),
            .init(icon: "📰", headline: "会社都合退職の場合に使える保険料軽減特例を解説", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "任意継続保険vs国民健康保険どちらが安いか比較", source: "Forbes Japan"),
            .init(icon: "📊", headline: "国民健康保険の均等割・所得割の仕組みと計算方法", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "低所得者向け国民健康保険料7割軽減の申請方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "国民健康保険料を軽減して月2万円を節約した体験談", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "退職後の国民健康保険料と軽減制度を解説", channel: "社会保険TV"),
            .init(platformIcon: "▶️", title: "任意継続vs国保どちらが安いか計算する方法", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "国民健康保険の軽減申請の手順と必要書類", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "会社都合退職の保険料軽減特例を活用する方法", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "収入が減った場合の国民健康保険料の再計算方法", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "国保の軽減申請で月2万円安くなった体験談", channel: "お金の教室"),
        ]),
        "年金保険料の免除": .init(avgIncome: nil, news: [
            .init(icon: "📑", headline: "国民年金保険料の免除制度｜全額〜4分の1まで段階別解説", source: "東洋経済"),
            .init(icon: "📰", headline: "免除期間の将来の年金受給額への影響と追納制度", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "年金保険料免除の申請方法と審査基準", source: "Forbes Japan"),
            .init(icon: "📊", headline: "学生納付特例と若者向け猶予制度の違いと申請", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "免除申請を拒否された場合の再申請と不服申し立て", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "収入が少ない時期の年金免除で年間20万円を節約した体験", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "国民年金保険料の免除制度を詳しく解説", channel: "年金TV"),
            .init(platformIcon: "▶️", title: "年金保険料の免除申請の手順と必要書類", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "免除・猶予が将来の年金に与える影響と追納方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "学生・若者向けの年金猶予制度の活用方法", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "収入減少時の年金免除で年間20万円を節約する方法", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "年金免除後の追納で将来の受取額を増やす戦略", channel: "お金の教室"),
        ]),
        "住宅確保給付金": .init(avgIncome: nil, news: [
            .init(icon: "🏡", headline: "住宅確保給付金の申請条件と支給期間・金額を解説", source: "東洋経済"),
            .init(icon: "📰", headline: "住宅確保給付金が最長9ヶ月延長できる条件と手続き", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "離職後すぐに申請すべき住宅確保給付金の手順", source: "Forbes Japan"),
            .init(icon: "📊", headline: "地域別の住宅確保給付金の支給上限額一覧", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "住宅確保給付金と生活困窮者自立支援制度の連携", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "住宅確保給付金を受給して経済的に立て直した体験談", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "住宅確保給付金の申請方法と対象条件を解説", channel: "給付金TV"),
            .init(platformIcon: "▶️", title: "家賃が払えない状況での住宅確保給付金申請", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "住宅確保給付金の申請に必要な書類と手順", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "給付金を受給しながら生活再建した体験談", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "生活困窮者自立支援制度と住宅確保給付金の活用法", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "住宅確保給付金で家賃を支援してもらう方法", channel: "お金の教室"),
        ]),
        "障害者手帳・年金": .init(avgIncome: nil, news: [
            .init(icon: "♿", headline: "障害者手帳で使える割引・支援サービス一覧2024", source: "東洋経済"),
            .init(icon: "📰", headline: "障害年金の申請方法と受給額の計算を解説", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "精神障害者保健福祉手帳の取得方法と使えるサービス", source: "Forbes Japan"),
            .init(icon: "📊", headline: "就労中でも受給できる障害年金の条件と申請手順", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "障害者手帳の交通費・公共施設・税金の割引まとめ", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "障害年金の申請で毎月10万円を受給できた体験談", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "障害者手帳の取得方法と使えるサービスを解説", channel: "福祉制度TV"),
            .init(platformIcon: "▶️", title: "障害年金の申請手順と必要書類の準備方法", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "精神障害者保健福祉手帳で使える割引と支援", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "就労しながら障害年金を受給する方法と注意点", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "障害者手帳の交通費割引をフル活用する方法", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "障害年金の不支給決定を覆した再申請の体験談", channel: "お金の教室"),
        ]),
        "介護保険サービス": .init(avgIncome: nil, news: [
            .init(icon: "👴", headline: "介護保険サービスの種類と自己負担額の計算方法", source: "東洋経済"),
            .init(icon: "📰", headline: "要介護認定の申請方法とスムーズに通るためのコツ", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "40歳から払う介護保険料と受けられるサービス一覧", source: "Forbes Japan"),
            .init(icon: "📊", headline: "在宅介護vs施設介護のコスト比較と利用できる補助", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "介護保険の高額介護サービス費制度で自己負担を減らす", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "親の介護費用を月3万円に抑えた介護保険活用術", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "介護保険サービスの仕組みと申請方法を解説", channel: "介護制度TV"),
            .init(platformIcon: "▶️", title: "要介護認定の申請手順と審査のポイント", channel: "節約チャンネル"),
            .init(platformIcon: "🎥", title: "在宅介護で使える介護保険サービスの選び方", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "高額介護サービス費の申請で自己負担を減らす方法", channel: "家計TV"),
            .init(platformIcon: "▶️", title: "親の介護費用を介護保険で抑えるための準備", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "介護保険を使って親の施設費用を月3万円に抑えた話", channel: "お金の教室"),
        ]),
        "農業・地方移住支援": .init(avgIncome: nil, news: [
            .init(icon: "🌾", headline: "地方移住支援金100万円の申請条件と対象自治体一覧", source: "東洋経済"),
            .init(icon: "📰", headline: "就農給付金で農業を始めた人の年収と生活実態", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "地方移住して生活費が半分になった都市住民の事例", source: "Forbes Japan"),
            .init(icon: "📊", headline: "地方移住支援金の申請方法と受給するための条件", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "テレワーク移住で東京の仕事を続けながら地方に住む方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "移住支援金と空き家補助で初期費用ゼロで移住した話", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "地方移住支援金の申請方法と対象条件を解説", channel: "移住TV"),
            .init(platformIcon: "▶️", title: "就農給付金で農業を始める方法と実際の収入", channel: "農業チャンネル"),
            .init(platformIcon: "🎥", title: "地方移住で生活費を月10万円下げた実例", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "テレワーク移住で東京の仕事を続ける方法", channel: "移住攻略TV"),
            .init(platformIcon: "▶️", title: "移住支援制度を活用した初期費用ゼロの移住術", channel: "節約攻略TV"),
            .init(platformIcon: "🎥", title: "地方移住で年間200万円を節約した夫婦の話", channel: "お金の教室"),
        ]),
    ]
}

// MARK: - 守る グリッドカード（3列用）
struct ProtectGridCard: View {
    @EnvironmentObject var appState: AppState
    let emoji: String
    let title: String
    let accentColor: Color
    let description: String
    @State private var showDetail = false

    private var hubContent: FukugyouRelatedContent? {
        FukugyouRelatedContent.protectData[title]
    }

    var body: some View {
        Button(action: {
            showDetail = true
            appState.recordCardView(emoji: emoji, title: title, category: .protect)
        }) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 34))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
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
            if let content = hubContent {
                FukugyouHubSheet(
                    emoji: emoji, title: title,
                    description: description, accentColor: accentColor,
                    relatedContent: content
                )
            } else {
                InfoDetailSheet(emoji: emoji, title: title, description: description, accentColor: accentColor)
            }
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
