import SwiftUI

// MARK: - 増やすタブ コンテンツ
struct GrowTabContent: View {
    @EnvironmentObject var appState: AppState

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        LazyVStack(spacing: 16) {
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

// MARK: - 増やす グリッドカード（3列用）
struct GrowGridCard: View {
    @EnvironmentObject var appState: AppState
    let emoji: String
    let title: String
    let tagColor: Color
    let description: String
    @State private var showDetail = false

    var body: some View {
        Button(action: {
            showDetail = true
            appState.recordCardView(emoji: emoji, title: title, category: .grow)
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
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(tagColor.opacity(0.25), lineWidth: 1.2))
            .shadow(color: AppColor.shadowColor, radius: 4, x: 0, y: 2)
        }
        .sheet(isPresented: $showDetail) {
            InfoDetailSheet(emoji: emoji, title: title, description: description, accentColor: tagColor)
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
                            GrowGridCard(emoji: "🌏", title: "翻訳・英語副業", tagColor: Color.blue.opacity(0.75),
                                description: "英語が得意なら翻訳副業は時給換算で高単価。DeepLを補助に使いながら精度を高める「後編集翻訳（MTPE）」はAI時代の新しい働き方。ランサーズや専門翻訳会社への登録で案件を取得できます。")
                            GrowGridCard(emoji: "🏠", title: "スペース貸し・民泊", tagColor: Color.brown.opacity(0.7),
                                description: "使っていない駐車場・空き部屋をakippaやAirbnbで貸し出すと毎月収入が得られます。都市部では駐車場1台で月2〜5万円も。初期費用ほぼゼロで始められます。")
                            GrowGridCard(emoji: "📸", title: "ストック素材販売", tagColor: Color.green.opacity(0.75),
                                description: "スマホで撮った写真・AIで生成したイラストをPIXTAやAdobe Stockに登録すると、ダウンロードごとに収入に。一度登録すれば自動で稼いでくれるストック型の不労所得です。")
                            GrowGridCard(emoji: "🎨", title: "ハンドメイド・Minne販売", tagColor: Color.pink.opacity(0.7),
                                description: "手作りアクセサリー・イラスト・デジタルデータをMinneやCreemaで販売。デジタルデータ（壁紙・テンプレート等）は在庫ゼロで何度でも売れます。材料費と売値を計算してから始めましょう。")
                            GrowGridCard(emoji: "🎥", title: "YouTube・ショート動画", tagColor: Color.red.opacity(0.65),
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
