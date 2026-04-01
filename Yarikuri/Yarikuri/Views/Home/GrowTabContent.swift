import SwiftUI

// MARK: - 増やすタブ コンテンツ
struct GrowTabContent: View {
    @EnvironmentObject var appState: AppState
    @State private var showIncomeTracker = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        LazyVStack(spacing: 16) {
            // ── 収入を記録 ──────────────────
            IncomeQuickCard(showIncomeTracker: $showIncomeTracker)
                .sheet(isPresented: $showIncomeTracker) {
                    IncomeTrackerSheet()
                        .environmentObject(appState)
                }

            // プロフィールに応じた優先カード
            if let fp = appState.userProfile?.financialProfile {
                profileBasedCards(fp: fp)
            } else {
                sectionLabel("はじめての方へ")
                LazyVGrid(columns: columns, spacing: 12) {
                    GrowGridCard(emoji: "😌", title: "投資が怖い理由", tagColor: Color.blue.opacity(0.7),
                        description: "「損しそう」という不安は自然なこと。長期・積立・分散の3原則を守ると、短期的な値動きに左右されにくくなります。まずは知ることから始めましょう。")
                    GrowGridCard(emoji: "💡", title: "1,000円積立の効果", tagColor: AppColor.primary,
                        description: "毎月1,000円を20年間、年利5%で積み立てると約410万円に。元本は240,000円なのに大きく育ちます。少額でも「時間」を味方につけることが大切です。")
                }
            }

            // ── 副業で稼ぐ ──────────────────
            sectionLabel("副業で稼ぐ")
            LazyVGrid(columns: columns, spacing: 12) {
                GrowGridCard(emoji: "🤖", title: "AIで副業収入", tagColor: Color.purple.opacity(0.8),
                    description: "ChatGPTやClaudeを使えばライティング・企画書・翻訳・画像生成など、1人でできる仕事の幅が急拡大。AIを「道具」として使いこなすことで、スキルがなくても月数万円の副収入が現実的になっています。")
                GrowGridCard(emoji: "📱", title: "SNS運用代行", tagColor: Color.pink.opacity(0.8),
                    description: "中小企業・個人経営者のInstagram・X・TikTokの投稿代行は月3〜10万円が相場。自分自身のSNSをある程度育てた実績があれば受注しやすく、完全リモートで完結します。")
                GrowGridCard(emoji: "🎬", title: "動画編集副業", tagColor: Color.red.opacity(0.75),
                    description: "YouTuber・企業動画の編集は1本5,000〜30,000円が相場。CapCutやDaVinci Resolveは無料で使え、独学3ヶ月で受注できるレベルに到達できます。動画市場拡大でニーズは急増中。")
                GrowGridCard(emoji: "💻", title: "プログラミング・Web制作", tagColor: AppColor.primary,
                    description: "DX推進の波でWeb制作・アプリ開発の需要は高まる一方。HTML/CSSだけでも数万円の案件があり、Reactが書ければ月20〜50万円の案件も。クラウドワークスやランサーズで未経験から実績を積めます。")
                GrowGridCard(emoji: "✍️", title: "Webライター・SEO記事", tagColor: Color.orange.opacity(0.85),
                    description: "企業のオウンドメディア向けSEO記事は1文字0.5〜3円が相場。ChatGPTと組み合わせることで執筆速度が2〜3倍に。クラウドワークスで初心者案件から始め、専門性を高めると単価が上がります。")
                GrowGridCard(emoji: "🎓", title: "オンライン家庭教師", tagColor: Color.indigo.opacity(0.8),
                    description: "塾講師経験や得意科目があれば、家庭教師マッチングサービス（まなぶ・スタディコーチ等）で時給1,500〜5,000円で教えられます。Zoomで完結するため移動ゼロ。大学生・社会人問わず始められます。")
                GrowGridCard(emoji: "♻️", title: "せどり・フリマ物販", tagColor: AppColor.secondary,
                    description: "リサイクルショップ・セール品をメルカリ・ラクマで転売するせどり。初期費用3〜5万円で月5〜15万円を狙えます。Keepaなどの価格追跡ツールを使えば仕入れリスクを減らせます。")
                GrowGridCard(emoji: "🚗", title: "ギグワーク・配達", tagColor: Color.orange,
                    description: "Uber Eats・出前館・Wolt等の配達は、スキマ時間に自分のペースで稼げます。自転車でも始められ、週5時間で月1〜2万円。複数サービスに登録し稼働時間を最大化するのがコツです。")
                GrowGridCard(emoji: "📚", title: "noteで知識を売る", tagColor: Color.teal.opacity(0.8),
                    description: "自分の経験・知識・ノウハウをnoteの有料記事やコンテンツとして販売。500〜3,000円/本で、1度書けば繰り返し収入に。転職体験・節約術・料理レシピなど、日常の経験が商品になります。")
                GrowGridCard(emoji: "🌏", title: "翻訳・通訳副業", tagColor: Color.blue.opacity(0.75),
                    description: "英語が得意なら翻訳副業は時給換算で高単価。DeepLを補助に使いながら精度を高める「後編集翻訳（MTPE）」はAI時代の新しい働き方。ランサーズや専門翻訳会社への登録で案件を取得できます。")
                GrowGridCard(emoji: "🏠", title: "スペース貸し・民泊", tagColor: Color.brown.opacity(0.7),
                    description: "使っていない駐車場・空き部屋をakippaやAirbnbで貸し出すと、何もしなくても毎月収入が得られます。特に都市部では駐車場1台で月2〜5万円の収益も。初期費用ほぼゼロで始められます。")
                GrowGridCard(emoji: "📸", title: "ストック素材販売", tagColor: Color.green.opacity(0.75),
                    description: "スマホで撮った写真・AIで生成したイラストをPIXTAやAdobe Stockに登録すると、ダウンロードごとに収入に。一度登録すれば自動で稼いでくれるストック型の不労所得です。")
            }

            // ── キャリア・転職で増やす ──────────────────
            sectionLabel("キャリア・転職で増やす")
            LazyVGrid(columns: columns, spacing: 12) {
                GrowGridCard(emoji: "🏢", title: "転職で年収アップ", tagColor: Color.indigo.opacity(0.85),
                    description: "同じスキルでも会社が変わるだけで年収が100〜200万円アップするケースは珍しくありません。転職エージェントは無料で利用でき、市場価値を確認するだけでもOKです。")
                GrowGridCard(emoji: "🔓", title: "副業OKの会社に転職", tagColor: Color.teal.opacity(0.8),
                    description: "副業禁止の会社から副業解禁している会社に転職するだけで収入の選択肢が広がります。最近は副業推奨の企業も増えており、年収本業＋副収入で大きく変わります。")
                GrowGridCard(emoji: "📚", title: "資格取得で単価アップ", tagColor: Color.orange.opacity(0.85),
                    description: "FP・宅建・簿記・ITパスポートなどの資格は取得すれば昇給・転職・副業のすべてに使えます。まずは自分の仕事に関連する資格を1つ目指してみましょう。")
                GrowGridCard(emoji: "🌐", title: "英語力で収入アップ", tagColor: Color.blue.opacity(0.75),
                    description: "TOEIC700点以上になると転職時の選択肢が大幅に広がり、外資系や商社など高収入の職場も視野に。英語の翻訳・通訳副業も時給が高めです。")
                GrowGridCard(emoji: "💼", title: "個人事業主になる", tagColor: Color.purple.opacity(0.8),
                    description: "副業が軌道に乗ったら個人事業主として開業届を提出。青色申告で最大65万円の控除が受けられ、経費計上で節税できます。開業届は無料で税務署に提出するだけです。")
                GrowGridCard(emoji: "🏗️", title: "法人化を検討する", tagColor: Color.indigo.opacity(0.75),
                    description: "個人事業の収入が年700万円を超えてきたら法人化が節税になるケースが多いです。役員報酬・社会保険・経費の幅が広がり、信用度もアップします。")
            }

            // ── 節税で増やす ──────────────────
            sectionLabel("節税で増やす")
            LazyVGrid(columns: columns, spacing: 12) {
                GrowGridCard(emoji: "🏯", title: "ふるさと納税", tagColor: Color.orange,
                    description: "寄附金額から2,000円を引いた額が税金から控除される制度。物価上昇の今こそ、お米・肉・日用品などの返礼品を最大限活用しましょう。「ワンストップ特例」なら確定申告不要。さとふるやふるなびで上限額を即確認できます。")
                GrowGridCard(emoji: "📋", title: "iDeCoで老後＋節税", tagColor: Color.indigo.opacity(0.8),
                    description: "掛け金が全額所得控除になる強力な節税手段。年収500万円の会社員が月2.3万円掛けると年間約5.5万円の節税効果。2024年の制度改正で拠出限度額も引き上げ。老後対策と節税を同時に達成できます。")
                GrowGridCard(emoji: "🏥", title: "医療費控除を活用", tagColor: Color.red.opacity(0.75),
                    description: "1年間の医療費が世帯で10万円を超えた分を所得控除できます。病院代だけでなく、通院交通費・市販薬・介護費用も対象。家族全員分をまとめて申告でき、所得の低い人が申告すると控除効果が高まります。")
                GrowGridCard(emoji: "📜", title: "年末調整の漏れをなくす", tagColor: Color.teal.opacity(0.8),
                    description: "生命保険料控除・地震保険料控除・住宅ローン控除（2年目以降）は年末調整で申請できます。書類を提出し忘れると数千〜数万円を損することも。10〜11月に届く控除証明書はすぐ保管しましょう。")
                GrowGridCard(emoji: "💼", title: "副業の経費を計上する", tagColor: Color.purple.opacity(0.8),
                    description: "副業収入がある場合、スマホ代・PC代・書籍代・通信費・交通費などを経費として計上できます。副業の利益＝収入−経費で計算され、経費が増えるほど税負担が減ります。青色申告すると最大65万円の特別控除も。")
                GrowGridCard(emoji: "👨‍👩‍👧", title: "配偶者・扶養控除の見直し", tagColor: Color.pink.opacity(0.75),
                    description: "配偶者の年収が103万円以下なら配偶者控除（最大38万円）が使えます。150万円以下でも配偶者特別控除が適用可能。子供や親の扶養に入れているかも確認を。控除を正しく申請するだけで数万円の節税になります。")
                GrowGridCard(emoji: "🏗️", title: "小規模企業共済", tagColor: Color.brown.opacity(0.75),
                    description: "フリーランス・個人事業主が加入できる退職金制度。掛け金が全額所得控除になり、月7万円まで掛けられます。廃業・退職時に共済金を受け取れるため、節税しながら将来の備えにもなります。")
                GrowGridCard(emoji: "🖥️", title: "e-Taxで確定申告", tagColor: Color.blue.opacity(0.75),
                    description: "e-Tax（電子申告）で確定申告すると青色申告の65万円控除が受けられます（紙申告は55万円）。スマホのマイナンバーカード＋国税庁の確定申告作成コーナーで手続きが完結。還付金も早く戻ってきます。")
                GrowGridCard(emoji: "💊", title: "セルフメディケーション税制", tagColor: Color.green.opacity(0.8),
                    description: "市販の対象スイッチOTC薬の購入費が年1.2万円を超えた分（最大8.8万円）を控除できます。通常の医療費控除との選択適用。レシートと購入明細を保管しておけば、翌年の確定申告で申請できます。")
                GrowGridCard(emoji: "🏠", title: "住宅ローン控除", tagColor: Color.orange.opacity(0.85),
                    description: "住宅ローン残高の0.7%が最長13年間、税金から控除される制度。新築・中古・リフォームも対象。入居初年度は確定申告が必要ですが、2年目以降は年末調整で完結。子育て世帯向けの特例措置も2025年まで延長中。")
                GrowGridCard(emoji: "🎁", title: "特定支出控除", tagColor: Color.indigo.opacity(0.75),
                    description: "資格取得費・研修費・転勤に伴う引越し代・職場への交通費など、給与所得者が仕事で支出した費用が一定額を超えると確定申告で控除できます。会社員には意外と知られていない節税手段です。")
            }

            // ── NISAで始める ──────────────────
            sectionLabel("NISAで始める")
            LazyVGrid(columns: columns, spacing: 12) {
                GrowGridCard(emoji: "🌱", title: "新NISAの基本", tagColor: Color.green.opacity(0.8),
                    description: "2024年から始まった新NISAは非課税期間が無期限・年間360万円まで投資可能になった大幅パワーアップ版。運用益・売却益に税金がかかりません。SBI証券・楽天証券で最短5分で口座開設できます。")
                GrowGridCard(emoji: "🔥", title: "インフレから資産を守る", tagColor: Color.red.opacity(0.75),
                    description: "物価上昇が続く日本で現金のまま持つと実質的に資産が目減りします。年3%のインフレが続くと10年で100万円の価値が約74万円に。株式投資はインフレに連動して価格が上がるため、資産防衛の手段として有効です。")
                GrowGridCard(emoji: "💴", title: "円安対策・外貨資産", tagColor: Color.orange.opacity(0.85),
                    description: "円安が続く局面では、円だけで資産を持つとドル建てで見た資産価値が下がります。全世界株・S&P500インデックスは外貨建て資産を含むため、自然と為替リスクを分散できます。資産の一部を外貨建てにする意識が重要です。")
                GrowGridCard(emoji: "📈", title: "積立投資枠を使う", tagColor: AppColor.primary,
                    description: "毎月1万円を20年間、年利5%で積み立てると約411万円（元本240万円）に。積立投資枠は年間120万円・月1万円から自動積立できます。暴落しても売らず積み続けることで、平均購入単価を下げる「ドルコスト平均法」が機能します。")
                GrowGridCard(emoji: "🌍", title: "全世界・米国株インデックス", tagColor: Color.blue.opacity(0.75),
                    description: "eMAXIS Slim 全世界株式（オルカン）やS&P500インデックスは、信託報酬0.05〜0.1%台の超低コストで世界中の企業に分散投資できます。30年の実績でS&P500は年率約10%のリターン。長期積立の鉄板です。")
                GrowGridCard(emoji: "💰", title: "高配当株・配当再投資", tagColor: Color.yellow.opacity(0.9),
                    description: "配当利回り3〜5%の高配当株をNISA成長投資枠で購入すると、配当金が非課税で受け取れます。日本の高配当ETF（VYMやHDV）や個別株（三菱UFJ・NTT等）を中心に、配当金を再投資する「複利運用」が長期では強力です。")
                GrowGridCard(emoji: "💹", title: "成長投資枠を活用", tagColor: Color.teal.opacity(0.8),
                    description: "NISA成長投資枠（年間240万円）は個別株・ETF・REITに投資できます。積立投資枠と合わせると年間360万円・生涯1,800万円まで非課税。高配当株や国内ETFをここで購入するのが定番です。")
                GrowGridCard(emoji: "👴", title: "老後2000万円問題", tagColor: Color.purple.opacity(0.8),
                    description: "老後30年で約2,000万円が不足するとされる試算は今も有効で、物価上昇でむしろ必要額は増加傾向です。月3万円を25年間NISAで年率5%運用すると約1,730万円に。早く始めるほど「時間」が最大の味方になります。")
                GrowGridCard(emoji: "🤖", title: "ロボアドバイザー", tagColor: Color.indigo.opacity(0.75),
                    description: "ウェルスナビやTHEOは、リスク許容度を答えるだけで自動で分散投資してくれるサービス。最低1万円から始められ、リバランスも自動。「何を買えばいいかわからない」人に最適な入口です。")
                GrowGridCard(emoji: "🪙", title: "金（ゴールド）で分散", tagColor: Color.yellow.opacity(0.8),
                    description: "株価が下落するとき金は上がる傾向があり、ポートフォリオの安定剤として機能します。SBI証券や楽天証券で金ETFをNISA成長投資枠で購入できます。資産全体の5〜10%程度を金に配分するのが一般的な分散戦略です。")
                GrowGridCard(emoji: "🏘️", title: "REITで不動産投資", tagColor: Color.orange.opacity(0.8),
                    description: "数万円から始められる不動産投資信託（REIT）。物件を直接持たずに不動産収益（分配金）を受け取れます。NISA成長投資枠で購入すれば分配金も非課税。都心のオフィスビルや物流施設に間接投資できます。")
                GrowGridCard(emoji: "🔗", title: "iDeCo×NISAの最適活用", tagColor: Color.green.opacity(0.75),
                    description: "iDeCo（掛け金全額控除）とNISA（運用益非課税）の二刀流が最強の資産形成戦略。会社員なら毎月iDeCo2.3万円＋NISA積立3万円で、年間節税効果と非課税メリットを両取りできます。まず始めることが最優先です。")
            }

            // ── ちりつも作戦 ──────────────────
            sectionLabel("ちりつも作戦")
            LazyVGrid(columns: columns, spacing: 12) {
                GrowGridCard(emoji: "🎁", title: "ポイ活・電子決済", tagColor: AppColor.secondary,
                    description: "日常の支払いをクレジットカードや電子マネーにまとめることで、ポイントが貯まります。年間数万円相当になることも。ただし使いすぎに注意。")
                GrowGridCard(emoji: "🐷", title: "先取り貯蓄", tagColor: AppColor.secondary,
                    description: "給料が入ったら自動で貯蓄口座に移す「先取り貯蓄」。残ったお金で生活する習慣が身につき、自然と貯まっていきます。月3,000円からでも始められます。")
                GrowGridCard(emoji: "📊", title: "高金利口座を探す", tagColor: Color.green.opacity(0.8),
                    description: "メガバンクの普通預金金利は低いですが、ネット銀行や証券会社の現金管理サービスでは年0.1〜0.3%程度の高金利のものもあります。緊急資金の置き場として検討を。")
                GrowGridCard(emoji: "🔄", title: "自動積立を設定", tagColor: AppColor.primary,
                    description: "手動で貯金するより「自動積立」が長続きのコツ。銀行の積立定期や投資信託の自動積立を設定すれば、意識しなくても資産が積み上がっていきます。")
                GrowGridCard(emoji: "📱", title: "格安SIMに変える", tagColor: Color.teal.opacity(0.8),
                    description: "大手キャリアから格安SIMに乗り換えると、月々の通信費が3,000〜6,000円程度安くなることも。年間で3〜7万円の節約になります。通話品質や通信速度を比較してから選びましょう。")
                GrowGridCard(emoji: "💡", title: "節電・節水を習慣に", tagColor: Color.orange.opacity(0.8),
                    description: "こまめな消灯・エアコンの設定温度を1度調整するだけで、月数百〜数千円の光熱費削減に。LED照明への切り替えも初期費用は回収できます。")
                GrowGridCard(emoji: "🍱", title: "お弁当を持参する", tagColor: Color.orange,
                    description: "外食1回800円→弁当200円なら1回600円節約。週3回持参すると月約7,000円の削減に。作り置きおかずを活用すると時間も手間も省けます。")
                GrowGridCard(emoji: "☕", title: "水筒・コーヒーを持参", tagColor: Color.brown.opacity(0.7),
                    description: "コンビニのコーヒー1杯150円を毎日買うと月4,500円。自宅でコーヒーを作って持参すれば月数千円の節約になります。ボトル代はすぐ元が取れます。")
                GrowGridCard(emoji: "🛒", title: "まとめ買いで節約", tagColor: Color.green.opacity(0.8),
                    description: "日用品や食材を特売日にまとめ買いすると単価が下がります。ただし買いすぎて無駄にならないよう、使い切れる量だけ購入するのがコツです。")
                GrowGridCard(emoji: "📚", title: "図書館を活用する", tagColor: Color.indigo.opacity(0.7),
                    description: "本・雑誌・DVDを無料で借りられる図書館は最強の節約術。電子図書館サービスを使えばスマホで読むことも。年間数万円の書籍代が浮きます。")
                GrowGridCard(emoji: "🏦", title: "ATM手数料をゼロに", tagColor: AppColor.primary,
                    description: "コンビニATMの手数料110〜220円は積み重なると大きな出費。ネット銀行のキャッシュカードや、手数料無料のATMを使う習慣をつけましょう。")
                GrowGridCard(emoji: "🏋️", title: "ジムをやめて自宅トレ", tagColor: Color.teal.opacity(0.75),
                    description: "月7,000〜10,000円のジム代もバカになりません。YouTube筋トレ動画＋ダンベル1セットで自宅でも十分な筋トレができます。年間8〜12万円の節約に。")
            }
        }
    }

    @ViewBuilder
    private func profileBasedCards(fp: UserFinancialProfile) -> some View {
        sectionLabel("あなたへのアドバイス")
        LazyVGrid(columns: columns, spacing: 12) {
            if fp.growReadiness < 0.4 {
                GrowGridCard(emoji: "🛡️", title: "まず土台を整えよう", tagColor: AppColor.secondary,
                    description: "投資を始める前に、生活防衛資金（3か月分）と高金利の借入返済を優先すると長期的に安心です。土台が整ってから投資を検討しましょう。")
            }
            if fp.investmentConfidence < 0.35 {
                GrowGridCard(emoji: "😌", title: "投資が怖い理由", tagColor: Color.blue.opacity(0.7),
                    description: "「損しそう」という不安は自然なこと。長期・積立・分散の3原則を守ると、短期的な値動きに左右されにくくなります。まずは知ることから始めましょう。")
                GrowGridCard(emoji: "💡", title: "1,000円積立の効果", tagColor: AppColor.primary,
                    description: "毎月1,000円を20年間、年利5%で積み立てると約410万円に。元本は240,000円なのに大きく育ちます。少額でも「時間」を味方につけることが大切です。")
            } else if fp.investmentConfidence < 0.65 {
                GrowGridCard(emoji: "🔄", title: "積立を続けるコツ", tagColor: Color.orange.opacity(0.9),
                    description: "相場が下がっても焦らず続けることが重要。「ドルコスト平均法」では、下がった時に多く買えるため長期的にはプラスになりやすいです。")
            } else {
                GrowGridCard(emoji: "📊", title: "ポートフォリオ見直し", tagColor: AppColor.primary,
                    description: "年に1〜2回、資産配分（株・債券・現金の比率）を確認してリバランスしましょう。相場の変化で意図せず偏りが生じることがあります。")
                GrowGridCard(emoji: "🌍", title: "分散投資を深める", tagColor: Color.indigo.opacity(0.8),
                    description: "国内・海外、株・債券・REITなど複数の資産クラスに分散することで、一つの下落に左右されにくくなります。")
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

// MARK: - 収入クイックカード
struct IncomeQuickCard: View {
    @EnvironmentObject var appState: AppState
    @Binding var showIncomeTracker: Bool

    private var latestRecord: IncomeRecord? {
        appState.incomeHistory.sorted {
            if $0.year != $1.year { return $0.year > $1.year }
            return $0.month > $1.month
        }.first
    }

    private var monthlyAverage: Int? {
        guard !appState.incomeHistory.isEmpty else { return nil }
        return appState.incomeHistory.reduce(0) { $0 + $1.amount } / appState.incomeHistory.count
    }

    var body: some View {
        Button(action: { showIncomeTracker = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Text("💴")
                        .font(.system(size: 28))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("収入を記録")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColor.textPrimary)
                    if let latest = latestRecord {
                        Text("\(latest.displayLabel): ¥\(latest.amount / 10000)万円")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textSecondary)
                    } else {
                        Text("収入を入力してグラフで確認")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textTertiary)
                    }
                }

                Spacer()

                if let avg = monthlyAverage {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("月平均")
                            .font(.system(size: 10))
                            .foregroundColor(AppColor.textTertiary)
                        Text("¥\(avg / 10000)万")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color.green)
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColor.textTertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppColor.cardBackground)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.green.opacity(0.3), lineWidth: 1.2))
            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - 増やす グリッドカード（3列用）
struct GrowGridCard: View {
    @EnvironmentObject var appState: AppState
    let emoji: String
    let title: String
    let tagColor: Color
    let description: String
    @State private var showDetail = false

    private var hubContent: FukugyouRelatedContent? {
        FukugyouRelatedContent.data[title]
    }

    var body: some View {
        Button(action: {
            showDetail = true
            appState.recordCardView(emoji: emoji, title: title, category: .grow)
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
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(tagColor.opacity(0.25), lineWidth: 1.2))
            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        }
        .sheet(isPresented: $showDetail) {
            if let content = hubContent {
                FukugyouHubSheet(
                    emoji: emoji, title: title,
                    description: description, accentColor: tagColor,
                    relatedContent: content
                )
            } else {
                InfoDetailSheet(emoji: emoji, title: title, description: description, accentColor: tagColor)
            }
        }
    }
}

// MARK: - 増やす フル幅カード（パーソナライズ用）
struct GrowInfoCard: View {
    @EnvironmentObject var appState: AppState
    let emoji: String
    let title: String
    let tag: String
    let tagColor: Color
    let description: String
    @State private var showDetail = false

    var body: some View {
        Button(action: {
            showDetail = true
            appState.recordCardView(emoji: emoji, title: title, category: .grow)
        }) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 38))
                    .frame(width: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColor.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(tag)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(tagColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(tagColor.opacity(0.1))
                        .cornerRadius(6)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColor.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppColor.cardBackground)
            .cornerRadius(16)
            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        }
        .sheet(isPresented: $showDetail) {
            InfoDetailSheet(emoji: emoji, title: title, description: description, accentColor: tagColor)
        }
    }
}

// MARK: - 副業情報ハブ データ
struct FukugyouRelatedContent {
    struct NewsItem: Identifiable {
        let id = UUID()
        let icon: String
        let headline: String
        let source: String
    }
    struct VideoItem: Identifiable {
        let id = UUID()
        let platformIcon: String
        let title: String
        let channel: String
    }
    var avgIncome: String?
    var news: [NewsItem]
    var videos: [VideoItem]

    static let data: [String: FukugyouRelatedContent] = [
        "AIで副業収入": .init(avgIncome: "月2〜8万円", news: [
            .init(icon: "🤖", headline: "ChatGPT副業で月10万円稼ぐ方法2024年版", source: "ビジネスインサイダー"),
            .init(icon: "📰", headline: "AI副業ランキング｜初心者でも始めやすい5選", source: "東洋経済オンライン"),
            .init(icon: "💡", headline: "副業でAIライティングを始める手順を解説", source: "Forbes Japan"),
            .init(icon: "🧠", headline: "生成AIで副業収入を得る最短ルートとは", source: "日経ビジネス"),
            .init(icon: "💰", headline: "AIプロンプト販売で月3万円を稼ぐ人が増加", source: "東洋経済"),
            .init(icon: "📊", headline: "AI副業の落とし穴と正しい稼ぎ方ガイド", source: "ダイヤモンドオンライン"),
        ], videos: [
            .init(platformIcon: "🎬", title: "ChatGPTで副業月5万円を達成した方法", channel: "副業チャンネル"),
            .init(platformIcon: "▶️", title: "AI副業入門｜初日から稼ぐためのロードマップ", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "ChatGPT×副業のリアルな収入を公開します", channel: "副業攻略TV"),
            .init(platformIcon: "🎬", title: "AIツール5選で副業効率を3倍にする方法", channel: "AI副業ラボ"),
            .init(platformIcon: "▶️", title: "プロンプトエンジニアリングで稼ぐ全手順", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎥", title: "【2024年最新】AI副業で月20万円の実態", channel: "副業TV"),
        ]),
        "SNS運用代行": .init(avgIncome: "月3〜10万円", news: [
            .init(icon: "📱", headline: "SNS代行市場が急拡大｜2024年の相場と始め方", source: "ダイヤモンドオンライン"),
            .init(icon: "📰", headline: "Instagram運用代行で月8万円稼ぐ主婦の話", source: "AERA dot."),
            .init(icon: "💼", headline: "SNS副業の単価相場と契約の取り方まとめ", source: "ランサーズブログ"),
            .init(icon: "📊", headline: "X（旧Twitter）代行で月5万円を稼ぐ方法", source: "Forbes Japan"),
            .init(icon: "🎯", headline: "SNS運用代行の初案件を取るポートフォリオ術", source: "東洋経済"),
            .init(icon: "💡", headline: "TikTok代行が熱い｜2024年の新相場と実態", source: "ビジネスインサイダー"),
        ], videos: [
            .init(platformIcon: "🎬", title: "SNS運用代行の始め方と実際の収入を公開", channel: "副業チャンネル"),
            .init(platformIcon: "▶️", title: "Instagram代行で月10万円稼ぐ方法", channel: "フリーランス道"),
            .init(platformIcon: "🎥", title: "【未経験OK】SNS副業の全手順を解説", channel: "お金の学校"),
            .init(platformIcon: "🎬", title: "TikTok代行副業の単価と案件の取り方", channel: "SNS副業チャンネル"),
            .init(platformIcon: "▶️", title: "SNS運用代行の契約書と料金設定のコツ", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "X代行副業で月6万円稼ぐロードマップ", channel: "稼ぐ力チャンネル"),
        ]),
        "動画編集副業": .init(avgIncome: "月3〜15万円", news: [
            .init(icon: "🎬", headline: "動画編集副業｜未経験から3ヶ月で月5万円の実例", source: "東洋経済"),
            .init(icon: "📰", headline: "CapCutで動画編集副業を始める完全ガイド", source: "ビジネスインサイダー"),
            .init(icon: "💻", headline: "2024年版｜動画編集案件の相場と取り方", source: "クラウドワークスブログ"),
            .init(icon: "🎯", headline: "Premiere Pro vs CapCut｜副業に使えるのはどっち", source: "Forbes Japan"),
            .init(icon: "📊", headline: "動画編集者の需要が過去最高｜案件倍増の背景", source: "日経ビジネス"),
            .init(icon: "💰", headline: "ショート動画編集特化で月収15万円の実態", source: "ダイヤモンドオンライン"),
        ], videos: [
            .init(platformIcon: "🎬", title: "動画編集副業の始め方【月収公開あり】", channel: "副業TV"),
            .init(platformIcon: "▶️", title: "CapCut完全入門｜0から副業で稼ぐ方法", channel: "動画編集塾"),
            .init(platformIcon: "🎥", title: "動画編集で稼ぐためのポートフォリオ作成法", channel: "フリーランス道"),
            .init(platformIcon: "🎬", title: "Premiere Pro入門から副業受注まで最速ルート", channel: "動画副業チャンネル"),
            .init(platformIcon: "▶️", title: "ショート動画編集で案件を量産する仕組み", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "動画編集単価を2倍にする交渉術とスキルアップ", channel: "稼ぐ力チャンネル"),
        ]),
        "プログラミング・Web制作": .init(avgIncome: "月5〜30万円", news: [
            .init(icon: "💻", headline: "未経験から6ヶ月でWeb制作月20万円達成の方法", source: "Forbes Japan"),
            .init(icon: "📰", headline: "2024年版｜プログラミング副業の需要と単価まとめ", source: "日経ビジネス"),
            .init(icon: "🌐", headline: "ランサーズ・クラウドワークスでWeb案件を取る方法", source: "ランサーズブログ"),
            .init(icon: "🔧", headline: "WordPress案件で安定収入｜月10万円の設計図", source: "東洋経済"),
            .init(icon: "📊", headline: "ノーコードWeb制作が急増｜Webflow副業の実態", source: "ダイヤモンドオンライン"),
            .init(icon: "🚀", headline: "Next.js案件で月30万円フリーランスになった体験", source: "ビジネスインサイダー"),
        ], videos: [
            .init(platformIcon: "🎬", title: "未経験からWeb制作副業で月10万円稼ぐロードマップ", channel: "プログラミング道"),
            .init(platformIcon: "▶️", title: "HTMLとCSSだけで受注できる案件の探し方", channel: "Web制作チャンネル"),
            .init(platformIcon: "🎥", title: "ReactでフリーランスWeb開発者になる方法", channel: "コーディング学院"),
            .init(platformIcon: "🎬", title: "WordPressで副業月10万円を達成する全手順", channel: "Web副業TV"),
            .init(platformIcon: "▶️", title: "ノーコードWebflow副業の始め方と単価設定", channel: "副業チャンネル"),
            .init(platformIcon: "🎥", title: "プログラミング副業で最初の案件を取る方法", channel: "稼ぐ力チャンネル"),
        ]),
        "Webライター・SEO記事": .init(avgIncome: "月2〜10万円", news: [
            .init(icon: "✍️", headline: "AIと併用でWebライター月収2倍｜実例レポート", source: "ダイヤモンドオンライン"),
            .init(icon: "📰", headline: "SEOライティング副業の単価相場2024年版", source: "東洋経済"),
            .init(icon: "💡", headline: "初心者Webライターが最初の案件を取る方法", source: "クラウドワークスブログ"),
            .init(icon: "🔍", headline: "SEO記事の単価が上昇｜専門ライターに需要集中", source: "Forbes Japan"),
            .init(icon: "📊", headline: "Webライター×ChatGPTで生産性5倍の実例", source: "日経ビジネス"),
            .init(icon: "💼", headline: "医療・法律・金融ジャンルの高単価ライター事情", source: "ビジネスインサイダー"),
        ], videos: [
            .init(platformIcon: "🎬", title: "Webライター副業の始め方【月5万円の実績公開】", channel: "副業チャンネル"),
            .init(platformIcon: "▶️", title: "ChatGPTでライティング速度を3倍にする方法", channel: "AIライティング塾"),
            .init(platformIcon: "🎥", title: "SEO記事で月10万円を目指すロードマップ", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "Webライター単価を文字1円→3円にした交渉術", channel: "ライター副業TV"),
            .init(platformIcon: "▶️", title: "SEOキーワード選定から記事作成の全工程解説", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "専門ライターになって月収10万円を超えた方法", channel: "副業攻略TV"),
        ]),
        "オンライン家庭教師": .init(avgIncome: "月2〜8万円", news: [
            .init(icon: "🎓", headline: "オンライン家庭教師の相場と稼ぎ方2024年版", source: "Biz/Zine"),
            .init(icon: "📰", headline: "「まなぶ」で時給3,000円を達成した体験談", source: "AERA dot."),
            .init(icon: "📚", headline: "副業家庭教師で月6万円稼ぐ大学生の話", source: "ダイヤモンド"),
            .init(icon: "🌐", headline: "英語オンライン教師で外国人生徒を獲得する方法", source: "Forbes Japan"),
            .init(icon: "💡", headline: "プログラミング家庭教師の需要が急増中", source: "東洋経済"),
            .init(icon: "📊", headline: "オンライン教育市場2兆円超え｜個人教師の機会", source: "日経ビジネス"),
        ], videos: [
            .init(platformIcon: "🎬", title: "オンライン家庭教師で稼ぐ方法｜登録から収入まで", channel: "副業TV"),
            .init(platformIcon: "▶️", title: "まなぶ・スタサプ講師の実態と収入を公開", channel: "教育副業チャンネル"),
            .init(platformIcon: "🎥", title: "Zoomで完結！オンライン家庭教師の始め方", channel: "お金の学校"),
            .init(platformIcon: "🎬", title: "英語家庭教師で時給5,000円を達成した方法", channel: "英語副業チャンネル"),
            .init(platformIcon: "▶️", title: "プログラミング教師副業の始め方と単価設定", channel: "副業チャンネル"),
            .init(platformIcon: "🎥", title: "オンライン教師の生徒獲得SNS戦略まとめ", channel: "稼ぐ力チャンネル"),
        ]),
        "せどり・フリマ物販": .init(avgIncome: "月3〜15万円", news: [
            .init(icon: "♻️", headline: "メルカリせどりで月10万円｜2024年の戦略", source: "東洋経済"),
            .init(icon: "📰", headline: "Keepaを使ったAmazon転売の仕入れ術", source: "ビジネスインサイダー"),
            .init(icon: "🛒", headline: "フリマアプリ最新動向｜売れる商品カテゴリー", source: "日経MJ"),
            .init(icon: "📦", headline: "Amazon FBAせどりで月15万円を達成する仕組み", source: "Forbes Japan"),
            .init(icon: "💰", headline: "ヤフオク×メルカリ裁定取引で稼ぐ方法2024", source: "ダイヤモンドオンライン"),
            .init(icon: "🏷️", headline: "古着転売で月8万円｜仕入れ先と販売先の全て", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "せどり副業で月10万円稼ぐリアルな方法", channel: "物販チャンネル"),
            .init(platformIcon: "▶️", title: "メルカリせどり完全攻略ガイド2024", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "Keepaの使い方と稼げる商品の見つけ方", channel: "Amazon物販塾"),
            .init(platformIcon: "🎬", title: "FBAせどりで月15万円を達成した全手順", channel: "せどり副業TV"),
            .init(platformIcon: "▶️", title: "古着転売ビジネスの始め方と仕入れ先一覧", channel: "副業チャンネル"),
            .init(platformIcon: "🎥", title: "ヤフオク転売で稼ぐリサーチ術を完全公開", channel: "物販副業ラボ"),
        ]),
        "ギグワーク・配達": .init(avgIncome: "月1〜5万円", news: [
            .init(icon: "🚗", headline: "Uber Eats×出前館ダブル登録で収入アップ術", source: "ビジネスインサイダー"),
            .init(icon: "📰", headline: "配達副業で稼ぐ時間帯と場所の選び方", source: "東洋経済"),
            .init(icon: "🚴", headline: "自転車で月3万円｜フードデリバリー副業の実態", source: "日経"),
            .init(icon: "⚡", headline: "電動自転車でデリバリー効率2倍｜機材投資の回収期間", source: "Forbes Japan"),
            .init(icon: "🗺️", headline: "稼げるエリアはどこ？配達副業の地域別データ", source: "ダイヤモンドオンライン"),
            .init(icon: "💰", headline: "配達×シェアリングの掛け持ちで月5万円を達成", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "Uber Eats副業の月収公開｜効率的な稼ぎ方", channel: "副業チャンネル"),
            .init(platformIcon: "▶️", title: "フードデリバリー複数登録で収入を最大化", channel: "ギグワーク攻略"),
            .init(platformIcon: "🎥", title: "配達副業で時給2,000円を達成する方法", channel: "副業TV"),
            .init(platformIcon: "🎬", title: "電動自転車投資で配達副業の効率を倍増させた", channel: "デリバリー副業ラボ"),
            .init(platformIcon: "▶️", title: "Uber×出前館×menu 3社かけ持ち戦略", channel: "ギグワーク研究所"),
            .init(platformIcon: "🎥", title: "配達副業の稼げるエリア・時間帯を徹底解説", channel: "副業攻略TV"),
        ]),
        "noteで知識を売る": .init(avgIncome: "月5,000〜5万円", news: [
            .init(icon: "📚", headline: "note有料記事で月10万円稼ぐクリエイターの話", source: "Forbes Japan"),
            .init(icon: "📰", headline: "2024年版｜noteで売れるコンテンツの作り方", source: "東洋経済"),
            .init(icon: "💡", headline: "日常の経験を売る｜note副業の始め方完全版", source: "ダイヤモンド"),
            .init(icon: "🎯", headline: "noteメンバーシップで安定収入を得る仕組み", source: "ビジネスインサイダー"),
            .init(icon: "📊", headline: "note売上公開｜月3万円を突破した記事の分析", source: "AERA dot."),
            .init(icon: "✍️", headline: "自己紹介記事の書き方でフォロワーが10倍に", source: "日経ビジネス"),
        ], videos: [
            .init(platformIcon: "🎬", title: "noteで月5万円稼ぐ有料記事の作り方", channel: "コンテンツ副業TV"),
            .init(platformIcon: "▶️", title: "何を売ればいい？noteで売れるネタの見つけ方", channel: "副業チャンネル"),
            .init(platformIcon: "🎥", title: "note副業で月10万円を達成するロードマップ", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "noteメンバーシップで月額収入を作る全手順", channel: "副業TV"),
            .init(platformIcon: "▶️", title: "noteを伸ばすSNS連携戦略と収益化の仕組み", channel: "コンテンツ戦略塾"),
            .init(platformIcon: "🎥", title: "有料note 3万円突破までの全過程を公開", channel: "お金の教室"),
        ]),
        "翻訳・英語副業": .init(avgIncome: "月3〜12万円", news: [
            .init(icon: "🌏", headline: "AI翻訳と組み合わせた後編集翻訳(MTPE)の需要急増", source: "日経"),
            .init(icon: "📰", headline: "英語翻訳副業の単価相場と案件の取り方2024", source: "ビジネスインサイダー"),
            .init(icon: "💼", headline: "TOEIC700点から翻訳副業で月8万円の事例", source: "Forbes Japan"),
            .init(icon: "🤖", headline: "DeepLポスト・エディティングで翻訳効率を5倍に", source: "東洋経済"),
            .init(icon: "📊", headline: "技術翻訳の単価が急騰｜IT・医療分野の需要", source: "ダイヤモンドオンライン"),
            .init(icon: "🌐", headline: "英語コーチング副業で時給5,000円を達成した方法", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "翻訳副業の始め方と実際の収入を公開", channel: "副業チャンネル"),
            .init(platformIcon: "▶️", title: "DeepL活用で翻訳速度3倍！副業に使える技", channel: "英語副業TV"),
            .init(platformIcon: "🎥", title: "ランサーズで翻訳案件を取るプロフィール作成術", channel: "フリーランス道"),
            .init(platformIcon: "🎬", title: "TOEIC700点からの翻訳副業スタートガイド", channel: "英語稼ぐ道"),
            .init(platformIcon: "▶️", title: "AI翻訳ポスト・エディティングで稼ぐ全手順", channel: "翻訳副業ラボ"),
            .init(platformIcon: "🎥", title: "英語コーチングで副業月10万円を達成した方法", channel: "副業攻略TV"),
        ]),
        "スペース貸し・民泊": .init(avgIncome: "月2〜10万円", news: [
            .init(icon: "🏠", headline: "空き部屋Airbnb活用で月8万円｜2024年の法規制も解説", source: "東洋経済"),
            .init(icon: "📰", headline: "akippaで駐車場を月3万円で貸し出す方法", source: "ダイヤモンド"),
            .init(icon: "🌆", headline: "民泊副業の始め方と収益シミュレーション", source: "Forbes Japan"),
            .init(icon: "🔑", headline: "民泊新法改正で追い風｜個人民泊の始め方2024", source: "ビジネスインサイダー"),
            .init(icon: "🚗", headline: "月極駐車場より高収入｜時間貸し駐車場副業の実態", source: "AERA dot."),
            .init(icon: "📊", headline: "インバウンド回復で民泊収入が過去最高水準に", source: "日経MJ"),
        ], videos: [
            .init(platformIcon: "🎬", title: "Airbnb民泊副業で月10万円を稼ぐ方法", channel: "不動産副業TV"),
            .init(platformIcon: "▶️", title: "akippa駐車場シェアの登録から収入まで", channel: "シェアリング副業"),
            .init(platformIcon: "🎥", title: "空き部屋を貸して副業収入を得る全手順", channel: "副業チャンネル"),
            .init(platformIcon: "🎬", title: "民泊新法対応の個人民泊登録完全ガイド", channel: "民泊副業ラボ"),
            .init(platformIcon: "▶️", title: "時間貸し駐車場で月3万円稼ぐ設定と運用方法", channel: "資産副業TV"),
            .init(platformIcon: "🎥", title: "Airbnb評価を上げてリピーターを増やす戦略", channel: "副業攻略TV"),
        ]),
        "ストック素材販売": .init(avgIncome: "月3,000〜5万円", news: [
            .init(icon: "📸", headline: "AI生成画像でストック販売月5万円の実例", source: "ビジネスインサイダー"),
            .init(icon: "📰", headline: "PIXTA・Shutterstock比較｜稼げるのはどっち？", source: "東洋経済"),
            .init(icon: "🎨", headline: "スマホ写真を売る副業｜月1万円を目指す方法", source: "Forbes Japan"),
            .init(icon: "🤖", headline: "Midjourney画像でストック収入を得る方法と注意点", source: "ダイヤモンドオンライン"),
            .init(icon: "🎵", headline: "BGM素材販売で不労所得｜音楽ストックの始め方", source: "日経ビジネス"),
            .init(icon: "📊", headline: "ストック素材の売れ筋トレンド2024年版まとめ", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "ストック写真で月10万円稼ぐ方法と実績公開", channel: "副業TV"),
            .init(platformIcon: "▶️", title: "AI画像生成でストック販売する方法2024", channel: "AI副業チャンネル"),
            .init(platformIcon: "🎥", title: "PIXTA登録からの稼ぎ方完全ガイド", channel: "クリエイター副業"),
            .init(platformIcon: "🎬", title: "Shutterstockで月3万円を達成するまでの戦略", channel: "ストック素材ラボ"),
            .init(platformIcon: "▶️", title: "AI画像でストック素材を量産する全手順", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "BGMストック販売で不労所得を作る方法", channel: "副業チャンネル"),
        ]),
        "ハンドメイド・Minne販売": .init(avgIncome: "月1〜10万円", news: [
            .init(icon: "🎨", headline: "Minne月10万円クリエイターが語る差別化戦略", source: "東洋経済"),
            .init(icon: "📰", headline: "デジタルデータ販売が急増｜在庫ゼロで稼ぐ方法", source: "AERA dot."),
            .init(icon: "✂️", headline: "ハンドメイド副業を軌道に乗せるSNS活用術", source: "Forbes Japan"),
            .init(icon: "💡", headline: "Minneよりメルカリ？ハンドメイド販売先の比較", source: "ダイヤモンドオンライン"),
            .init(icon: "📦", headline: "ハンドメイドのデジタルデータ化で収入を自動化", source: "ビジネスインサイダー"),
            .init(icon: "🌸", headline: "季節商品で稼ぐハンドメイドカレンダー戦略", source: "日経MJ"),
        ], videos: [
            .init(platformIcon: "🎬", title: "Minne副業で月5万円を達成するまでの道のり", channel: "ハンドメイド副業TV"),
            .init(platformIcon: "▶️", title: "デジタルデータ販売｜作って継続収入を得る方法", channel: "クリエイター副業"),
            .init(platformIcon: "🎥", title: "Creema・Minneの違いと稼ぎやすいのはどっち？", channel: "副業チャンネル"),
            .init(platformIcon: "🎬", title: "ハンドメイド副業のSNS集客で売上3倍にした方法", channel: "ハンドメイドラボ"),
            .init(platformIcon: "▶️", title: "デジタルデータ販売で月3万円の不労所得を作る", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "Minne出品ページの作り方｜売れる写真と説明文", channel: "稼ぐ力チャンネル"),
        ]),
        "YouTube・ショート動画": .init(avgIncome: "月1〜20万円", news: [
            .init(icon: "🎥", headline: "YouTubeショート収益化の最新アルゴリズム解説", source: "Forbes Japan"),
            .init(icon: "📰", headline: "TikTok副業で月5万円達成｜伸びる動画の法則", source: "東洋経済"),
            .init(icon: "💡", headline: "Reels×TikTok×YT Shorts同時運用で効率化", source: "ビジネスインサイダー"),
            .init(icon: "📊", headline: "YouTubeチャンネル収益化達成までの最短ルート", source: "ダイヤモンドオンライン"),
            .init(icon: "🚀", headline: "顔出しなしYouTubeで月10万円稼ぐ人が続出", source: "AERA dot."),
            .init(icon: "🤖", headline: "AI音声×自動編集でショート動画を量産する方法", source: "日経ビジネス"),
        ], videos: [
            .init(platformIcon: "🎬", title: "YouTubeで副業月10万円を達成する全手順", channel: "YouTube攻略TV"),
            .init(platformIcon: "▶️", title: "TikTok副業の始め方と収益化の仕組み", channel: "ショート動画塾"),
            .init(platformIcon: "🎥", title: "Reelsで伸びる動画の作り方【完全解説】", channel: "SNS副業チャンネル"),
            .init(platformIcon: "🎬", title: "顔出しなしYouTubeで月収10万円を達成した方法", channel: "副業TV"),
            .init(platformIcon: "▶️", title: "ショート動画3媒体同時運用で効率最大化", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "AI自動化でYouTube副業を半自動にする仕組み", channel: "AI副業ラボ"),
        ]),

        // ── キャリア・転職 ──
        "転職で年収アップ": .init(avgIncome: nil, news: [
            .init(icon: "🏢", headline: "転職で年収100万円アップした人の共通点", source: "東洋経済"),
            .init(icon: "📰", headline: "転職エージェント活用術｜無料で市場価値を知る方法", source: "ダイヤモンドオンライン"),
            .init(icon: "💼", headline: "2024年版｜年収アップしやすい業界・職種ランキング", source: "Forbes Japan"),
            .init(icon: "📊", headline: "同職種で年収200万円差が生まれる会社の違い", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "転職成功者の9割が実践した自己分析の方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "30代で年収600万円超えを実現した転職戦略", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "転職で年収アップするための全手順を解説", channel: "転職チャンネル"),
            .init(platformIcon: "▶️", title: "転職エージェント選びの失敗しない方法", channel: "キャリアTV"),
            .init(platformIcon: "🎥", title: "年収交渉で100万円アップさせた実践テクニック", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "スカウト転職で年収1.5倍を実現した体験談", channel: "副業攻略TV"),
            .init(platformIcon: "▶️", title: "転職市場の最新動向｜狙い目の業界と職種", channel: "キャリア研究所"),
            .init(platformIcon: "🎥", title: "職務経歴書の書き方で採用率が2倍になる方法", channel: "就活・転職ラボ"),
        ]),
        "副業OKの会社に転職": .init(avgIncome: nil, news: [
            .init(icon: "🔓", headline: "副業解禁企業が3年で2倍に｜最新動向レポート", source: "日経ビジネス"),
            .init(icon: "📰", headline: "副業推奨の上場企業一覧2024｜探し方と注意点", source: "東洋経済"),
            .init(icon: "💡", headline: "本業＋副業で年収1000万円を達成した人の事例", source: "Forbes Japan"),
            .init(icon: "📊", headline: "副業OK企業への転職で収入が平均35%増加", source: "ダイヤモンドオンライン"),
            .init(icon: "🎯", headline: "求人票で副業可否を見極める方法とチェック項目", source: "ビジネスインサイダー"),
            .init(icon: "💼", headline: "副業解禁で先行くIT企業の社内制度を調査", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "副業OKの会社への転職で収入を増やす方法", channel: "副業転職チャンネル"),
            .init(platformIcon: "▶️", title: "副業推奨企業の探し方｜求人サイト活用術", channel: "キャリアTV"),
            .init(platformIcon: "🎥", title: "本業＋副業で月収100万円を達成した戦略", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "副業解禁企業に転職して変わったこと全部話す", channel: "副業TV"),
            .init(platformIcon: "▶️", title: "面接で副業について正直に話すべきか解説", channel: "転職研究所"),
            .init(platformIcon: "🎥", title: "副業で月20万円稼ぎながら本業転職した体験談", channel: "副業攻略TV"),
        ]),
        "資格取得で単価アップ": .init(avgIncome: nil, news: [
            .init(icon: "📚", headline: "取るだけで年収アップする資格ランキング2024", source: "ダイヤモンドオンライン"),
            .init(icon: "📰", headline: "FP・宅建・簿記の取得が転職市場で有利な理由", source: "東洋経済"),
            .init(icon: "💡", headline: "ITパスポートから始めるIT系資格の取り方", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "社会人の資格取得｜独学3ヶ月で合格する方法", source: "Forbes Japan"),
            .init(icon: "📊", headline: "資格手当の相場｜企業が月給にプラスする金額一覧", source: "ビジネスインサイダー"),
            .init(icon: "🏆", headline: "中小企業診断士で副業月20万円を達成した事例", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "収入アップに直結する資格おすすめ5選を解説", channel: "資格チャンネル"),
            .init(platformIcon: "▶️", title: "FP2級を独学3ヶ月で合格した勉強法", channel: "FP試験攻略"),
            .init(platformIcon: "🎥", title: "簿記2級で年収アップした体験談と勉強法", channel: "資格TV"),
            .init(platformIcon: "🎬", title: "宅建試験の独学合格ロードマップ2024", channel: "宅建チャンネル"),
            .init(platformIcon: "▶️", title: "IT系資格で転職年収アップした全過程を公開", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎥", title: "資格取得でフリーランス単価を月10万円上げた話", channel: "副業攻略TV"),
        ]),
        "英語力で収入アップ": .init(avgIncome: nil, news: [
            .init(icon: "🌐", headline: "TOEIC700点超で選べる求人が4倍に増える理由", source: "Forbes Japan"),
            .init(icon: "📰", headline: "外資系転職で年収200万円アップした実例", source: "東洋経済"),
            .init(icon: "💡", headline: "英語学習を3ヶ月で加速する最新メソッド2024", source: "ダイヤモンドオンライン"),
            .init(icon: "📊", headline: "英語×専門スキルで年収1000万円超えが急増中", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "スタートアップ英語面接で内定を取るコツ", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "英語コーチング副業で時給5,000円を達成した方法", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "英語で収入アップを実現した最短ロードマップ", channel: "英語チャンネル"),
            .init(platformIcon: "▶️", title: "TOEIC800点を3ヶ月で取る勉強法", channel: "TOEIC攻略TV"),
            .init(platformIcon: "🎥", title: "外資転職で年収が2倍になった体験談", channel: "転職チャンネル"),
            .init(platformIcon: "🎬", title: "英語×ITで年収1000万円超えを実現した戦略", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "英語コーチングで副業月15万円を達成した方法", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "日常英会話を30日でマスターするメソッド", channel: "英語学習ラボ"),
        ]),
        "個人事業主になる": .init(avgIncome: nil, news: [
            .init(icon: "💼", headline: "開業届の出し方｜5分で完了する手順を解説", source: "東洋経済"),
            .init(icon: "📰", headline: "青色申告65万円控除のメリットと申請方法", source: "ダイヤモンドオンライン"),
            .init(icon: "📊", headline: "副業から個人事業主になるタイミングの見極め方", source: "Forbes Japan"),
            .init(icon: "💡", headline: "個人事業主が使える経費の全リスト2024年版", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "フリーランス転向で失敗しないためのチェックリスト", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "会社員×個人事業主の二刀流で年収1.5倍の実態", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "個人事業主になる手順｜開業届の書き方完全版", channel: "起業チャンネル"),
            .init(platformIcon: "▶️", title: "青色申告で65万円控除を受ける全手順", channel: "節税TV"),
            .init(platformIcon: "🎥", title: "副業から独立するタイミングと準備すること", channel: "フリーランス道"),
            .init(platformIcon: "🎬", title: "個人事業主の確定申告を自分でやる方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "フリーランス1年目のリアルな収支を公開", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "会社員しながら個人事業主になる注意点", channel: "副業チャンネル"),
        ]),
        "法人化を検討する": .init(avgIncome: nil, news: [
            .init(icon: "🏗️", headline: "個人事業→法人化のタイミング｜税理士が解説", source: "日経ビジネス"),
            .init(icon: "📰", headline: "法人化で節税できる仕組みと具体的な金額", source: "東洋経済"),
            .init(icon: "💡", headline: "合同会社vs株式会社｜フリーランスに向いているのは", source: "Forbes Japan"),
            .init(icon: "📊", headline: "法人化で社会保険料が変わる｜損益分岐点を計算", source: "ダイヤモンドオンライン"),
            .init(icon: "🎯", headline: "マイクロ法人で税負担を最適化した実例", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "法人設立の費用と手続き｜最短1週間で完了する方法", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "法人化するべき年収の目安と税メリットを解説", channel: "節税TV"),
            .init(platformIcon: "▶️", title: "合同会社の設立方法｜費用6万円で始める手順", channel: "起業チャンネル"),
            .init(platformIcon: "🎥", title: "マイクロ法人で社会保険料を最適化する方法", channel: "税金対策チャンネル"),
            .init(platformIcon: "🎬", title: "法人化して年間100万円節税した体験談", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "株式会社vs合同会社｜違いとおすすめはどっち", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "役員報酬の設定と法人節税の基本を完全解説", channel: "フリーランス道"),
        ]),

        // ── 節税 ──
        "ふるさと納税": .init(avgIncome: nil, news: [
            .init(icon: "🏯", headline: "ふるさと納税2024年｜改正後の上限額と注意点", source: "東洋経済"),
            .init(icon: "📰", headline: "ワンストップ特例と確定申告どちらが得？徹底比較", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "コスパ最強の返礼品ランキング2024年版", source: "Forbes Japan"),
            .init(icon: "📊", headline: "年収別ふるさと納税上限額の一覧表", source: "日経ビジネス"),
            .init(icon: "🎁", headline: "日用品返礼品で実質無料生活を実現した主婦の話", source: "AERA dot."),
            .init(icon: "🌾", headline: "お米・肉・魚介｜食費を節約できる返礼品特集", source: "ビジネスインサイダー"),
        ], videos: [
            .init(platformIcon: "🎬", title: "ふるさと納税の始め方と上限額の計算方法", channel: "節税TV"),
            .init(platformIcon: "▶️", title: "ワンストップ特例申請の手順を画面で解説", channel: "税金チャンネル"),
            .init(platformIcon: "🎥", title: "ふるさと納税でお得な返礼品の選び方", channel: "節約チャンネル"),
            .init(platformIcon: "🎬", title: "年収500万円の場合のふるさと納税シミュレーション", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "さとふる・ふるなびの使い方と比較", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "ふるさと納税で年間5万円分の食品を無料で得る方法", channel: "副業攻略TV"),
        ]),
        "iDeCoで老後＋節税": .init(avgIncome: nil, news: [
            .init(icon: "📋", headline: "iDeCo2024年改正｜拠出限度額引き上げの影響", source: "日経ビジネス"),
            .init(icon: "📰", headline: "iDeCoで年間5万円節税した会社員の事例", source: "東洋経済"),
            .init(icon: "💡", headline: "iDeCo×NISAの最適な掛け金バランスを解説", source: "Forbes Japan"),
            .init(icon: "📊", headline: "iDeCoで選ぶべきファンドランキング2024", source: "ダイヤモンドオンライン"),
            .init(icon: "👴", headline: "60歳からiDeCoを受け取る際の税金対策", source: "AERA dot."),
            .init(icon: "🏦", headline: "iDeCoの証券会社比較｜手数料が最安なのはどこ", source: "ビジネスインサイダー"),
        ], videos: [
            .init(platformIcon: "🎬", title: "iDeCo完全解説｜節税効果と始め方を紹介", channel: "節税TV"),
            .init(platformIcon: "▶️", title: "iDeCoの掛け金と受け取り方を徹底解説", channel: "老後対策チャンネル"),
            .init(platformIcon: "🎥", title: "iDeCoで選ぶべきファンドの選び方", channel: "投資チャンネル"),
            .init(platformIcon: "🎬", title: "iDeCo×NISA二刀流で資産形成を最大化する方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "iDeCoの年間節税額シミュレーションを公開", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "SBI証券でiDeCo口座を開設する全手順", channel: "副業攻略TV"),
        ]),
        "医療費控除を活用": .init(avgIncome: nil, news: [
            .init(icon: "🏥", headline: "医療費控除の対象になるもの・ならないもの一覧", source: "東洋経済"),
            .init(icon: "📰", headline: "家族の医療費をまとめて申告する方法と注意点", source: "ダイヤモンドオンライン"),
            .init(icon: "💊", headline: "市販薬が医療費控除の対象になる条件とは", source: "Forbes Japan"),
            .init(icon: "📊", headline: "医療費控除で還付される金額の計算方法", source: "日経ビジネス"),
            .init(icon: "🚗", headline: "通院交通費も対象！医療費控除で見落とされがちな費用", source: "ビジネスインサイダー"),
            .init(icon: "📋", headline: "確定申告で医療費控除を申請する手順を解説", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "医療費控除の申請方法を図解で解説", channel: "節税TV"),
            .init(platformIcon: "▶️", title: "医療費控除で10万円以上還付された事例", channel: "税金チャンネル"),
            .init(platformIcon: "🎥", title: "e-Taxで医療費控除を申請する全手順", channel: "確定申告チャンネル"),
            .init(platformIcon: "🎬", title: "医療費の領収書の管理と集計方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "セルフメディケーション税制との使い分け方", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "家族全員分の医療費をまとめて節税する方法", channel: "副業攻略TV"),
        ]),
        "年末調整の漏れをなくす": .init(avgIncome: nil, news: [
            .init(icon: "📜", headline: "年末調整で見落としやすい控除10項目を解説", source: "東洋経済"),
            .init(icon: "📰", headline: "生命保険料控除証明書の読み方と記入方法", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "年末調整の書類提出期限と遅れたときの対処法", source: "Forbes Japan"),
            .init(icon: "📊", headline: "住宅ローン控除2年目以降の年末調整手続き", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "地震保険料控除を正しく申請して税金を取り戻す", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "年末調整の還付金が少ない理由と対策", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "年末調整の書き方を最初から丁寧に解説", channel: "税金チャンネル"),
            .init(platformIcon: "▶️", title: "見落としがちな控除で還付金を増やす方法", channel: "節税TV"),
            .init(platformIcon: "🎥", title: "生命保険料控除証明書の見方と記入手順", channel: "保険チャンネル"),
            .init(platformIcon: "🎬", title: "住宅ローン控除の年末調整記入方法", channel: "住宅ローンTV"),
            .init(platformIcon: "▶️", title: "年末調整後に追加申告できる費用一覧", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎥", title: "年末調整と確定申告の違いをわかりやすく解説", channel: "お金の教室"),
        ]),
        "副業の経費を計上する": .init(avgIncome: nil, news: [
            .init(icon: "💼", headline: "副業の経費にできるもの全リスト｜スマホ代から書籍まで", source: "東洋経済"),
            .init(icon: "📰", headline: "家事按分の割合設定と証拠の残し方", source: "Forbes Japan"),
            .init(icon: "📊", headline: "副業で使えるクラウド会計ソフト比較2024", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "青色申告で65万円控除を受けるための条件", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "副業収入20万円以下でも確定申告すべきケース", source: "ビジネスインサイダー"),
            .init(icon: "🧾", headline: "領収書のデジタル保存と電子帳簿保存法の対応", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "副業の経費計上で節税する全手順を解説", channel: "節税TV"),
            .init(platformIcon: "▶️", title: "freee・マネーフォワードで経費を管理する方法", channel: "会計チャンネル"),
            .init(platformIcon: "🎥", title: "副業の確定申告を自分でやる方法【初心者向け】", channel: "確定申告チャンネル"),
            .init(platformIcon: "🎬", title: "青色申告で65万円控除を受けるための手順", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "副業収入の税金を最小化する合法的な方法", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "スマホ・PC代の家事按分の正しい計算方法", channel: "お金の教室"),
        ]),
        "副業の経費を計上": .init(avgIncome: nil, news: [
            .init(icon: "💼", headline: "副業の経費にできるもの全リスト｜スマホ代から書籍まで", source: "東洋経済"),
            .init(icon: "📰", headline: "家事按分の割合設定と証拠の残し方", source: "Forbes Japan"),
            .init(icon: "📊", headline: "副業で使えるクラウド会計ソフト比較2024", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "青色申告で65万円控除を受けるための条件", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "副業収入20万円以下でも確定申告すべきケース", source: "ビジネスインサイダー"),
            .init(icon: "🧾", headline: "領収書のデジタル保存と電子帳簿保存法の対応", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "副業の経費計上で節税する全手順を解説", channel: "節税TV"),
            .init(platformIcon: "▶️", title: "freee・マネーフォワードで経費を管理する方法", channel: "会計チャンネル"),
            .init(platformIcon: "🎥", title: "副業の確定申告を自分でやる方法【初心者向け】", channel: "確定申告チャンネル"),
            .init(platformIcon: "🎬", title: "青色申告で65万円控除を受けるための手順", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "副業収入の税金を最小化する合法的な方法", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "スマホ・PC代の家事按分の正しい計算方法", channel: "お金の教室"),
        ]),
        "配偶者・扶養控除の見直し": .init(avgIncome: nil, news: [
            .init(icon: "👨‍👩‍👧", headline: "103万円の壁・150万円の壁をわかりやすく解説", source: "東洋経済"),
            .init(icon: "📰", headline: "配偶者控除と配偶者特別控除の違いと計算方法", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "扶養に入れると節税になる家族の条件一覧", source: "Forbes Japan"),
            .init(icon: "📊", headline: "共働き世帯の扶養控除活用で年間30万円節税", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "2024年の扶養控除改正で変わること・変わらないこと", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "親を扶養に入れて節税する手続きと注意点", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "配偶者控除・扶養控除をわかりやすく解説", channel: "税金チャンネル"),
            .init(platformIcon: "▶️", title: "103万円・150万円の壁と対策を図解で説明", channel: "節税TV"),
            .init(platformIcon: "🎥", title: "親を扶養に入れる手続きと節税効果", channel: "お金の教室"),
            .init(platformIcon: "🎬", title: "共働き夫婦の配偶者控除の申請方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "扶養控除の年末調整での記入方法", channel: "確定申告チャンネル"),
            .init(platformIcon: "🎥", title: "扶養から外れると損するケースを解説", channel: "副業攻略TV"),
        ]),
        "配偶者・扶養控除": .init(avgIncome: nil, news: [
            .init(icon: "👨‍👩‍👧", headline: "103万円の壁・150万円の壁をわかりやすく解説", source: "東洋経済"),
            .init(icon: "📰", headline: "配偶者控除と配偶者特別控除の違いと計算方法", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "扶養に入れると節税になる家族の条件一覧", source: "Forbes Japan"),
            .init(icon: "📊", headline: "共働き世帯の扶養控除活用で年間30万円節税", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "2024年の扶養控除改正で変わること・変わらないこと", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "親を扶養に入れて節税する手続きと注意点", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "配偶者控除・扶養控除をわかりやすく解説", channel: "税金チャンネル"),
            .init(platformIcon: "▶️", title: "103万円・150万円の壁と対策を図解で説明", channel: "節税TV"),
            .init(platformIcon: "🎥", title: "親を扶養に入れる手続きと節税効果", channel: "お金の教室"),
            .init(platformIcon: "🎬", title: "共働き夫婦の配偶者控除の申請方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "扶養控除の年末調整での記入方法", channel: "確定申告チャンネル"),
            .init(platformIcon: "🎥", title: "扶養から外れると損するケースを解説", channel: "副業攻略TV"),
        ]),
        "小規模企業共済": .init(avgIncome: nil, news: [
            .init(icon: "🏗️", headline: "小規模企業共済とは｜フリーランスの退職金制度を解説", source: "日経ビジネス"),
            .init(icon: "📰", headline: "月7万円を満額積んで30年後にいくら受け取れるか", source: "東洋経済"),
            .init(icon: "💡", headline: "小規模企業共済の節税効果シミュレーション", source: "Forbes Japan"),
            .init(icon: "📊", headline: "廃業時・老齢時の受け取り方の違いと税金", source: "ダイヤモンドオンライン"),
            .init(icon: "🎯", headline: "個人事業主の老後対策に小規模共済が最強な理由", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "iDeCoと小規模企業共済の違いと使い分け方", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "小規模企業共済の仕組みと節税効果を解説", channel: "節税TV"),
            .init(platformIcon: "▶️", title: "加入手続きから掛け金設定まで全部説明", channel: "フリーランス道"),
            .init(platformIcon: "🎥", title: "iDeCo×小規模共済の最適な組み合わせ方", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "小規模企業共済で年間84万円を節税した事例", channel: "副業攻略TV"),
            .init(platformIcon: "▶️", title: "受け取り時の税金を最小化する方法", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "フリーランスの老後対策を完全解説", channel: "税金チャンネル"),
        ]),
        "e-Taxで確定申告": .init(avgIncome: nil, news: [
            .init(icon: "🖥️", headline: "e-Tax確定申告の始め方｜マイナンバーカード設定方法", source: "東洋経済"),
            .init(icon: "📰", headline: "スマホだけで完結するe-Tax申告の全手順2024", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "e-Tax申告で65万円控除を受けるための準備", source: "Forbes Japan"),
            .init(icon: "📊", headline: "e-Taxで申告書を提出すると還付が早くなる仕組み", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "確定申告の期限とペナルティ｜遅れた場合の対処法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "初めてでも迷わないe-Tax申告ナビを使った方法", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "e-Taxで確定申告する方法【2024年版完全解説】", channel: "確定申告チャンネル"),
            .init(platformIcon: "▶️", title: "スマホだけで副業の確定申告を済ませる方法", channel: "節税TV"),
            .init(platformIcon: "🎥", title: "マイナンバーカードのe-Tax設定方法", channel: "デジタル行政チャンネル"),
            .init(platformIcon: "🎬", title: "青色申告65万円控除をe-Taxで申請する手順", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "freeeを使ったe-Tax確定申告の全手順", channel: "会計チャンネル"),
            .init(platformIcon: "🎥", title: "確定申告の還付金を早く受け取るコツ", channel: "副業攻略TV"),
        ]),
        "セルフメディケーション税制": .init(avgIncome: nil, news: [
            .init(icon: "💊", headline: "セルフメディケーション税制の対象薬品一覧2024", source: "東洋経済"),
            .init(icon: "📰", headline: "通常の医療費控除との選択適用｜どちらが得か計算", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "対象スイッチOTC医薬品の見分け方（パッケージ確認）", source: "Forbes Japan"),
            .init(icon: "📋", headline: "申請に必要なもの｜レシートの保管期間と注意点", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "花粉症薬・市販の風邪薬が控除対象になる条件", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "セルフメディケーションで年1万円節税した事例", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "セルフメディケーション税制をわかりやすく解説", channel: "節税TV"),
            .init(platformIcon: "▶️", title: "対象薬品の見分け方とレシートの保管方法", channel: "税金チャンネル"),
            .init(platformIcon: "🎥", title: "医療費控除との比較｜どちらで申請するか判断方法", channel: "確定申告チャンネル"),
            .init(platformIcon: "🎬", title: "e-Taxでセルフメディケーション申請する手順", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "ドラッグストアで対象商品を選ぶコツ", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "年間1.2万円超えを達成する節約×節税の方法", channel: "副業攻略TV"),
        ]),
        "住宅ローン控除": .init(avgIncome: nil, news: [
            .init(icon: "🏠", headline: "住宅ローン控除2024年改正後の控除率・期間まとめ", source: "東洋経済"),
            .init(icon: "📰", headline: "子育て世帯・若者向けの住宅ローン控除特例を解説", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "中古住宅でも使える住宅ローン控除の条件", source: "Forbes Japan"),
            .init(icon: "📊", headline: "住宅ローン控除13年間で戻ってくる金額シミュレーション", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "リフォーム・耐震改修でも使える税制優遇措置", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "2年目以降の年末調整での申請手続きを解説", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "住宅ローン控除の仕組みと申請方法を解説", channel: "住宅ローンTV"),
            .init(platformIcon: "▶️", title: "確定申告で住宅ローン控除を初年度申請する方法", channel: "節税TV"),
            .init(platformIcon: "🎥", title: "住宅ローン控除で年間30万円還付された事例", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "子育て世帯の住宅ローン控除特例を活用する方法", channel: "マイホームチャンネル"),
            .init(platformIcon: "▶️", title: "中古住宅購入時の住宅ローン控除手続き", channel: "不動産TV"),
            .init(platformIcon: "🎥", title: "2年目以降の年末調整記入のポイント", channel: "副業攻略TV"),
        ]),
        "特定支出控除": .init(avgIncome: nil, news: [
            .init(icon: "🎁", headline: "給与所得者の特定支出控除｜会社員が使える節税術", source: "東洋経済"),
            .init(icon: "📰", headline: "特定支出控除の対象費用一覧と申請方法2024", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "資格取得費用が特定支出控除の対象になる条件", source: "Forbes Japan"),
            .init(icon: "📊", headline: "転勤費用・単身赴任費用も控除対象になる仕組み", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "特定支出控除で還付を受けた会社員の事例集", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "特定支出控除と確定申告の流れを図解で解説", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "会社員が使える特定支出控除を完全解説", channel: "節税TV"),
            .init(platformIcon: "▶️", title: "特定支出控除の申請に必要な書類と手順", channel: "税金チャンネル"),
            .init(platformIcon: "🎥", title: "資格取得費・研修費で節税する方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "特定支出控除で年間20万円節税した事例", channel: "副業攻略TV"),
            .init(platformIcon: "▶️", title: "e-Taxで特定支出控除を申請する手順", channel: "確定申告チャンネル"),
            .init(platformIcon: "🎥", title: "意外と知られていない会社員の節税術まとめ", channel: "お金の教室"),
        ]),
        "生命保険料控除": .init(avgIncome: nil, news: [
            .init(icon: "🛡️", headline: "生命保険料控除の区分と最大控除額をわかりやすく解説", source: "東洋経済"),
            .init(icon: "📰", headline: "個人年金保険が節税になる仕組みと注意点", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "年末調整での生命保険料控除申請の書き方", source: "Forbes Japan"),
            .init(icon: "📊", headline: "保険を使った節税の限界と投資との比較", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "医療保険・がん保険の控除証明書の読み方", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "生命保険料控除で年間3万円節税する方法", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "生命保険料控除の仕組みと節税効果を解説", channel: "保険チャンネル"),
            .init(platformIcon: "▶️", title: "年末調整で生命保険料控除を申請する書き方", channel: "節税TV"),
            .init(platformIcon: "🎥", title: "控除証明書の見方と年末調整への活用方法", channel: "税金チャンネル"),
            .init(platformIcon: "🎬", title: "個人年金保険の節税効果シミュレーション", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "保険×節税の最適な組み合わせを徹底比較", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "保険を使った節税の落とし穴と対策", channel: "副業攻略TV"),
        ]),

        // ── NISA・投資 ──
        "新NISAの基本": .init(avgIncome: nil, news: [
            .init(icon: "🌱", headline: "新NISA2024年｜旧NISAとの違いと最大活用法", source: "東洋経済"),
            .init(icon: "📰", headline: "SBI証券と楽天証券のNISA比較｜使い勝手の違い", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "新NISAの口座開設からの投資開始手順を解説", source: "Forbes Japan"),
            .init(icon: "📊", headline: "年間360万円・生涯1800万円の非課税枠を最大活用", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "非課税期間無期限のNISAで長期複利運用する方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "新NISAで運用益500万円が非課税になった事例", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "新NISAを完全解説｜仕組みと始め方", channel: "投資チャンネル"),
            .init(platformIcon: "▶️", title: "SBI証券でNISA口座を開設する手順", channel: "資産形成TV"),
            .init(platformIcon: "🎥", title: "新NISAの積立投資枠と成長投資枠の使い分け", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "旧NISAから新NISAへの移行方法と注意点", channel: "NISA攻略"),
            .init(platformIcon: "▶️", title: "新NISAで1800万円の非課税枠を最大活用する方法", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "新NISAを始めるべき年代別の戦略", channel: "副業攻略TV"),
        ]),
        "インフレから資産を守る": .init(avgIncome: nil, news: [
            .init(icon: "🔥", headline: "日本のインフレ率が30年ぶり高水準｜資産への影響", source: "日経ビジネス"),
            .init(icon: "📰", headline: "現金100万円が10年で実質いくらになるか計算した", source: "東洋経済"),
            .init(icon: "💡", headline: "インフレに強い資産クラス比較｜株・不動産・金", source: "Forbes Japan"),
            .init(icon: "📊", headline: "物価上昇に連動する株式投資の仕組みを解説", source: "ダイヤモンドオンライン"),
            .init(icon: "🎯", headline: "インフレ対策に今すぐできる5つのアクション", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "預金だけの人が損している金額を試算してみた", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "インフレから資産を守る投資の基本を解説", channel: "資産形成TV"),
            .init(platformIcon: "▶️", title: "物価上昇でも資産を増やす積立投資の仕組み", channel: "投資チャンネル"),
            .init(platformIcon: "🎥", title: "現金・預金だけだと損する理由をわかりやすく", channel: "お金の教室"),
            .init(platformIcon: "🎬", title: "インフレに強いポートフォリオの作り方", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "日本のインフレ動向と今後の資産運用戦略", channel: "経済チャンネル"),
            .init(platformIcon: "🎥", title: "NISAでインフレ対策をする最短ルート", channel: "副業攻略TV"),
        ]),
        "円安対策・外貨資産": .init(avgIncome: nil, news: [
            .init(icon: "💴", headline: "円安が続く理由と個人投資家が取るべき対策", source: "東洋経済"),
            .init(icon: "📰", headline: "外貨建て資産で円安リスクを分散する方法", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "全世界株・S&P500で自動的に為替分散する仕組み", source: "Forbes Japan"),
            .init(icon: "📊", headline: "円安で損している人と得している人の違い", source: "日経ビジネス"),
            .init(icon: "🌍", headline: "外貨預金vsインデックス投資｜どちらが円安対策に有効", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "米国株投資で円安の恩恵を受けた事例を紹介", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "円安対策の外貨資産投資を初心者向けに解説", channel: "投資チャンネル"),
            .init(platformIcon: "▶️", title: "S&P500で円安リスクを自動ヘッジする方法", channel: "資産形成TV"),
            .init(platformIcon: "🎥", title: "外貨預金と外国株投資の比較と使い分け", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "円安時代の資産配分の最適解を解説", channel: "経済チャンネル"),
            .init(platformIcon: "▶️", title: "全世界株式で自然に為替分散する仕組み", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "円安で資産1000万円が増えた人の投資内容", channel: "副業攻略TV"),
        ]),
        "積立投資枠を使う": .init(avgIncome: nil, news: [
            .init(icon: "📈", headline: "NISA積立投資枠で月3万円を20年続けた結果", source: "東洋経済"),
            .init(icon: "📰", headline: "ドルコスト平均法の効果を図解で解説", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "積立投資枠の対象ファンド一覧と選び方", source: "Forbes Japan"),
            .init(icon: "📊", headline: "年間120万円の積立投資枠を最大活用する方法", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "暴落時に積立を続けるべき理由をデータで証明", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "積立NISAから新NISA積立枠への移行方法", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "NISA積立投資枠の始め方と設定方法", channel: "投資チャンネル"),
            .init(platformIcon: "▶️", title: "ドルコスト平均法で長期積立を続ける方法", channel: "資産形成TV"),
            .init(platformIcon: "🎥", title: "積立投資枠でおすすめのファンド3選を解説", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "月1万円から始める積立NISAの実際の効果", channel: "NISA攻略"),
            .init(platformIcon: "▶️", title: "暴落時に積立を止めない方が良い理由", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "SBI証券で積立設定する方法【画面解説】", channel: "副業攻略TV"),
        ]),
        "全世界・米国株インデックス": .init(avgIncome: nil, news: [
            .init(icon: "🌍", headline: "eMAXIS Slim全世界株式(オルカン)の仕組みと実績", source: "東洋経済"),
            .init(icon: "📰", headline: "S&P500インデックスの30年パフォーマンスを検証", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "オルカンvsS&P500どちらを選ぶべきか徹底比較", source: "Forbes Japan"),
            .init(icon: "📊", headline: "信託報酬0.05%台の超低コストファンドが増加中", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "インデックス投資で月10万円の配当を受け取るには", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "積立20年でS&P500が資産を4倍にした実例", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "全世界株式インデックスの仕組みを解説", channel: "投資チャンネル"),
            .init(platformIcon: "▶️", title: "オルカンとS&P500の違いと選び方", channel: "資産形成TV"),
            .init(platformIcon: "🎥", title: "インデックス投資で10年後に資産が倍になる計算", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "eMAXIS Slimの設定方法と購入手順", channel: "NISA攻略"),
            .init(platformIcon: "▶️", title: "インデックスvsアクティブ投資のリターン比較", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "米国株インデックスの長期積立シミュレーション", channel: "副業攻略TV"),
        ]),
        "高配当株・配当再投資": .init(avgIncome: nil, news: [
            .init(icon: "💰", headline: "NISA成長投資枠で高配当株を非課税で保有する方法", source: "東洋経済"),
            .init(icon: "📰", headline: "配当利回り5%超の日本株ランキング2024年版", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "VYM・HDVの配当再投資戦略で資産形成する方法", source: "Forbes Japan"),
            .init(icon: "📊", headline: "三菱UFJと日本高配当ETFの比較分析", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "配当再投資の複利効果｜10年・20年のシミュレーション", source: "ビジネスインサイダー"),
            .init(icon: "💴", headline: "月5万円の配当収入を作るポートフォリオの作り方", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "高配当株投資の始め方と銘柄選び", channel: "配当投資チャンネル"),
            .init(platformIcon: "▶️", title: "VYM・HDVをNISAで買う方法と設定手順", channel: "米国株TV"),
            .init(platformIcon: "🎥", title: "日本高配当株でFIREを目指す戦略を解説", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "配当再投資の複利効果を図解で説明", channel: "資産形成TV"),
            .init(platformIcon: "▶️", title: "三菱UFJ・NTTなど高配当株の分析方法", channel: "株式投資ラボ"),
            .init(platformIcon: "🎥", title: "月3万円の配当収入ポートフォリオを公開", channel: "副業攻略TV"),
        ]),
        "成長投資枠を活用": .init(avgIncome: nil, news: [
            .init(icon: "💹", headline: "NISA成長投資枠で買える銘柄の全リスト2024", source: "東洋経済"),
            .init(icon: "📰", headline: "成長投資枠×積立投資枠の最適な組み合わせ方", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "成長投資枠でREITを購入して分配金を非課税で受け取る", source: "Forbes Japan"),
            .init(icon: "📊", headline: "年間240万円の成長投資枠を効率よく使いきる方法", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "成長投資枠で個別株を買う際のリスク管理", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "生涯1800万円の非課税枠を最速で埋める戦略", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "成長投資枠の使い方と対象銘柄の選び方", channel: "NISA攻略"),
            .init(platformIcon: "▶️", title: "成長投資枠でETFを買う方法【画面操作解説】", channel: "投資チャンネル"),
            .init(platformIcon: "🎥", title: "積立枠×成長枠の最強の組み合わせを解説", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "成長投資枠で高配当ETFを保有する戦略", channel: "配当投資チャンネル"),
            .init(platformIcon: "▶️", title: "個別株購入に成長投資枠を使う際の注意点", channel: "資産形成TV"),
            .init(platformIcon: "🎥", title: "1800万円の非課税枠を最速で活用する方法", channel: "副業攻略TV"),
        ]),
        "老後2000万円問題": .init(avgIncome: nil, news: [
            .init(icon: "👴", headline: "老後2000万円問題は今や3000万円問題になっている", source: "東洋経済"),
            .init(icon: "📰", headline: "年金だけでは生活できない理由を数字で解説", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "老後資金を準備するための3つの方法を比較", source: "Forbes Japan"),
            .init(icon: "📊", headline: "30代から老後対策を始めると何が変わるか試算", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "NISA+iDeCoで老後2000万円を達成するプラン", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "65歳以降の生活費を正確に計算する方法", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "老後2000万円問題をわかりやすく解説", channel: "老後対策チャンネル"),
            .init(platformIcon: "▶️", title: "30代から始める老後資産形成の完全版", channel: "資産形成TV"),
            .init(platformIcon: "🎥", title: "NISAで老後2000万円を作るシミュレーション", channel: "NISA攻略"),
            .init(platformIcon: "🎬", title: "年金受給額の確認方法と不足分の計算", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "iDeCo+NISAで老後不安をゼロにする方法", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "老後資金3000万円を現役中に準備する戦略", channel: "副業攻略TV"),
        ]),
        "ロボアドバイザー": .init(avgIncome: nil, news: [
            .init(icon: "🤖", headline: "ウェルスナビ・THEOの実績比較2024年版", source: "東洋経済"),
            .init(icon: "📰", headline: "ロボアドバイザーの手数料が割高な理由と代替手段", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "ロボアドとNISAの使い分け方を専門家が解説", source: "Forbes Japan"),
            .init(icon: "📊", headline: "ウェルスナビの5年間の平均リターンを検証", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "投資初心者がロボアドから卒業するタイミング", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "100万円をロボアドに預けた場合の10年シミュレーション", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "ロボアドバイザーの仕組みと始め方を解説", channel: "投資チャンネル"),
            .init(platformIcon: "▶️", title: "ウェルスナビの口座開設から運用開始まで", channel: "資産形成TV"),
            .init(platformIcon: "🎥", title: "ロボアドとインデックス投資どちらが得か比較", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "THEO+docomoの始め方と設定方法", channel: "ロボアド研究所"),
            .init(platformIcon: "▶️", title: "ロボアドを卒業してNISAに移行する方法", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "投資初心者がロボアドで1年運用した結果", channel: "副業攻略TV"),
        ]),
        "金（ゴールド）で分散": .init(avgIncome: nil, news: [
            .init(icon: "🪙", headline: "金価格が過去最高値更新｜今後の見通しと投資戦略", source: "東洋経済"),
            .init(icon: "📰", headline: "ポートフォリオの5〜10%を金にするメリット", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "金ETFと純金積立の違い｜NISAで買えるのは", source: "Forbes Japan"),
            .init(icon: "📊", headline: "株暴落時に金が上がる理由をデータで検証", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "有事の金｜地政学リスク時の資産防衛としての金投資", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "純金積立で毎月1万円をコツコツ投資した10年の結果", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "金投資の始め方｜ETFと純金積立の比較", channel: "投資チャンネル"),
            .init(platformIcon: "▶️", title: "NISAで金ETFを購入する方法と銘柄選び", channel: "資産形成TV"),
            .init(platformIcon: "🎥", title: "ポートフォリオに金を加えるべき理由とタイミング", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "金価格の動向と今後の投資戦略を解説", channel: "経済チャンネル"),
            .init(platformIcon: "▶️", title: "株・債券・金の分散で資産を安定させる方法", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "純金積立10年で資産がどう変わったか公開", channel: "副業攻略TV"),
        ]),
        "REITで不動産投資": .init(avgIncome: nil, news: [
            .init(icon: "🏘️", headline: "J-REITの分配金利回りランキング2024年版", source: "東洋経済"),
            .init(icon: "📰", headline: "NISA成長投資枠でREITを購入して分配金を非課税に", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "数万円から始められる不動産投資の仕組みを解説", source: "Forbes Japan"),
            .init(icon: "📊", headline: "物流施設・オフィスビル・住宅系REITの比較", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "インバウンド回復でホテル系REITが上昇中", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "REITで月3万円の分配金を受け取るポートフォリオ", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "REIT投資の始め方と銘柄の選び方", channel: "不動産投資チャンネル"),
            .init(platformIcon: "▶️", title: "J-REITとETF-REITの違いと投資方法", channel: "投資チャンネル"),
            .init(platformIcon: "🎥", title: "NISAでREITを購入して分配金を非課税受取り", channel: "NISA攻略"),
            .init(platformIcon: "🎬", title: "REIT分配金で毎月収入を作る戦略を解説", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "物流施設REITが今注目される理由と選び方", channel: "資産形成TV"),
            .init(platformIcon: "🎥", title: "直接不動産投資とREITの比較｜どちらが有利か", channel: "副業攻略TV"),
        ]),
        "iDeCo×NISAの最適活用": .init(avgIncome: nil, news: [
            .init(icon: "🔗", headline: "iDeCo×NISAの二刀流で年間節税＋非課税運用の最強プラン", source: "東洋経済"),
            .init(icon: "📰", headline: "会社員のiDeCo掛け金上限と最適な設定方法", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "iDeCoとNISAの優先順位｜どちらから始めるべきか", source: "Forbes Japan"),
            .init(icon: "📊", headline: "iDeCo2.3万円＋NISA3万円で年間節税効果を試算", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "iDeCoの受け取り方とNISA出口戦略の最適化", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "30代から始めるiDeCo×NISA最強資産形成術", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "iDeCo×NISA二刀流で資産形成を最大化する方法", channel: "資産形成TV"),
            .init(platformIcon: "▶️", title: "iDeCoとNISAの始め方と優先順位を解説", channel: "投資チャンネル"),
            .init(platformIcon: "🎥", title: "年間の節税＋非課税運用の総合効果シミュレーション", channel: "節税TV"),
            .init(platformIcon: "🎬", title: "会社員がiDeCo×NISAで資産1億円を目指す方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "iDeCoの口座開設からNISAとの連携設定まで", channel: "NISA攻略"),
            .init(platformIcon: "🎥", title: "30代が今すぐiDeCo×NISAを始めるべき理由", channel: "副業攻略TV"),
        ]),

        // ── ちりつも作戦 ──
        "ポイ活・電子決済": .init(avgIncome: nil, news: [
            .init(icon: "🎁", headline: "ポイ活で年間10万円を稼ぐ主婦の全手順を公開", source: "東洋経済"),
            .init(icon: "📰", headline: "クレジットカード還元率ランキング2024年版", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "楽天経済圏・PayPay経済圏どちらが得か徹底比較", source: "Forbes Japan"),
            .init(icon: "📊", headline: "電子マネー×ポイントカードで二重取りする方法", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "マイル系カードで旅行費をゼロにした実例", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "ポイントの失効を防ぐ管理術と使い方のコツ", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "ポイ活で年間5万円を稼ぐ方法を全部解説", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "最強クレジットカードの組み合わせ3選", channel: "ポイ活TV"),
            .init(platformIcon: "🎥", title: "楽天カード×PayPayカードの使い分け方", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "ポイントカードのデジタル管理術を解説", channel: "お金の教室"),
            .init(platformIcon: "▶️", title: "電子決済でポイントを効率よく貯める方法", channel: "副業攻略TV"),
            .init(platformIcon: "🎥", title: "マイルを貯めて飛行機タダで乗った体験談", channel: "旅行×節約TV"),
        ]),
        "先取り貯蓄": .init(avgIncome: nil, news: [
            .init(icon: "🐷", headline: "先取り貯蓄で年間50万円を自動で貯めた方法", source: "東洋経済"),
            .init(icon: "📰", headline: "給与日に自動振替を設定する手順を解説", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "先取り貯蓄の適切な割合｜収入の何%が理想か", source: "Forbes Japan"),
            .init(icon: "📊", headline: "先取り貯蓄を3年続けた人の資産変化を調査", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "貯蓄専用口座の作り方と銀行選びのポイント", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "月3,000円から始めて5年で200万円貯めた体験談", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "先取り貯蓄の設定方法と効果を解説", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "銀行の自動積立設定の手順を画面で解説", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "先取り貯蓄で年間100万円貯めたロードマップ", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "貯蓄専用口座の作り方とネット銀行比較", channel: "副業攻略TV"),
            .init(platformIcon: "▶️", title: "家計管理と先取り貯蓄を同時に行う方法", channel: "家計チャンネル"),
            .init(platformIcon: "🎥", title: "貯蓄ゼロから1年で100万円達成した方法", channel: "節約TV"),
        ]),
        "高金利口座を探す": .init(avgIncome: nil, news: [
            .init(icon: "📊", headline: "ネット銀行高金利ランキング2024年版｜最新比較", source: "東洋経済"),
            .init(icon: "📰", headline: "SBI証券×住信SBIネット銀行の連携で金利アップ", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "普通預金0.001%→0.3%への乗り換えで増える金額", source: "Forbes Japan"),
            .init(icon: "🏦", headline: "証券口座の現金管理機能で年利1%を得る方法", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "生活防衛資金の置き場所としての高金利口座活用", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "定期預金キャンペーンで年利2%を得た体験談", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "高金利ネット銀行ランキングと選び方", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "住信SBIネット銀行の口座開設と金利設定", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "証券口座の現金管理サービスで利息を増やす方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "定期預金キャンペーンを使って金利1%を得る方法", channel: "副業攻略TV"),
            .init(platformIcon: "▶️", title: "メガバンクからネット銀行への乗り換え手順", channel: "銀行TV"),
            .init(platformIcon: "🎥", title: "生活防衛資金の最適な置き場所を比較", channel: "資産形成TV"),
        ]),
        "自動積立を設定": .init(avgIncome: nil, news: [
            .init(icon: "🔄", headline: "自動積立設定で意識せずに年間100万円を貯める方法", source: "東洋経済"),
            .init(icon: "📰", headline: "銀行積立定期とNISA自動積立の使い分け方", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "毎月1日に自動積立を設定するだけで変わること", source: "Forbes Japan"),
            .init(icon: "📊", headline: "自動積立3年間の実績と資産変化を公開", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "ボーナス月に積立額を増やす設定のコツ", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "iDeCo・NISA・銀行積立を組み合わせた最強設定", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "自動積立設定の全手順をわかりやすく解説", channel: "資産形成TV"),
            .init(platformIcon: "▶️", title: "NISAの自動積立設定をスマホで完了する方法", channel: "投資チャンネル"),
            .init(platformIcon: "🎥", title: "銀行自動積立で貯金ゼロから脱出した体験談", channel: "節約チャンネル"),
            .init(platformIcon: "🎬", title: "積立金額の最適な設定額と増やすタイミング", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "▶️", title: "iDeCo×NISAの自動積立を同時設定する方法", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "自動積立で年間200万円を達成した設定を公開", channel: "副業攻略TV"),
        ]),
        "格安SIMに変える": .init(avgIncome: nil, news: [
            .init(icon: "📱", headline: "格安SIMランキング2024｜通信品質と料金の比較", source: "東洋経済"),
            .init(icon: "📰", headline: "大手から格安SIMで月5,000円節約した体験談", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "ahamoとpovo2.0の違いと選び方を徹底解説", source: "Forbes Japan"),
            .init(icon: "📊", headline: "格安SIM乗り換えで年間6万円節約する計算", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "格安SIMへの乗り換え手順と注意点まとめ", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "MNPで番号そのまま乗り換える全手順", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "格安SIMの選び方と乗り換え手順を解説", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "ahamoへの乗り換えで月3,000円節約した体験談", channel: "通信費節約TV"),
            .init(platformIcon: "🎥", title: "povo2.0の設定方法と0円運用の始め方", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "格安SIM比較10社｜通信速度と料金の実測結果", channel: "スマホTV"),
            .init(platformIcon: "▶️", title: "MNP転出から新SIM開通まで全手順を解説", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "家族4人で格安SIMに変えて年間24万円節約した方法", channel: "副業攻略TV"),
        ]),
        "節電・節水を習慣に": .init(avgIncome: nil, news: [
            .init(icon: "💡", headline: "電気代2倍の今こそ｜節電で月3,000円削減する方法", source: "東洋経済"),
            .init(icon: "📰", headline: "エアコン設定温度1度で変わる電気代を計算した", source: "ダイヤモンドオンライン"),
            .init(icon: "🌿", headline: "LED照明への切り替えで年間1万円節約する仕組み", source: "Forbes Japan"),
            .init(icon: "📊", headline: "電力会社の切り替えで年間1.5万円節約した事例", source: "日経ビジネス"),
            .init(icon: "🚿", headline: "節水シャワーヘッドの効果｜1年で元が取れる計算", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "太陽光パネル設置で電気代ゼロを実現した家庭の話", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "節電で電気代を月3,000円下げる方法を解説", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "電力会社を切り替えて年間1.5万円節約する手順", channel: "光熱費節約TV"),
            .init(platformIcon: "🎥", title: "LED切り替えと節電グッズで家計を改善する方法", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "エアコンの電気代を最小化する設定のコツ", channel: "家電チャンネル"),
            .init(platformIcon: "▶️", title: "節水シャワーヘッドの効果と選び方", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "光熱費を年間5万円削減した主婦の節電術", channel: "副業攻略TV"),
        ]),
        "お弁当を持参する": .init(avgIncome: nil, news: [
            .init(icon: "🍱", headline: "弁当持参で年間8万円節約した会社員の1ヶ月を追跡", source: "東洋経済"),
            .init(icon: "📰", headline: "作り置きおかずで弁当作りが週1時間で完結する方法", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "コンビニ昼食から弁当切り替えで資産形成が加速", source: "Forbes Japan"),
            .init(icon: "📊", headline: "外食・コンビニ・自炊の昼食コスト比較一覧", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "週3回弁当を持参するだけで月8,000円節約できる計算", source: "ビジネスインサイダー"),
            .init(icon: "🌿", headline: "冷凍食材を活用した時短弁当の作り方", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "弁当持参で月1万円節約する方法を解説", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "作り置き週1時間で弁当5日分を準備する方法", channel: "料理節約TV"),
            .init(platformIcon: "🎥", title: "コンビニ代を弁当に変えて資産形成を加速する話", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "100均弁当グッズで昼食代を200円に抑える方法", channel: "お金の教室"),
            .init(platformIcon: "▶️", title: "5分で作れる弁当レシピ10選", channel: "時短料理チャンネル"),
            .init(platformIcon: "🎥", title: "弁当持参1年間で年間10万円を貯めた体験談", channel: "副業攻略TV"),
        ]),
        "水筒・コーヒーを持参": .init(avgIncome: nil, news: [
            .init(icon: "☕", headline: "コンビニコーヒー毎日→水筒持参で年間4万円節約", source: "東洋経済"),
            .init(icon: "📰", headline: "マイボトル持参の節約効果と健康メリット", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "おすすめ保温水筒5選｜1,500円以下から使えるモデル", source: "Forbes Japan"),
            .init(icon: "📊", headline: "カフェ代×コンビニコーヒー代を月次計算した結果", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "自宅コーヒーのコスト｜1杯20円で作る方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "飲み物代の節約で1年間で貯まったお金を公開", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "水筒持参で年間4万円を節約する方法", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "コーヒー代を月500円に抑えるドリップ術", channel: "コーヒーTV"),
            .init(platformIcon: "🎥", title: "コスパ最強マイボトル5選と使い方", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "飲み物代を節約して年間5万円を積立した体験", channel: "お金の教室"),
            .init(platformIcon: "▶️", title: "1日150円のコーヒー代が年間でいくらになるか計算", channel: "節約TV"),
            .init(platformIcon: "🎥", title: "自宅カフェを作って外食費を削減した主婦の話", channel: "副業攻略TV"),
        ]),
        "まとめ買いで節約": .init(avgIncome: nil, news: [
            .init(icon: "🛒", headline: "まとめ買いで月5,000円節約する食料品管理術", source: "東洋経済"),
            .init(icon: "📰", headline: "業務スーパー活用で食費を月1万円削減した事例", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "まとめ買いで損しないための在庫管理アプリ活用術", source: "Forbes Japan"),
            .init(icon: "📊", headline: "特売日のパターンと買い物タイミングの最適化", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "コストコ・業務スーパーで損する商品・得する商品", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "冷凍保存を活用してまとめ買いを無駄なく使う方法", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "まとめ買いで食費を月1万円下げる方法", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "業務スーパー活用術｜コスパの良い商品10選", channel: "食費節約TV"),
            .init(platformIcon: "🎥", title: "食材の冷凍保存で無駄ゼロのまとめ買い術", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "コストコで損しないための買い物リスト", channel: "コストコTV"),
            .init(platformIcon: "▶️", title: "在庫管理アプリで買いすぎを防ぐ方法", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "週1まとめ買いで食費月2万円を達成した方法", channel: "副業攻略TV"),
        ]),
        "図書館を活用する": .init(avgIncome: nil, news: [
            .init(icon: "📚", headline: "図書館の電子サービスで無料で読める本が急増中", source: "東洋経済"),
            .init(icon: "📰", headline: "年間書籍代5万円をゼロにした図書館活用術", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "図書館カードで利用できる電子図書館サービス一覧", source: "Forbes Japan"),
            .init(icon: "📊", headline: "Kindle本vs図書館どちらが得か比較した結果", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "図書館の取り寄せサービスで絶版本を読む方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "自習室・Wi-Fi無料でカフェ代も節約できる図書館活用", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "図書館を使って年間書籍代ゼロにする方法", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "電子図書館の使い方とアプリ設定方法", channel: "読書TV"),
            .init(platformIcon: "🎥", title: "図書館＋KindleUnlimitedで読書代を最小化する", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "図書館のビジネス書・資格書活用で節約しながら成長", channel: "お金の教室"),
            .init(platformIcon: "▶️", title: "図書館で無料で使えるサービス一覧を解説", channel: "節約TV"),
            .init(platformIcon: "🎥", title: "図書館を活用して年間5万円の書籍代を節約した話", channel: "副業攻略TV"),
        ]),
        "ATM手数料をゼロに": .init(avgIncome: nil, news: [
            .init(icon: "🏦", headline: "コンビニATM手数料が年間で数万円になっている現実", source: "東洋経済"),
            .init(icon: "📰", headline: "手数料無料ATMが使えるネット銀行ランキング2024", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "イオン銀行・住信SBIの手数料無料条件を比較", source: "Forbes Japan"),
            .init(icon: "📊", headline: "月3回のATM手数料が年間で8,000円超になる計算", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "キャッシュレス化でATM利用を週ゼロにする方法", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "ATM手数料を完全ゼロにして年間1万円を節約した話", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "ATM手数料をゼロにする銀行の選び方", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "住信SBIネット銀行でATM手数料を無料にする方法", channel: "銀行TV"),
            .init(platformIcon: "🎥", title: "キャッシュレス化でATMを使わない生活の作り方", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "手数料無料ATMが多い銀行カードを比較", channel: "お金の教室"),
            .init(platformIcon: "▶️", title: "イオン銀行の手数料無料条件と口座開設方法", channel: "節約TV"),
            .init(platformIcon: "🎥", title: "ATM手数料節約で年間1万円を積み立てた体験", channel: "副業攻略TV"),
        ]),
        "ジムをやめて自宅トレ": .init(avgIncome: nil, news: [
            .init(icon: "🏋️", headline: "ジム解約で年間10万円を節約してYouTube筋トレに切替", source: "東洋経済"),
            .init(icon: "📰", headline: "自宅筋トレで同じ効果が出る理由を専門家が解説", source: "ダイヤモンドオンライン"),
            .init(icon: "💡", headline: "1万円以下で揃えるホームジムの最低限の器具", source: "Forbes Japan"),
            .init(icon: "📊", headline: "ジム代月1万円→YouTube無料で変わった体の変化", source: "日経ビジネス"),
            .init(icon: "🎯", headline: "おすすめ自宅筋トレYouTubeチャンネル5選", source: "ビジネスインサイダー"),
            .init(icon: "💰", headline: "公共のスポーツ施設を月500円で利用する方法", source: "AERA dot."),
        ], videos: [
            .init(platformIcon: "🎬", title: "自宅筋トレで年間10万円を節約する方法", channel: "節約チャンネル"),
            .init(platformIcon: "▶️", title: "器具なしで全身を鍛える自重トレーニングメニュー", channel: "筋トレTV"),
            .init(platformIcon: "🎥", title: "1万円以下のダンベルセットで始めるホームジム", channel: "稼ぐ力チャンネル"),
            .init(platformIcon: "🎬", title: "ジムを解約してYouTube筋トレで体が変わった体験談", channel: "フィットネスTV"),
            .init(platformIcon: "▶️", title: "公共スポーツ施設の利用方法と節約効果", channel: "お金の教室"),
            .init(platformIcon: "🎥", title: "週3回30分の自宅トレで年間12万円を節約した話", channel: "副業攻略TV"),
        ]),
    ]
}

// MARK: - 副業情報ハブ グリッドカード
private struct FukugyouGridCard: View {
    @EnvironmentObject var appState: AppState
    let emoji: String
    let title: String
    let tagColor: Color
    let description: String
    @State private var showHub = false

    var body: some View {
        Button(action: {
            showHub = true
            appState.recordCardView(emoji: emoji, title: title, category: .grow)
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
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(tagColor.opacity(0.25), lineWidth: 1.2))
            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showHub) {
            FukugyouHubSheet(
                emoji: emoji, title: title,
                description: description, accentColor: tagColor,
                relatedContent: FukugyouRelatedContent.data[title]
            )
        }
    }
}

// MARK: - 副業情報ハブ シート
struct FukugyouHubSheet: View {
    @Environment(\.dismiss) private var dismiss
    let emoji: String
    let title: String
    let description: String
    let accentColor: Color
    let relatedContent: FukugyouRelatedContent?

    @State private var showMoreNews   = false
    @State private var showMoreVideos = false

    private static let previewCount = 3

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // ── ヘッダー
                        VStack(spacing: 10) {
                            Text(emoji).font(.system(size: 52))
                            Text(title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppColor.textPrimary)
                            if let avg = relatedContent?.avgIncome {
                                Text("平均収入: \(avg)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(accentColor)
                                    .padding(.horizontal, 12).padding(.vertical, 5)
                                    .background(accentColor.opacity(0.1))
                                    .cornerRadius(20)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [accentColor.opacity(0.08), AppColor.cardBackground],
                                                   startPoint: .top, endPoint: .bottom))
                        .cornerRadius(16)

                        // ── 概要
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📝 概要")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)
                            Text(description)
                                .font(.system(size: 14))
                                .foregroundColor(AppColor.textPrimary)
                                .lineSpacing(4)
                        }
                        .padding(14)
                        .background(AppColor.cardBackground)
                        .cornerRadius(14)
                        .shadow(color: AppColor.shadowColor, radius: 3, x: 0, y: 1)

                        // ── 関連ニュース
                        if let news = relatedContent?.news, !news.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                // セクションヘッダー
                                HStack(spacing: 6) {
                                    Image(systemName: "newspaper.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(accentColor)
                                    Text("関連ニュース")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppColor.textPrimary)
                                    Spacer()
                                    Button(action: { showMoreNews = true }) {
                                        Text("続きを見る")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(accentColor)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 11))
                                            .foregroundColor(accentColor)
                                    }
                                    .buttonStyle(.plain)
                                }

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(news.prefix(Self.previewCount).enumerated()), id: \.element.id) { i, item in
                                            NewsItemRow(item: item, accentColor: accentColor, index: i)
                                        }
                                    }
                                    .padding(.horizontal, 2).padding(.vertical, 2)
                                }
                            }
                            .padding(14)
                            .background(AppColor.cardBackground)
                            .cornerRadius(14)
                            .shadow(color: AppColor.shadowColor, radius: 3, x: 0, y: 1)
                            .sheet(isPresented: $showMoreNews) {
                                MoreItemsSheet(
                                    kind: .news, title: title, accentColor: accentColor,
                                    news: news, videos: []
                                )
                            }
                        }

                        // ── 関連動画
                        if let videos = relatedContent?.videos, !videos.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "play.rectangle.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(.red)
                                    Text("関連動画")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppColor.textPrimary)
                                    Spacer()
                                    Button(action: { showMoreVideos = true }) {
                                        Text("続きを見る")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.red)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 11))
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(videos.prefix(Self.previewCount).enumerated()), id: \.element.id) { i, item in
                                            VideoItemRow(item: item, accentColor: accentColor, index: i)
                                        }
                                    }
                                    .padding(.horizontal, 2).padding(.vertical, 2)
                                }
                            }
                            .padding(14)
                            .background(AppColor.cardBackground)
                            .cornerRadius(14)
                            .shadow(color: AppColor.shadowColor, radius: 3, x: 0, y: 1)
                            .sheet(isPresented: $showMoreVideos) {
                                MoreItemsSheet(
                                    kind: .videos, title: title, accentColor: accentColor,
                                    news: [], videos: videos
                                )
                            }
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

// MARK: - ニュースカード（横スクロール用）
struct NewsItemRow: View {
    let item: FukugyouRelatedContent.NewsItem
    let accentColor: Color
    let index: Int

    @Environment(\.openURL) private var openURL

    private var sourceDomain: String {
        switch item.source {
        case "東洋経済", "東洋経済オンライン": return "toyokeizai.net"
        case "ダイヤモンドオンライン":         return "diamond.jp"
        case "Forbes Japan":                   return "forbesjapan.com"
        case "日経ビジネス":                   return "business.nikkei.com"
        case "日経", "日経MJ":                 return "nikkei.com"
        case "ビジネスインサイダー":           return "businessinsider.jp"
        case "AERA dot.":                      return "dot.asahi.com"
        case "Biz/Zine":                       return "bizzine.jp"
        case "ランサーズブログ":               return "lancers.jp"
        case "クラウドワークスブログ":         return "crowdworks.jp"
        default:                               return "google.com"
        }
    }

    private var sourceColor: Color {
        switch item.source {
        case "東洋経済", "東洋経済オンライン": return Color(red: 0.85, green: 0.18, blue: 0.18)
        case "ダイヤモンドオンライン":         return Color(red: 0.10, green: 0.25, blue: 0.65)
        case "Forbes Japan":                   return Color(red: 0.72, green: 0.55, blue: 0.10)
        case "日経ビジネス", "日経", "日経MJ": return Color(red: 0.80, green: 0.10, blue: 0.10)
        case "ビジネスインサイダー":           return Color(red: 0.10, green: 0.10, blue: 0.10)
        case "AERA dot.":                      return Color(red: 0.20, green: 0.45, blue: 0.80)
        default:                               return accentColor
        }
    }

    private var faviconURL: URL? {
        URL(string: "https://www.google.com/s2/favicons?domain=\(sourceDomain)&sz=128")
    }

    private var searchURL: URL? {
        let q = item.headline.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://news.google.com/search?q=\(q)&hl=ja&gl=JP&ceid=JP:ja")
    }

    private var thumbnailURL: URL? {
        URL(string: "https://picsum.photos/seed/news\(index)a/300/170")
    }

    var body: some View {
        Button(action: { if let url = searchURL { openURL(url) } }) {
            VStack(alignment: .leading, spacing: 0) {
                // サムネイル
                ZStack(alignment: .bottomLeading) {
                    // 実写真サムネイル
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            LinearGradient(
                                colors: [sourceColor, sourceColor.opacity(0.55)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        }
                    }
                    .frame(width: 168, height: 100)
                    .clipped()

                    // 暗めオーバーレイ（テキスト読みやすさ確保）
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.45)],
                        startPoint: .top, endPoint: .bottom
                    )

                    // ソースバッジ（左下）
                    HStack(spacing: 4) {
                        AsyncImage(url: faviconURL) { phase in
                            if case .success(let img) = phase {
                                img.resizable().scaledToFit()
                                    .frame(width: 14, height: 14)
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                            }
                        }
                        .frame(width: 14, height: 14)
                        Text(item.source)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6).padding(.vertical, 3)
                    .background(Color.black.opacity(0.45))
                    .cornerRadius(4)
                    .padding(6)
                    // 右上の外部リンクアイコン
                    Image(systemName: "arrow.up.right.square.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 168, height: 100, alignment: .topTrailing)
                        .padding(6)
                }
                .frame(width: 168, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                // テキスト部分
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.headline)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColor.textPrimary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 4)
                .padding(.top, 7)
                .padding(.bottom, 4)
            }
            .frame(width: 168)
            .background(AppColor.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 動画カード（横スクロール用・YouTubeスタイル）
struct VideoItemRow: View {
    let item: FukugyouRelatedContent.VideoItem
    let accentColor: Color
    let index: Int

    @Environment(\.openURL) private var openURL

    private var youtubeURL: URL? {
        let q = item.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.youtube.com/results?search_query=\(q)")
    }

    // チャンネル名から頭文字を取得
    private var channelInitial: String {
        String(item.channel.prefix(1))
    }

    // インデックスごとにアクセントカラーを変える
    private var bgColors: [Color] {
        [[accentColor, accentColor.opacity(0.4)],
         [Color.red.opacity(0.8), Color(red: 0.5, green: 0.05, blue: 0.05)],
         [accentColor.opacity(0.7), Color(red: 0.05, green: 0.05, blue: 0.20)]][index % 3]
    }

    private var thumbnailURL: URL? {
        URL(string: "https://picsum.photos/seed/video\(index)b/300/170")
    }

    var body: some View {
        Button(action: { if let url = youtubeURL { openURL(url) } }) {
            VStack(alignment: .leading, spacing: 0) {
                // サムネイル（16:9）
                ZStack(alignment: .bottomLeading) {
                    // 実写真サムネイル
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            LinearGradient(colors: bgColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        }
                    }
                    .frame(width: 168, height: 95)
                    .clipped()

                    // 暗めオーバーレイ
                    Color.black.opacity(0.25)

                    // 中央の再生ボタン
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.55))
                            .frame(width: 44, height: 44)
                        Image(systemName: "play.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .offset(x: 2)
                    }
                    .frame(width: 168, height: 95)
                    // 左下 YouTubeバッジ
                    HStack(spacing: 3) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                        Text("YouTube")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(Color.red)
                    .cornerRadius(3)
                    .padding(6)
                    // チャンネル名（右下）
                    Text(item.channel)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(3)
                        .frame(width: 168, height: 95, alignment: .bottomTrailing)
                        .padding(6)
                }
                .frame(width: 168, height: 95)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                // テキスト部分
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColor.textPrimary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(item.channel)
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.textTertiary)
                }
                .padding(.horizontal, 4)
                .padding(.top, 7)
                .padding(.bottom, 4)
            }
            .frame(width: 168)
            .background(AppColor.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 続きを見るシート
struct MoreItemsSheet: View {
    enum Kind { case news, videos }

    let kind: Kind
    let title: String
    let accentColor: Color
    let news: [FukugyouRelatedContent.NewsItem]
    let videos: [FukugyouRelatedContent.VideoItem]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        switch kind {
                        case .news:
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(Array(news.enumerated()), id: \.element.id) { i, item in
                                    NewsItemRow(item: item, accentColor: accentColor, index: i % 3)
                                }
                            }
                            .padding(.horizontal, 16)
                        case .videos:
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(Array(videos.enumerated()), id: \.element.id) { i, item in
                                    VideoItemRow(item: item, accentColor: accentColor, index: i % 3)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        Spacer().frame(height: 30)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle(kind == .news ? "関連ニュース一覧" : "関連動画一覧")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 4) {
                        Image(systemName: kind == .news ? "newspaper.fill" : "play.rectangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(kind == .news ? accentColor : .red)
                        Text(title)
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textSecondary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(accentColor)
                }
            }
        }
    }
}

// MARK: - 副業で稼ぐ シート
struct GrowFukugyouSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // バナー：物価上昇・実質賃金低下への対応
                        HStack(spacing: 10) {
                            Text("💡")
                                .font(.system(size: 22))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("実質賃金が下がり続ける今、副業は必須")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.0))
                                Text("月2〜5万円の副収入で生活防衛ラインを確保しましょう")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColor.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(red: 1.0, green: 0.95, blue: 0.80))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                        LazyVGrid(columns: columns, spacing: 12) {
                            FukugyouGridCard(emoji: "🤖", title: "AIで副業収入", tagColor: Color.purple.opacity(0.8),
                                description: "ChatGPTやClaudeを使えばライティング・企画書・翻訳・画像生成など、1人でできる仕事の幅が急拡大。AIを「道具」として使いこなすことで、スキルがなくても月数万円の副収入が現実的になっています。")
                            FukugyouGridCard(emoji: "📱", title: "SNS運用代行", tagColor: Color.pink.opacity(0.8),
                                description: "中小企業・個人経営者のInstagram・X・TikTokの投稿代行は月3〜10万円が相場。自分自身のSNSをある程度育てた実績があれば受注しやすく、完全リモートで完結します。")
                            FukugyouGridCard(emoji: "🎬", title: "動画編集副業", tagColor: Color.red.opacity(0.75),
                                description: "YouTuber・企業動画の編集は1本5,000〜30,000円が相場。CapCutやDaVinci Resolveは無料で使え、独学3ヶ月で受注できるレベルに到達できます。動画市場拡大でニーズは急増中。")
                            FukugyouGridCard(emoji: "💻", title: "プログラミング・Web制作", tagColor: AppColor.primary,
                                description: "DX推進の波でWeb制作・アプリ開発の需要は高まる一方。HTML/CSSだけでも数万円の案件があり、Reactが書ければ月20〜50万円の案件も。クラウドワークスやランサーズで未経験から実績を積めます。")
                            FukugyouGridCard(emoji: "✍️", title: "Webライター・SEO記事", tagColor: Color.orange.opacity(0.85),
                                description: "企業のオウンドメディア向けSEO記事は1文字0.5〜3円が相場。ChatGPTと組み合わせることで執筆速度が2〜3倍に。クラウドワークスで初心者案件から始め、専門性を高めると単価が上がります。")
                            FukugyouGridCard(emoji: "🎓", title: "オンライン家庭教師", tagColor: Color.indigo.opacity(0.8),
                                description: "塾講師経験や得意科目があれば、家庭教師マッチングサービス（まなぶ・スタディコーチ等）で時給1,500〜5,000円で教えられます。Zoomで完結するため移動ゼロ。大学生・社会人問わず始められます。")
                            FukugyouGridCard(emoji: "♻️", title: "せどり・フリマ物販", tagColor: AppColor.secondary,
                                description: "リサイクルショップ・セール品をメルカリ・ラクマで転売するせどり。初期費用3〜5万円で月5〜15万円を狙えます。Keepaなどの価格追跡ツールを使えば仕入れリスクを減らせます。")
                            FukugyouGridCard(emoji: "🚗", title: "ギグワーク・配達", tagColor: Color.orange,
                                description: "Uber Eats・出前館・Wolt等の配達は、スキマ時間に自分のペースで稼げます。自転車でも始められ、週5時間で月1〜2万円。複数サービスに登録し稼働時間を最大化するのがコツです。")
                            FukugyouGridCard(emoji: "📚", title: "noteで知識を売る", tagColor: Color.teal.opacity(0.8),
                                description: "自分の経験・知識・ノウハウをnoteの有料記事やコンテンツとして販売。500〜3,000円/本で、1度書けば繰り返し収入に。転職体験・節約術・料理レシピなど、日常の経験が商品になります。")
                            FukugyouGridCard(emoji: "🌏", title: "翻訳・英語副業", tagColor: Color.blue.opacity(0.75),
                                description: "英語が得意なら翻訳副業は時給換算で高単価。DeepLを補助に使いながら精度を高める「後編集翻訳（MTPE）」はAI時代の新しい働き方。ランサーズや専門翻訳会社への登録で案件を取得できます。")
                            FukugyouGridCard(emoji: "🏠", title: "スペース貸し・民泊", tagColor: Color.brown.opacity(0.7),
                                description: "使っていない駐車場・空き部屋をakippaやAirbnbで貸し出すと毎月収入が得られます。都市部では駐車場1台で月2〜5万円も。初期費用ほぼゼロで始められます。")
                            FukugyouGridCard(emoji: "📸", title: "ストック素材販売", tagColor: Color.green.opacity(0.75),
                                description: "スマホで撮った写真・AIで生成したイラストをPIXTAやAdobe Stockに登録すると、ダウンロードごとに収入に。一度登録すれば自動で稼いでくれるストック型の不労所得です。")
                            FukugyouGridCard(emoji: "🎨", title: "ハンドメイド・Minne販売", tagColor: Color.pink.opacity(0.7),
                                description: "手作りアクセサリー・イラスト・デジタルデータをMinneやCreemaで販売。デジタルデータ（壁紙・テンプレート等）は在庫ゼロで何度でも売れます。材料費と売値を計算してから始めましょう。")
                            FukugyouGridCard(emoji: "🎥", title: "YouTube・ショート動画", tagColor: Color.red.opacity(0.65),
                                description: "TikTok・Instagram Reels・YouTubeショートは短尺動画の需要が急増中。1分以内の動画でも収益化できる時代に。趣味・料理・節約術など、日常のリアルな発信が特に伸びています。")
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        Spacer().frame(height: 20)
                    }
                }
            }
            .navigationTitle("副業で稼ぐ")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("閉じる") { dismiss() } } }
        }
    }
}

// MARK: - キャリア・転職 シート
struct GrowCareerSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        GrowGridCard(emoji: "🏢", title: "転職で年収アップ", tagColor: Color.indigo.opacity(0.85),
                            description: "同じスキルでも会社が変わるだけで年収が100〜200万円アップするケースは珍しくありません。転職エージェントは無料で利用でき、市場価値を確認するだけでもOKです。")
                        GrowGridCard(emoji: "🔓", title: "副業OKの会社に転職", tagColor: Color.teal.opacity(0.8),
                            description: "副業禁止の会社から副業解禁している会社に転職するだけで収入の選択肢が広がります。最近は副業推奨の企業も増えており、年収本業＋副収入で大きく変わります。")
                        GrowGridCard(emoji: "📚", title: "資格取得で単価アップ", tagColor: Color.orange.opacity(0.85),
                            description: "FP・宅建・簿記・ITパスポートなどの資格は取得すれば昇給・転職・副業のすべてに使えます。まずは自分の仕事に関連する資格を1つ目指してみましょう。")
                        GrowGridCard(emoji: "🌐", title: "英語力で収入アップ", tagColor: Color.blue.opacity(0.75),
                            description: "TOEIC700点以上になると転職時の選択肢が大幅に広がり、外資系や商社など高収入の職場も視野に。英語の翻訳・通訳副業も時給が高めです。")
                        GrowGridCard(emoji: "💼", title: "個人事業主になる", tagColor: Color.purple.opacity(0.8),
                            description: "副業が軌道に乗ったら個人事業主として開業届を提出。青色申告で最大65万円の控除が受けられ、経費計上で節税できます。開業届は無料で税務署に提出するだけです。")
                        GrowGridCard(emoji: "🏗️", title: "法人化を検討する", tagColor: Color.indigo.opacity(0.75),
                            description: "個人事業の収入が年700万円を超えてきたら法人化が節税になるケースが多いです。役員報酬・社会保険・経費の幅が広がり、信用度もアップします。")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    Spacer().frame(height: 20)
                }
            }
            .navigationTitle("キャリア・転職で増やす")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("閉じる") { dismiss() } } }
        }
    }
}

// MARK: - 節税 シート
struct GrowSetsuzeiSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack(spacing: 10) {
                            Text("💡")
                                .font(.system(size: 22))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("申告しないと損！会社員でも使える控除が多数")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(red: 0.55, green: 0.30, blue: 0.0))
                                Text("知っている人だけが得をする節税制度を全部使いましょう")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColor.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(red: 1.0, green: 0.95, blue: 0.80))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                        LazyVGrid(columns: columns, spacing: 12) {
                            GrowGridCard(emoji: "🏯", title: "ふるさと納税", tagColor: Color.orange,
                                description: "寄附金額から2,000円を引いた額が税金から控除される制度。物価上昇の今こそ、お米・肉・日用品などの返礼品を最大限活用しましょう。「ワンストップ特例」なら確定申告不要。さとふるやふるなびで上限額を即確認できます。")
                            GrowGridCard(emoji: "📋", title: "iDeCoで老後＋節税", tagColor: Color.indigo.opacity(0.8),
                                description: "掛け金が全額所得控除になる強力な節税手段。年収500万円の会社員が月2.3万円掛けると年間約5.5万円の節税効果。2024年の制度改正で拠出限度額も引き上げ。老後対策と節税を同時に達成できます。")
                            GrowGridCard(emoji: "🏥", title: "医療費控除を活用", tagColor: Color.red.opacity(0.75),
                                description: "1年間の医療費が世帯で10万円を超えた分を所得控除できます。病院代だけでなく、通院交通費・市販薬・介護費用も対象。家族全員分をまとめて申告でき、所得の低い人が申告すると控除効果が高まります。")
                            GrowGridCard(emoji: "📜", title: "年末調整の漏れをなくす", tagColor: Color.teal.opacity(0.8),
                                description: "生命保険料控除・地震保険料控除・住宅ローン控除（2年目以降）は年末調整で申請できます。書類を提出し忘れると数千〜数万円を損することも。10〜11月に届く控除証明書はすぐ保管しましょう。")
                            GrowGridCard(emoji: "💼", title: "副業の経費を計上", tagColor: Color.purple.opacity(0.8),
                                description: "副業収入がある場合、スマホ代・PC代・書籍代・通信費・交通費などを経費として計上できます。副業の利益＝収入−経費で計算され、経費が増えるほど税負担が減ります。青色申告すると最大65万円の特別控除も。")
                            GrowGridCard(emoji: "👨‍👩‍👧", title: "配偶者・扶養控除", tagColor: Color.pink.opacity(0.75),
                                description: "配偶者の年収が103万円以下なら配偶者控除（最大38万円）が使えます。150万円以下でも配偶者特別控除が適用可能。子供や親の扶養に入れているかも確認を。控除を正しく申請するだけで数万円の節税になります。")
                            GrowGridCard(emoji: "🏗️", title: "小規模企業共済", tagColor: Color.brown.opacity(0.75),
                                description: "フリーランス・個人事業主が加入できる退職金制度。掛け金が全額所得控除になり、月7万円まで掛けられます。廃業・退職時に共済金を受け取れるため、節税しながら将来の備えにもなります。")
                            GrowGridCard(emoji: "🖥️", title: "e-Taxで確定申告", tagColor: Color.blue.opacity(0.75),
                                description: "e-Tax（電子申告）で確定申告すると青色申告の65万円控除が受けられます（紙申告は55万円）。スマホのマイナンバーカード＋国税庁の確定申告作成コーナーで手続きが完結。還付金も早く戻ってきます。")
                            GrowGridCard(emoji: "💊", title: "セルフメディケーション税制", tagColor: Color.green.opacity(0.8),
                                description: "市販の対象スイッチOTC薬の購入費が年1.2万円を超えた分（最大8.8万円）を控除できます。通常の医療費控除との選択適用。レシートと購入明細を保管しておけば、翌年の確定申告で申請できます。")
                            GrowGridCard(emoji: "🏠", title: "住宅ローン控除", tagColor: Color.orange.opacity(0.85),
                                description: "住宅ローン残高の0.7%が最長13年間、税金から控除される制度。新築・中古・リフォームも対象。入居初年度は確定申告が必要ですが、2年目以降は年末調整で完結。子育て世帯向けの特例措置も延長中。")
                            GrowGridCard(emoji: "🎁", title: "特定支出控除", tagColor: Color.indigo.opacity(0.75),
                                description: "資格取得費・研修費・転勤に伴う引越し代・職場への交通費など、給与所得者が仕事で支出した費用が一定額を超えると確定申告で控除できます。会社員には意外と知られていない節税手段です。")
                            GrowGridCard(emoji: "🛡️", title: "生命保険料控除", tagColor: Color.teal.opacity(0.75),
                                description: "生命保険・医療保険・個人年金保険の保険料は、一般生命保険料・介護医療保険料・個人年金保険料の3つに区分され、それぞれ最大4万円ずつ（合計最大12万円）の所得控除になります。")
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        Spacer().frame(height: 20)
                    }
                }
            }
            .navigationTitle("節税で増やす")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("閉じる") { dismiss() } } }
        }
    }
}

// MARK: - NISA・投資 シート
struct GrowNisaSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack(spacing: 10) {
                            Text("💡")
                                .font(.system(size: 22))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("物価上昇・円安・老後不安を投資で乗り越える")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.45, blue: 0.2))
                                Text("新NISAで非課税のまま長期運用するのが最強の選択肢")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColor.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(red: 0.88, green: 0.97, blue: 0.88))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                        LazyVGrid(columns: columns, spacing: 12) {
                            GrowGridCard(emoji: "🌱", title: "新NISAの基本", tagColor: Color.green.opacity(0.8),
                                description: "2024年から始まった新NISAは非課税期間が無期限・年間360万円まで投資可能になった大幅パワーアップ版。運用益・売却益に税金がかかりません。SBI証券・楽天証券で最短5分で口座開設できます。")
                            GrowGridCard(emoji: "🔥", title: "インフレから資産を守る", tagColor: Color.red.opacity(0.75),
                                description: "物価上昇が続く日本で現金のまま持つと実質的に資産が目減りします。年3%のインフレが続くと10年で100万円の価値が約74万円に。株式投資はインフレに連動して価格が上がるため、資産防衛の手段として有効です。")
                            GrowGridCard(emoji: "💴", title: "円安対策・外貨資産", tagColor: Color.orange.opacity(0.85),
                                description: "円安が続く局面では、円だけで資産を持つとドル建てで見た資産価値が下がります。全世界株・S&P500インデックスは外貨建て資産を含むため、自然と為替リスクを分散できます。資産の一部を外貨建てにする意識が重要です。")
                            GrowGridCard(emoji: "📈", title: "積立投資枠を使う", tagColor: AppColor.primary,
                                description: "毎月1万円を20年間、年利5%で積み立てると約411万円（元本240万円）に。積立投資枠は年間120万円・月1万円から自動積立できます。暴落しても売らず積み続けることで、平均購入単価を下げる「ドルコスト平均法」が機能します。")
                            GrowGridCard(emoji: "🌍", title: "全世界・米国株インデックス", tagColor: Color.blue.opacity(0.75),
                                description: "eMAXIS Slim 全世界株式（オルカン）やS&P500インデックスは、信託報酬0.05〜0.1%台の超低コストで世界中の企業に分散投資できます。30年の実績でS&P500は年率約10%のリターン。長期積立の鉄板です。")
                            GrowGridCard(emoji: "💰", title: "高配当株・配当再投資", tagColor: Color.yellow.opacity(0.9),
                                description: "配当利回り3〜5%の高配当株をNISA成長投資枠で購入すると、配当金が非課税で受け取れます。日本の高配当ETF（VYMやHDV）や個別株（三菱UFJ・NTT等）を中心に、配当金を再投資する「複利運用」が長期では強力です。")
                            GrowGridCard(emoji: "💹", title: "成長投資枠を活用", tagColor: Color.teal.opacity(0.8),
                                description: "NISA成長投資枠（年間240万円）は個別株・ETF・REITに投資できます。積立投資枠と合わせると年間360万円・生涯1,800万円まで非課税。高配当株や国内ETFをここで購入するのが定番です。")
                            GrowGridCard(emoji: "👴", title: "老後2000万円問題", tagColor: Color.purple.opacity(0.8),
                                description: "老後30年で約2,000万円が不足するとされる試算は今も有効で、物価上昇でむしろ必要額は増加傾向です。月3万円を25年間NISAで年率5%運用すると約1,730万円に。早く始めるほど「時間」が最大の味方になります。")
                            GrowGridCard(emoji: "🤖", title: "ロボアドバイザー", tagColor: Color.indigo.opacity(0.75),
                                description: "ウェルスナビやTHEOは、リスク許容度を答えるだけで自動で分散投資してくれるサービス。最低1万円から始められ、リバランスも自動。「何を買えばいいかわからない」人に最適な入口です。")
                            GrowGridCard(emoji: "🪙", title: "金（ゴールド）で分散", tagColor: Color.yellow.opacity(0.8),
                                description: "株価が下落するとき金は上がる傾向があり、ポートフォリオの安定剤として機能します。SBI証券や楽天証券で金ETFをNISA成長投資枠で購入できます。資産全体の5〜10%程度を金に配分するのが一般的な分散戦略です。")
                            GrowGridCard(emoji: "🏘️", title: "REITで不動産投資", tagColor: Color.orange.opacity(0.8),
                                description: "数万円から始められる不動産投資信託（REIT）。物件を直接持たずに不動産収益（分配金）を受け取れます。NISA成長投資枠で購入すれば分配金も非課税。都心のオフィスビルや物流施設に間接投資できます。")
                            GrowGridCard(emoji: "🔗", title: "iDeCo×NISAの最適活用", tagColor: Color.green.opacity(0.75),
                                description: "iDeCo（掛け金全額控除）とNISA（運用益非課税）の二刀流が最強の資産形成戦略。会社員なら毎月iDeCo2.3万円＋NISA積立3万円で、年間節税効果と非課税メリットを両取りできます。まず始めることが最優先です。")
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        Spacer().frame(height: 20)
                    }
                }
            }
            .navigationTitle("NISA・投資")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("閉じる") { dismiss() } } }
        }
    }
}

// MARK: - ちりつも作戦 シート
struct GrowChiritsumoSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        GrowGridCard(emoji: "🎁", title: "ポイ活・電子決済", tagColor: AppColor.secondary,
                            description: "日常の支払いをクレジットカードや電子マネーにまとめることで、ポイントが貯まります。年間数万円相当になることも。ただし使いすぎに注意。")
                        GrowGridCard(emoji: "🐷", title: "先取り貯蓄", tagColor: AppColor.secondary,
                            description: "給料が入ったら自動で貯蓄口座に移す「先取り貯蓄」。残ったお金で生活する習慣が身につき、自然と貯まっていきます。月3,000円からでも始められます。")
                        GrowGridCard(emoji: "📊", title: "高金利口座を探す", tagColor: Color.green.opacity(0.8),
                            description: "メガバンクの普通預金金利は低いですが、ネット銀行や証券会社の現金管理サービスでは年0.1〜0.3%程度の高金利のものもあります。緊急資金の置き場として検討を。")
                        GrowGridCard(emoji: "🔄", title: "自動積立を設定", tagColor: AppColor.primary,
                            description: "手動で貯金するより「自動積立」が長続きのコツ。銀行の積立定期や投資信託の自動積立を設定すれば、意識しなくても資産が積み上がっていきます。")
                        GrowGridCard(emoji: "📱", title: "格安SIMに変える", tagColor: Color.teal.opacity(0.8),
                            description: "大手キャリアから格安SIMに乗り換えると、月々の通信費が3,000〜6,000円程度安くなることも。年間で3〜7万円の節約になります。")
                        GrowGridCard(emoji: "💡", title: "節電・節水を習慣に", tagColor: Color.orange.opacity(0.8),
                            description: "こまめな消灯・エアコンの設定温度を1度調整するだけで、月数百〜数千円の光熱費削減に。LED照明への切り替えも初期費用は回収できます。")
                        GrowGridCard(emoji: "🍱", title: "お弁当を持参する", tagColor: Color.orange,
                            description: "外食1回800円→弁当200円なら1回600円節約。週3回持参すると月約7,000円の削減に。作り置きおかずを活用すると時間も手間も省けます。")
                        GrowGridCard(emoji: "☕", title: "水筒・コーヒーを持参", tagColor: Color.brown.opacity(0.7),
                            description: "コンビニのコーヒー1杯150円を毎日買うと月4,500円。自宅でコーヒーを作って持参すれば月数千円の節約になります。ボトル代はすぐ元が取れます。")
                        GrowGridCard(emoji: "🛒", title: "まとめ買いで節約", tagColor: Color.green.opacity(0.8),
                            description: "日用品や食材を特売日にまとめ買いすると単価が下がります。ただし買いすぎて無駄にならないよう、使い切れる量だけ購入するのがコツです。")
                        GrowGridCard(emoji: "📚", title: "図書館を活用する", tagColor: Color.indigo.opacity(0.7),
                            description: "本・雑誌・DVDを無料で借りられる図書館は最強の節約術。電子図書館サービスを使えばスマホで読むことも。年間数万円の書籍代が浮きます。")
                        GrowGridCard(emoji: "🏦", title: "ATM手数料をゼロに", tagColor: AppColor.primary,
                            description: "コンビニATMの手数料110〜220円は積み重なると大きな出費。ネット銀行のキャッシュカードや、手数料無料のATMを使う習慣をつけましょう。")
                        GrowGridCard(emoji: "🏋️", title: "ジムをやめて自宅トレ", tagColor: Color.teal.opacity(0.75),
                            description: "月7,000〜10,000円のジム代もバカになりません。YouTube筋トレ動画＋ダンベル1セットで自宅でも十分な筋トレができます。年間8〜12万円の節約に。")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    Spacer().frame(height: 20)
                }
            }
            .navigationTitle("ちりつも作戦")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("閉じる") { dismiss() } } }
        }
    }
}

// MARK: - 共通詳細シート
struct InfoDetailSheet: View {
    let emoji: String
    let title: String
    let description: String
    let accentColor: Color
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.12))
                            .frame(width: 90, height: 90)
                        Text(emoji).font(.system(size: 46))
                    }
                    .padding(.top, 24)

                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColor.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Text(description)
                        .font(.system(size: 15))
                        .foregroundColor(AppColor.textSecondary)
                        .lineSpacing(5)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 20)
                }
            }

            // ── ボタン行：閉じる ＋ 学んだ ──
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Text("閉じる")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(AppColor.sectionBackground)
                        .cornerRadius(14)
                }

                Button(action: {
                    dismiss()
                    // シートが閉じた後にやりくりん褒めを表示
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                        appState.triggerPraise()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                        Text("学んだ")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(accentColor)
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .padding(.top, 8)
        }
        .background(AppColor.background.ignoresSafeArea())
    }
}
