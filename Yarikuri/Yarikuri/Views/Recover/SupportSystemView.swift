import SwiftUI

// MARK: - 制度・給付・支援画面
struct SupportSystemView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: SystemCategory? = nil
    @State private var showPrefectureSelect = false

    private var userPref: String { appState.prefecture }
    private var userCity: String { appState.userProfile?.municipality ?? "" }

    private var systems: [SupportSystem] {
        SupportSystem.sampleData(for: appState.userProfile)
    }

    private var filteredSystems: [SupportSystem] {
        var result = systems.filter { s in
            if s.isNational { return true }
            guard !userPref.isEmpty else { return false }
            // 市区町村レベルのマッチ
            if !userCity.isEmpty && !s.municipalities.isEmpty {
                return s.municipalities.contains(userCity)
            }
            return s.prefectures.contains(userPref)
        }
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        return result
    }

    private var localCount: Int {
        systems.filter { !$0.isNational && $0.prefectures.contains(userPref) }.count
    }

    private var cityLocalCount: Int {
        guard !userCity.isEmpty else { return 0 }
        return systems.filter { !$0.municipalities.isEmpty && $0.municipalities.contains(userCity) }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        // 地域設定バナー
                        prefectureBanner

                        // フィルター
                        categoryFilter

                        // 地域限定件数バッジ
                        if !userPref.isEmpty && localCount > 0 {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(AppColor.secondary)
                                    .font(.system(size: 13))
                                VStack(alignment: .leading, spacing: 1) {
                                    let cityLabel = userCity.isEmpty ? userPref : "\(userPref)・\(userCity)"
                                    Text("\(cityLabel)の地域制度 \(localCount)件")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColor.secondary)
                                    if cityLocalCount > 0 {
                                        Text("うち\(userCity)専用 \(cityLocalCount)件")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColor.tertiary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                        }

                        // 制度リスト
                        ForEach(filteredSystems) { system in
                            SupportSystemCard(system: system)
                        }

                        disclaimerCard
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("使える制度・支援")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showPrefectureSelect = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.system(size: 13))
                            if userPref.isEmpty {
                                Text("地域設定")
                                    .font(.system(size: 13))
                            } else if !userCity.isEmpty {
                                Text("\(userCity)")
                                    .font(.system(size: 13))
                            } else {
                                Text(userPref)
                                    .font(.system(size: 13))
                            }
                        }
                        .foregroundColor(AppColor.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
        .sheet(isPresented: $showPrefectureSelect) {
            PrefectureSelectSheet()
        }
    }

    // MARK: - 地域設定バナー
    private var prefectureBanner: some View {
        Button(action: { showPrefectureSelect = true }) {
            HStack(spacing: 12) {
                Text("📍").font(.system(size: 24))
                VStack(alignment: .leading, spacing: 3) {
                    if userPref.isEmpty {
                        Text("あなたの地域を設定しよう 📍")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)
                        Text("地域を選ぶと、あなたの街だけの支援も見られます")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textSecondary)
                    } else {
                        HStack(spacing: 4) {
                            Text(userPref).font(.system(size: 14, weight: .semibold)).foregroundColor(AppColor.textPrimary)
                            if !userCity.isEmpty {
                                Text("›").foregroundColor(AppColor.textTertiary)
                                Text(userCity).font(.system(size: 14, weight: .semibold)).foregroundColor(AppColor.primary)
                            }
                        }
                        Text(userCity.isEmpty ? "市区町村をタップして絞り込む" : "タップして変更")
                            .font(.system(size: 11))
                            .foregroundColor(AppColor.textTertiary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
            }
            .padding(14)
            .background(userPref.isEmpty ? AppColor.primaryLight : AppColor.sectionBackground)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColor.primary.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "すべて", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(SystemCategory.allCases, id: \.rawValue) { cat in
                    FilterChip(title: "\(cat.emoji) \(cat.displayText)", isSelected: selectedCategory == cat) {
                        selectedCategory = selectedCategory == cat ? nil : cat
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var disclaimerCard: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundColor(AppColor.textTertiary)
                .font(.system(size: 13))
                .padding(.top, 1)
            Text("制度はいつか変わることがあります。必ず公式サイトや窓口で確認してね。")
                .font(.system(size: 12))
                .foregroundColor(AppColor.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(AppColor.sectionBackground)
        .cornerRadius(10)
    }
}

// MARK: - 制度カード
private struct SupportSystemCard: View {
    let system: SupportSystem
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.spring(response: 0.3)) { isExpanded.toggle() } }) {
                HStack(spacing: 12) {
                    Text(system.emoji)
                        .font(.system(size: 24))
                        .frame(width: 44, height: 44)
                        .background(AppColor.tertiaryLight)
                        .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(system.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColor.textPrimary)
                            Text(system.category.displayText)
                                .font(.system(size: 10))
                                .foregroundColor(AppColor.tertiary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColor.tertiaryLight)
                                .cornerRadius(4)
                            // 地域限定バッジ
                            if !system.isNational {
                                Text("📍 地域")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColor.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColor.secondaryLight)
                                    .cornerRadius(4)
                            }
                        }
                        Text(system.summary)
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(system.benefit)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppColor.secondary)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textTertiary)
                    }
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().padding(.horizontal, 14)

                VStack(alignment: .leading, spacing: 10) {
                    Text(system.detail)
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)

                    if !system.eligibility.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("👤 こんな人がもらえます")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppColor.textSecondary)
                            ForEach(system.eligibility, id: \.self) { item in
                                HStack(spacing: 6) {
                                    Circle().fill(AppColor.secondary).frame(width: 5, height: 5)
                                    Text(item).font(.system(size: 13)).foregroundColor(AppColor.textPrimary)
                                }
                            }
                        }
                    }

                    HStack {
                        Text("📞 相談窓口: \(system.contact)")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textTertiary)
                        Spacer()
                    }
                }
                .padding(14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppColor.cardBackground)
        .cornerRadius(14)
        .shadow(color: AppColor.shadowColor, radius: 5)
    }
}

// MARK: - フィルターチップ
private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? AppColor.primary : AppColor.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppColor.primaryLight : AppColor.cardBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? AppColor.primary : AppColor.sectionBackground, lineWidth: 1)
                )
        }
    }
}

// MARK: - 都道府県選択シート
struct PrefectureSelectSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedPref: String = ""
    @State private var step: Int = 1   // 1=都道府県, 2=市区町村

    static let allPrefectures: [String] = [
        "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
        "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
        "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県",
        "岐阜県", "静岡県", "愛知県", "三重県",
        "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県",
        "鳥取県", "島根県", "岡山県", "広島県", "山口県",
        "徳島県", "香川県", "愛媛県", "高知県",
        "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
    ]

    // 主要な市区町村（全47都道府県）
    static let municipalitiesByPref: [String: [String]] = [
        "北海道": ["札幌市", "旭川市", "函館市", "釧路市", "帯広市", "北見市", "小樽市", "苫小牧市", "江別市", "岩見沢市", "室蘭市", "千歳市", "根室市", "網走市", "紋別市", "稚内市", "名寄市", "留萌市"],
        "青森県": ["青森市", "八戸市", "弘前市", "十和田市", "三沢市", "むつ市", "五所川原市", "黒石市", "平川市", "つがる市"],
        "岩手県": ["盛岡市", "一関市", "奥州市", "花巻市", "北上市", "宮古市", "大船渡市", "久慈市", "釜石市", "二戸市", "陸前高田市"],
        "宮城県": ["仙台市", "石巻市", "大崎市", "気仙沼市", "名取市", "多賀城市", "塩竈市", "登米市", "栗原市", "東松島市", "白石市", "角田市"],
        "秋田県": ["秋田市", "横手市", "大仙市", "能代市", "湯沢市", "由利本荘市", "男鹿市", "にかほ市", "北秋田市", "鹿角市"],
        "山形県": ["山形市", "鶴岡市", "酒田市", "米沢市", "天童市", "上山市", "新庄市", "長井市", "村山市", "南陽市"],
        "福島県": ["福島市", "郡山市", "いわき市", "会津若松市", "白河市", "須賀川市", "喜多方市", "二本松市", "相馬市", "南相馬市", "伊達市", "本宮市"],
        "茨城県": ["水戸市", "つくば市", "日立市", "土浦市", "古河市", "ひたちなか市", "取手市", "筑西市", "守谷市", "常総市", "坂東市", "神栖市"],
        "栃木県": ["宇都宮市", "小山市", "栃木市", "足利市", "那須塩原市", "佐野市", "鹿沼市", "日光市", "真岡市", "大田原市", "矢板市"],
        "群馬県": ["前橋市", "高崎市", "伊勢崎市", "太田市", "桐生市", "渋川市", "館林市", "富岡市", "安中市", "みどり市", "沼田市"],
        "埼玉県": ["さいたま市", "川口市", "越谷市", "所沢市", "川越市", "熊谷市", "草加市", "春日部市", "上尾市", "狭山市", "行田市", "加須市", "鴻巣市", "東松山市", "朝霞市", "志木市", "和光市", "新座市", "富士見市", "ふじみ野市"],
        "千葉県": ["千葉市", "船橋市", "松戸市", "市川市", "柏市", "八千代市", "浦安市", "市原市", "習志野市", "我孫子市", "流山市", "四街道市", "佐倉市", "成田市", "銚子市", "木更津市"],
        "東京都": ["千代田区", "中央区", "港区", "新宿区", "文京区", "台東区", "墨田区", "江東区", "品川区", "目黒区", "大田区", "世田谷区", "渋谷区", "中野区", "杉並区", "豊島区", "北区", "荒川区", "板橋区", "練馬区", "足立区", "葛飾区", "江戸川区", "八王子市", "立川市", "武蔵野市", "三鷹市", "府中市", "調布市", "町田市", "小金井市", "東村山市", "国分寺市", "多摩市"],
        "神奈川県": ["横浜市", "川崎市", "相模原市", "横須賀市", "藤沢市", "平塚市", "厚木市", "茅ヶ崎市", "大和市", "小田原市", "秦野市", "鎌倉市", "逗子市", "三浦市", "海老名市", "座間市"],
        "新潟県": ["新潟市", "長岡市", "上越市", "三条市", "新発田市", "小千谷市", "柏崎市", "加茂市", "十日町市", "燕市", "村上市", "魚沼市", "南魚沼市", "阿賀野市"],
        "富山県": ["富山市", "高岡市", "射水市", "魚津市", "砺波市", "小矢部市", "南砺市", "滑川市", "黒部市", "氷見市"],
        "石川県": ["金沢市", "白山市", "小松市", "加賀市", "七尾市", "野々市市", "輪島市", "珠洲市", "羽咋市", "かほく市"],
        "福井県": ["福井市", "敦賀市", "越前市", "坂井市", "鯖江市", "小浜市", "あわら市", "大野市", "勝山市"],
        "山梨県": ["甲府市", "甲斐市", "笛吹市", "山梨市", "富士吉田市", "都留市", "韮崎市", "北杜市", "中央市", "南アルプス市"],
        "長野県": ["長野市", "松本市", "上田市", "飯田市", "佐久市", "諏訪市", "伊那市", "茅野市", "駒ヶ根市", "塩尻市", "安曇野市", "須坂市", "中野市", "大町市"],
        "岐阜県": ["岐阜市", "大垣市", "各務原市", "可児市", "高山市", "多治見市", "関市", "中津川市", "羽島市", "美濃加茂市", "土岐市", "恵那市"],
        "静岡県": ["静岡市", "浜松市", "沼津市", "富士市", "磐田市", "焼津市", "掛川市", "藤枝市", "島田市", "富士宮市", "三島市", "袋井市", "裾野市"],
        "愛知県": ["名古屋市", "豊田市", "豊橋市", "岡崎市", "一宮市", "春日井市", "豊川市", "安城市", "西尾市", "刈谷市", "小牧市", "稲沢市", "東海市", "大府市", "蒲郡市", "知立市", "半田市", "瀬戸市"],
        "三重県": ["津市", "四日市市", "伊勢市", "松阪市", "鈴鹿市", "桑名市", "伊賀市", "亀山市", "志摩市", "名張市", "尾鷲市", "熊野市"],
        "滋賀県": ["大津市", "草津市", "彦根市", "長浜市", "東近江市", "栗東市", "甲賀市", "近江八幡市", "守山市", "湖南市", "野洲市", "高島市"],
        "京都府": ["京都市", "宇治市", "亀岡市", "城陽市", "長岡京市", "向日市", "八幡市", "京田辺市", "南丹市", "木津川市", "舞鶴市", "福知山市", "綾部市", "宮津市", "京丹後市"],
        "大阪府": ["大阪市", "堺市", "東大阪市", "豊中市", "高槻市", "枚方市", "八尾市", "寝屋川市", "吹田市", "茨木市", "岸和田市", "和泉市", "守口市", "富田林市", "松原市", "大東市", "門真市", "摂津市", "高石市", "藤井寺市", "泉大津市", "泉佐野市"],
        "兵庫県": ["神戸市", "姫路市", "西宮市", "尼崎市", "明石市", "加古川市", "宝塚市", "伊丹市", "川西市", "三田市", "芦屋市", "豊岡市", "相生市", "龍野市", "洲本市", "淡路市"],
        "奈良県": ["奈良市", "橿原市", "生駒市", "大和郡山市", "天理市", "桜井市", "大和高田市", "葛城市", "香芝市", "宇陀市", "五條市"],
        "和歌山県": ["和歌山市", "橋本市", "田辺市", "新宮市", "海南市", "有田市", "御坊市", "岩出市"],
        "鳥取県": ["鳥取市", "米子市", "倉吉市", "境港市"],
        "島根県": ["松江市", "出雲市", "浜田市", "益田市", "大田市", "安来市", "江津市", "雲南市"],
        "岡山県": ["岡山市", "倉敷市", "津山市", "総社市", "玉野市", "笠岡市", "井原市", "高梁市", "真庭市", "新見市", "備前市", "瀬戸内市", "赤磐市", "浅口市"],
        "広島県": ["広島市", "福山市", "呉市", "東広島市", "尾道市", "廿日市市", "府中市", "三次市", "庄原市", "大竹市", "竹原市", "江田島市"],
        "山口県": ["山口市", "下関市", "宇部市", "周南市", "防府市", "岩国市", "光市", "萩市", "長門市", "柳井市", "美祢市"],
        "徳島県": ["徳島市", "鳴門市", "阿南市", "吉野川市", "阿波市", "美馬市", "三好市", "小松島市", "阿南市"],
        "香川県": ["高松市", "丸亀市", "観音寺市", "さぬき市", "東かがわ市", "三豊市", "坂出市", "善通寺市"],
        "愛媛県": ["松山市", "今治市", "新居浜市", "西条市", "宇和島市", "四国中央市", "大洲市", "伊予市", "東温市"],
        "高知県": ["高知市", "南国市", "四万十市", "香南市", "香美市", "安芸市", "土佐市", "須崎市", "宿毛市"],
        "福岡県": ["福岡市", "北九州市", "久留米市", "飯塚市", "春日市", "大野城市", "宗像市", "太宰府市", "行橋市", "小郡市", "筑紫野市", "朝倉市", "みやま市", "古賀市", "糟屋郡"],
        "佐賀県": ["佐賀市", "唐津市", "鳥栖市", "伊万里市", "武雄市", "鹿島市", "多久市", "嬉野市", "小城市"],
        "長崎県": ["長崎市", "佐世保市", "諫早市", "大村市", "島原市", "対馬市", "雲仙市", "南島原市", "平戸市", "松浦市"],
        "熊本県": ["熊本市", "八代市", "天草市", "荒尾市", "水俣市", "玉名市", "山鹿市", "菊池市", "宇土市", "上天草市", "宇城市", "阿蘇市", "合志市"],
        "大分県": ["大分市", "別府市", "中津市", "日田市", "佐伯市", "臼杵市", "杵築市", "豊後大野市", "由布市", "竹田市", "豊後高田市"],
        "宮崎県": ["宮崎市", "都城市", "延岡市", "日南市", "小林市", "日向市", "串間市", "西都市", "えびの市"],
        "鹿児島県": ["鹿児島市", "霧島市", "鹿屋市", "薩摩川内市", "出水市", "指宿市", "南さつま市", "南九州市", "姶良市", "伊佐市", "奄美市"],
        "沖縄県": ["那覇市", "沖縄市", "うるま市", "宜野湾市", "浦添市", "名護市", "糸満市", "豊見城市", "石垣市", "宮古島市", "南城市", "北谷町", "読谷村"],
    ]

    private var filteredPrefectures: [String] {
        searchText.isEmpty ? Self.allPrefectures
            : Self.allPrefectures.filter { $0.contains(searchText) }
    }

    private var citiesForPref: [String] {
        Self.municipalitiesByPref[selectedPref] ?? []
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    if step == 1 {
                        // Step 1: 都道府県を選ぶ
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass").foregroundColor(AppColor.textTertiary)
                            TextField("都道府県を検索", text: $searchText).font(.system(size: 15))
                        }
                        .padding(10)
                        .background(AppColor.cardBackground)
                        .cornerRadius(10)
                        .padding(.horizontal, 16).padding(.vertical, 10)

                        List {
                            Button(action: {
                                appState.updatePrefecture("")
                                appState.userProfile?.municipality = ""
                                dismiss()
                            }) {
                                HStack {
                                    Text("設定しない").foregroundColor(AppColor.textSecondary)
                                    Spacer()
                                    if appState.prefecture.isEmpty {
                                        Image(systemName: "checkmark").foregroundColor(AppColor.primary)
                                    }
                                }
                            }
                            ForEach(filteredPrefectures, id: \.self) { pref in
                                Button(action: {
                                    selectedPref = pref
                                    appState.updatePrefecture(pref)
                                    appState.userProfile?.municipality = ""
                                    searchText = ""
                                    step = 2
                                }) {
                                    HStack {
                                        Text(pref).foregroundColor(AppColor.textPrimary)
                                        Spacer()
                                        if appState.prefecture == pref {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppColor.primary)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    } else {
                        // Step 2: 市区町村を選ぶ
                        List {
                            Button(action: {
                                appState.userProfile?.municipality = ""
                                dismiss()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("市区町村は設定しない")
                                            .foregroundColor(AppColor.textSecondary)
                                        Text("\(selectedPref)全体の制度を表示")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColor.textTertiary)
                                    }
                                    Spacer()
                                    if (appState.userProfile?.municipality ?? "").isEmpty {
                                        Image(systemName: "checkmark").foregroundColor(AppColor.primary)
                                    }
                                }
                            }

                            if !citiesForPref.isEmpty {
                                Section(header: Text("主要な市区町村")) {
                                    ForEach(citiesForPref, id: \.self) { city in
                                        Button(action: {
                                            appState.userProfile?.municipality = city
                                            dismiss()
                                        }) {
                                            HStack {
                                                Text(city).foregroundColor(AppColor.textPrimary)
                                                Spacer()
                                                if appState.userProfile?.municipality == city {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(AppColor.primary)
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("主要な市区町村データがまだありません")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColor.textTertiary)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle(step == 1 ? "都道府県を選択" : selectedPref)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(step == 1 ? "キャンセル" : "戻る") {
                        if step == 1 { dismiss() } else { step = 1 }
                    }
                }
            }
            .onAppear {
                selectedPref = appState.prefecture
            }
        }
    }
}

// MARK: - 制度データモデル
struct SupportSystem: Identifiable {
    var id = UUID()
    var name: String
    var emoji: String
    var summary: String
    var detail: String
    var benefit: String
    var category: SystemCategory
    var eligibility: [String]
    var contact: String
    var prefectures: [String] = []      // 空 = 全国共通
    var municipalities: [String] = []   // 空 = 都道府県全体、指定あり = 市区町村限定

    var isNational: Bool { prefectures.isEmpty }

    static func sampleData(for profile: UserProfile?) -> [SupportSystem] {
        var systems: [SupportSystem] = []

        // ── 全国共通：生活支援 ────────────────────────────────
        systems.append(SupportSystem(
            name: "住民税非課税世帯給付",
            emoji: "🏛️",
            summary: "低所得世帯への現金給付",
            detail: "住民税が非課税の世帯に対して、国・自治体から給付金が支給されます。物価高騰対応として複数回にわたって実施されており、金額は数万円〜となっています。",
            benefit: "数万円〜",
            category: .livingSupport,
            eligibility: ["住民税非課税世帯", "均等割のみ課税世帯"],
            contact: "お住まいの市区町村窓口"
        ))
        systems.append(SupportSystem(
            name: "住宅確保給付金",
            emoji: "🏠",
            summary: "家賃を自治体が直接支払う制度",
            detail: "離職・廃業などで住居を失うおそれがある方に、原則3ヶ月（最長9ヶ月）家賃相当額を自治体が家主へ直接支払います。求職活動が条件です。",
            benefit: "家賃相当額（地域上限あり）",
            category: .livingSupport,
            eligibility: ["離職・廃業から2年以内", "収入・資産が一定以下", "ハローワーク等で求職活動中"],
            contact: "居住地の自立相談支援機関"
        ))
        systems.append(SupportSystem(
            name: "生活保護",
            emoji: "🤲",
            summary: "最低限の生活を国が保障する制度",
            detail: "収入・資産が一定基準を下回る場合に、生活費・住宅費・医療費などを国が支給する制度です。条件を満たせば受給できます。",
            benefit: "生活費・住宅費・医療費等",
            category: .livingSupport,
            eligibility: ["収入と資産が最低生活費を下回る", "利用できる資産・能力をすべて活用している"],
            contact: "お住まいの福祉事務所"
        ))
        systems.append(SupportSystem(
            name: "電気・ガス料金の補助",
            emoji: "💡",
            summary: "光熱費の値上がりを政府が補助",
            detail: "物価高騰対策として、電気・都市ガス料金に対して政府が補助金を出す制度が実施されています。補助額や期間は変わりますので、最新情報をご確認ください。",
            benefit: "月数百円〜数千円の割引",
            category: .livingSupport,
            eligibility: ["電力・ガス契約者全員（自動適用）"],
            contact: "資源エネルギー庁 公式サイト"
        ))

        // ── 全国共通：医療・年金 ──────────────────────────────
        systems.append(SupportSystem(
            name: "高額療養費制度",
            emoji: "🏥",
            summary: "1ヶ月の医療費に上限を設ける",
            detail: "1ヶ月の自己負担医療費が一定額を超えた場合、超えた分が払い戻されます。年収約370万円以下なら自己負担上限は月約5.7万円。限度額認定証を事前に取得すると窓口での支払いも抑えられます。",
            benefit: "医療費の一部〜大部分",
            category: .medical,
            eligibility: ["健康保険・国民健康保険の加入者", "1ヶ月の医療費が上限額を超えた方"],
            contact: "加入している健康保険組合または市区町村"
        ))
        systems.append(SupportSystem(
            name: "傷病手当金",
            emoji: "💊",
            summary: "病気・怪我で休業中の生活を補償",
            detail: "業務外の病気や怪我で連続3日以上休業した場合、4日目から最大1年6ヶ月、標準報酬日額の約2/3が支給されます。",
            benefit: "給与の約2/3",
            category: .medical,
            eligibility: ["協会けんぽ・健保組合の被保険者", "業務外の病気・怪我による休業"],
            contact: "加入している健康保険組合"
        ))
        systems.append(SupportSystem(
            name: "障害年金",
            emoji: "♿",
            summary: "障害を負った場合に受け取れる年金",
            detail: "病気や怪我で障害状態になった場合に受給できる公的年金です。精神疾患・内部障害も対象になります。",
            benefit: "月約6.6万〜16万円（等級・加入歴による）",
            category: .medical,
            eligibility: ["初診日に年金に加入していた", "一定の保険料納付要件を満たす", "障害等級1〜3級に該当"],
            contact: "近くの年金事務所・街角の年金相談センター"
        ))
        systems.append(SupportSystem(
            name: "医療費控除",
            emoji: "🧾",
            summary: "年間の医療費が10万円超なら税が戻る",
            detail: "1年間に支払った医療費が10万円を超えた場合、確定申告で所得控除が受けられます。通院交通費も対象です。",
            benefit: "超過分×所得税率分が還付",
            category: .medical,
            eligibility: ["年間医療費が10万円（または所得の5%）を超えた方"],
            contact: "最寄りの税務署・e-Tax"
        ))

        // ── 全国共通：子育て ──────────────────────────────────
        if profile?.hasChildren == true {
            systems.append(SupportSystem(
                name: "児童手当",
                emoji: "👶",
                summary: "子育て世帯への月次手当",
                detail: "0歳から高校卒業まで（18歳年度末まで）支給。月額は3歳未満1.5万円、3歳〜高校生1万円（第3子以降は3万円）。2024年10月から所得制限撤廃・高校生も対象。",
                benefit: "月1〜3万円",
                category: .childcare,
                eligibility: ["0歳〜18歳年度末の子どもを養育する方"],
                contact: "お住まいの市区町村窓口"
            ))
            systems.append(SupportSystem(
                name: "幼児教育・保育の無償化",
                emoji: "🏫",
                summary: "3歳〜5歳の保育料が原則無料",
                detail: "幼稚園・保育所・認定こども園等を利用する3〜5歳児の保育料が無償化。0〜2歳も住民税非課税世帯は無料です。",
                benefit: "保育料が無料〜大幅減",
                category: .childcare,
                eligibility: ["3歳〜5歳の就学前児童", "0〜2歳の住民税非課税世帯"],
                contact: "お住まいの市区町村窓口"
            ))
            systems.append(SupportSystem(
                name: "子どもの医療費助成",
                emoji: "🩺",
                summary: "子どもの医療費を自治体が補助",
                detail: "ほとんどの自治体で、子どもの医療費の自己負担分を助成しています。対象年齢や内容は自治体ごとに異なります。",
                benefit: "医療費の自己負担ほぼ0円",
                category: .childcare,
                eligibility: ["自治体が定める年齢までの子ども"],
                contact: "お住まいの市区町村窓口"
            ))
        }

        // ── 全国共通：就労・スキル ────────────────────────────
        systems.append(SupportSystem(
            name: "雇用保険（失業給付）",
            emoji: "📋",
            summary: "退職後に受け取れる生活支援給付",
            detail: "会社都合退職なら待機期間なし、自己都合退職でも2ヶ月後から受給できます。給付日額は前職賃金の50〜80%。受給期間は90〜360日。",
            benefit: "前職賃金の50〜80%",
            category: .employment,
            eligibility: ["雇用保険加入期間が12ヶ月以上（自己都合）または6ヶ月以上（会社都合）", "求職活動中"],
            contact: "最寄りのハローワーク"
        ))
        systems.append(SupportSystem(
            name: "教育訓練給付金",
            emoji: "📖",
            summary: "資格取得費用の最大70%が戻る",
            detail: "厚生労働省指定の講座（簿記・ITパスポート・看護師等）を受講した場合、費用の20〜70%（上限56万円/年）が支給されます。",
            benefit: "受講費の20〜70%",
            category: .employment,
            eligibility: ["雇用保険の被保険者期間が1年以上（または離職後1年以内）"],
            contact: "最寄りのハローワーク"
        ))
        systems.append(SupportSystem(
            name: "求職者支援制度",
            emoji: "🤝",
            summary: "雇用保険未加入者でも職業訓練+給付金",
            detail: "雇用保険に入っていない方やフリーランスでも、無料の職業訓練を受けながら月10万円の職業訓練受講給付金を受け取れます。",
            benefit: "月10万円＋交通費",
            category: .employment,
            eligibility: ["雇用保険を受給できない求職者", "収入・資産が一定以下"],
            contact: "最寄りのハローワーク"
        ))

        // ── 全国共通：税制 ────────────────────────────────────
        systems.append(SupportSystem(
            name: "ふるさと納税",
            emoji: "🎁",
            summary: "実質2,000円で返礼品をもらいながら節税",
            detail: "任意の自治体に寄付することで、住民税・所得税から寄付額−2,000円が控除されます。年収や家族構成で上限額が変わります。",
            benefit: "寄付額−2,000円が税額控除",
            category: .tax,
            eligibility: ["所得税・住民税の納税者"],
            contact: "各ふるさと納税ポータルサイト"
        ))
        systems.append(SupportSystem(
            name: "iDeCo（個人型確定拠出年金）",
            emoji: "🐷",
            summary: "掛け金が全額所得控除になる老後の積立",
            detail: "毎月の掛け金（月5,000円〜）が全額所得控除になります。運用益も非課税。60歳以降に受け取り時も優遇あり。",
            benefit: "掛け金の全額が所得控除",
            category: .tax,
            eligibility: ["20〜65歳未満の方（条件あり）", "国民年金・厚生年金の加入者"],
            contact: "証券会社・銀行等"
        ))
        systems.append(SupportSystem(
            name: "住宅ローン控除",
            emoji: "🏡",
            summary: "ローン残高の0.7%が毎年税額控除",
            detail: "住宅ローンを使って住宅を取得した場合、年末ローン残高の0.7%（最大35万円/年）が最大13年間控除されます。",
            benefit: "最大35万円/年×最大13年",
            category: .tax,
            eligibility: ["住宅ローンで自己居住用住宅を取得", "合計所得2,000万円以下"],
            contact: "最寄りの税務署・e-Tax"
        ))

        // ── 全国共通：貸付 ────────────────────────────────────
        systems.append(SupportSystem(
            name: "生活福祉資金貸付制度",
            emoji: "💴",
            summary: "低所得世帯向けの無利子・低利子貸付",
            detail: "生活費・教育費・福祉用具購入など目的に合わせた種類があります。無利子〜年1.5%と低利です。",
            benefit: "無利子〜年1.5%",
            category: .loan,
            eligibility: ["低所得世帯", "障害者世帯", "高齢者世帯"],
            contact: "お住まいの都道府県社会福祉協議会"
        ))
        systems.append(SupportSystem(
            name: "緊急小口資金",
            emoji: "🆘",
            summary: "急な出費に最大20万円を無利子で貸付",
            detail: "病気や怪我、災害などで緊急に資金が必要な場合に最大20万円を無利子で貸し付ける制度です。原則1〜2週間で振り込まれます。",
            benefit: "最大20万円（無利子）",
            category: .loan,
            eligibility: ["緊急かつ一時的に生計が成り立たなくなった世帯"],
            contact: "お住まいの市区町村社会福祉協議会"
        ))

        // ── 東京都限定 ────────────────────────────────────────
        systems.append(SupportSystem(
            name: "東京都ひとり親家庭支援給付金",
            emoji: "👨‍👧",
            summary: "都独自のひとり親支援（国の制度に上乗せ）",
            detail: "東京都は国の児童扶養手当に加え、独自の給付金や生活支援を充実させています。高校生年齢の子どもを持つひとり親への支援も手厚くなっています。",
            benefit: "月額上乗せ給付あり",
            category: .childcare,
            eligibility: ["都内在住のひとり親世帯", "所得が一定以下"],
            contact: "お住まいの区市町村窓口",
            prefectures: ["東京都"]
        ))
        systems.append(SupportSystem(
            name: "東京都医療費助成（マル福）",
            emoji: "🏥",
            summary: "障がい者・ひとり親等の医療費を都が助成",
            detail: "重度心身障がい者、ひとり親家庭、乳幼児等を対象に、医療費の自己負担分を東京都が助成する制度。「マル障」「マル親」「マル乳」など複数の種類があります。",
            benefit: "医療費自己負担分の大半〜全額",
            category: .medical,
            eligibility: ["都内在住の障がい者・ひとり親・乳幼児等（種類による）"],
            contact: "お住まいの区市町村窓口",
            prefectures: ["東京都"]
        ))
        systems.append(SupportSystem(
            name: "TOKYOゼロエミポイント",
            emoji: "🌿",
            summary: "省エネ家電への買い替えでポイント還元",
            detail: "エアコン・冷蔵庫・給湯器等の省エネ性能の高い製品に買い替えると、商品券等と交換できるポイントが付与されます。1台あたり最大40,000ポイント。",
            benefit: "最大40,000ポイント（1台）",
            category: .livingSupport,
            eligibility: ["都内在住で対象省エネ製品に買い替えた方"],
            contact: "TOKYOゼロエミポイント事務局",
            prefectures: ["東京都"]
        ))

        // ── 大阪府限定 ────────────────────────────────────────
        systems.append(SupportSystem(
            name: "大阪府・大阪市 節電プログラム",
            emoji: "💡",
            summary: "節電への取り組みでポイントを付与",
            detail: "大阪府・大阪市が実施する節電プログラムへ参加することで、電気料金の削減に加えてポイントや特典を受け取れます。スマートメーター設置済みの契約者が対象です。",
            benefit: "参加特典・ポイント付与",
            category: .livingSupport,
            eligibility: ["府内・市内在住の電力契約者（スマートメーター設置済み）"],
            contact: "大阪府・大阪市 省エネ推進課",
            prefectures: ["大阪府"]
        ))
        systems.append(SupportSystem(
            name: "おおさか・住まいサポートセンター",
            emoji: "🏠",
            summary: "住まいに関する総合相談・補助制度",
            detail: "家賃補助・空き家活用・バリアフリー改修等、大阪府独自の住まい支援制度を一括相談できます。若者・子育て世帯向けの家賃補助（最大月3万円）もあります。",
            benefit: "家賃補助最大月3万円など",
            category: .livingSupport,
            eligibility: ["府内在住・移住予定の方", "若者・子育て世帯（条件あり）"],
            contact: "おおさか・住まいサポートセンター",
            prefectures: ["大阪府"]
        ))

        // ── 神奈川県限定 ──────────────────────────────────────
        systems.append(SupportSystem(
            name: "かながわ子育て応援パスポート",
            emoji: "🎫",
            summary: "子育て世帯に各種割引・優待サービス",
            detail: "18歳未満の子を持つ世帯や妊娠中の方が対象。県内の施設・店舗で割引や優待サービスが受けられます。加盟店は2,000店舗以上。",
            benefit: "各種割引・優待（加盟店多数）",
            category: .childcare,
            eligibility: ["県内在住の妊婦または18歳未満の子を持つ方"],
            contact: "神奈川県子ども家庭課",
            prefectures: ["神奈川県"]
        ))
        systems.append(SupportSystem(
            name: "かながわ移住促進奨学金返還支援",
            emoji: "🎓",
            summary: "県外出身者が神奈川に移住で奨学金を支援",
            detail: "県外から神奈川に移住し、対象職種（IT・医療・農業等）に就職した方の奨学金返還を最大120万円補助する制度です。",
            benefit: "最大120万円の返還補助",
            category: .loan,
            eligibility: ["県外出身で県内に移住・就職した方", "対象職種・年齢条件あり"],
            contact: "神奈川県未来創生課",
            prefectures: ["神奈川県"]
        ))

        // ── 愛知県限定 ────────────────────────────────────────
        systems.append(SupportSystem(
            name: "あいちの木の家助成金",
            emoji: "🌲",
            summary: "県産木材を使った住宅に助成",
            detail: "愛知県産の木材を一定量使用して住宅を新築・リフォームした方に、費用の一部を補助します。最大50万円の助成金が受けられます。",
            benefit: "最大50万円",
            category: .livingSupport,
            eligibility: ["愛知県産材を規定量以上使用した住宅の建築・改修を行う方"],
            contact: "愛知県農林基盤局 森林保全課",
            prefectures: ["愛知県"]
        ))
        systems.append(SupportSystem(
            name: "愛知県給付型奨学金",
            emoji: "📖",
            summary: "愛知県内の大学等に在籍する学生への支援",
            detail: "家庭の経済状況が厳しい学生に対し、返済不要の給付型奨学金を支給します。月額2〜4万円、学業成績や家庭の収入基準があります。",
            benefit: "月2〜4万円（給付型）",
            category: .employment,
            eligibility: ["県内の大学・専門学校等に在籍", "家計基準・学業基準を満たす方"],
            contact: "愛知県教育委員会 学習支援課",
            prefectures: ["愛知県"]
        ))

        // ── 埼玉県限定 ────────────────────────────────────────
        systems.append(SupportSystem(
            name: "埼玉県新婚・子育て世帯向け移住支援金",
            emoji: "💒",
            summary: "東京圏から埼玉に移住した新婚・子育て世帯に給付",
            detail: "東京圏（東京・神奈川・千葉）から埼玉に移住し、テレワーク等で就業または対象就職をした世帯に最大100万円（子ども加算あり）が支給されます。",
            benefit: "最大100万円（子ども加算あり）",
            category: .livingSupport,
            eligibility: ["東京圏から埼玉に移住した方", "テレワーク就業または対象就職"],
            contact: "埼玉県まち・住まい・環境整備課",
            prefectures: ["埼玉県"]
        ))

        // ── 千葉県限定 ────────────────────────────────────────
        systems.append(SupportSystem(
            name: "千葉県移住・定住促進補助金",
            emoji: "🌿",
            summary: "東京圏から千葉に移住で最大100万円",
            detail: "東京圏から千葉に移住し、テレワーク等で就業または地元企業に就職した世帯に補助金が支給されます。子どもがいる世帯は加算あり。",
            benefit: "最大100万円",
            category: .livingSupport,
            eligibility: ["東京圏から千葉県に移住", "テレワーク就業または県内就職"],
            contact: "千葉県総合企画部 地域・人口政策課",
            prefectures: ["千葉県"]
        ))

        // ── 北海道限定 ────────────────────────────────────────
        systems.append(SupportSystem(
            name: "北海道移住応援給付金",
            emoji: "🏔️",
            summary: "道内移住で最大100万円の給付",
            detail: "東京23区在住者または通勤者が北海道に移住し、テレワーク等で就業した場合に、最大100万円（世帯の場合）が給付されます。子ども1人につき100万円の加算あり。",
            benefit: "最大100万円＋子ども加算",
            category: .livingSupport,
            eligibility: ["東京23区から移住", "テレワーク就業または道内就職"],
            contact: "北海道移住・交流推進センター",
            prefectures: ["北海道"]
        ))
        systems.append(SupportSystem(
            name: "北海道ふるさと奨学金返還支援",
            emoji: "🎓",
            summary: "道内就職で奨学金返還を最大180万円補助",
            detail: "北海道内の対象職種（IT・医療・農業等）に就職した方を対象に、奨学金の返還費用を最大180万円補助します。",
            benefit: "最大180万円",
            category: .loan,
            eligibility: ["道内の対象職種に就職", "日本学生支援機構の奨学金貸与者"],
            contact: "北海道経済部 雇用労政課",
            prefectures: ["北海道"]
        ))

        // ── 福岡県限定 ────────────────────────────────────────
        systems.append(SupportSystem(
            name: "福岡市奨学金返還支援事業",
            emoji: "🎓",
            summary: "福岡市内企業就職で奨学金を補助",
            detail: "市内の中小企業等に就職した若者の奨学金返還を、企業と市が協力して補助します。月最大2万円、最長5年間の支援を受けられます。",
            benefit: "月最大2万円×最長5年",
            category: .loan,
            eligibility: ["市内中小企業等に就職した35歳以下", "日本学生支援機構の奨学金貸与者"],
            contact: "福岡市経済観光文化局 雇用推進部",
            prefectures: ["福岡県"]
        ))
        systems.append(SupportSystem(
            name: "福岡県若者就労支援給付",
            emoji: "💼",
            summary: "就活中の若者に月10万円給付＋訓練",
            detail: "15〜49歳の就労困難な若者を対象に、無料の就職支援プログラムと、参加中の生活費補助（月最大10万円）を提供します。",
            benefit: "月最大10万円＋無料支援",
            category: .employment,
            eligibility: ["15〜49歳の就労困難な方", "県内在住"],
            contact: "福岡県若者サポートステーション",
            prefectures: ["福岡県"]
        ))

        // ── 兵庫県限定 ────────────────────────────────────────
        systems.append(SupportSystem(
            name: "神戸市移住応援補助金",
            emoji: "⚓",
            summary: "神戸市への移住で最大100万円",
            detail: "東京圏から神戸市に移住した方に最大100万円（単身50万円、世帯100万円）の補助金が支給されます。子ども加算もあり。",
            benefit: "単身50万・世帯100万円",
            category: .livingSupport,
            eligibility: ["東京圏から神戸市に移住", "テレワーク就業または市内就職"],
            contact: "神戸市まちの活力推進局",
            prefectures: ["兵庫県"]
        ))

        // ── 京都府限定 ────────────────────────────────────────
        systems.append(SupportSystem(
            name: "京都市移住促進補助金",
            emoji: "⛩️",
            summary: "東京圏から京都市への移住で補助",
            detail: "東京圏から京都市に移住し、テレワーク等で就業または市内就職をした方に、最大100万円の補助金を支給します。",
            benefit: "最大100万円",
            category: .livingSupport,
            eligibility: ["東京圏から京都市に移住", "就業要件を満たす方"],
            contact: "京都市まち・住まい・環境整備室",
            prefectures: ["京都府"]
        ))

        return systems
    }
}

enum SystemCategory: String, CaseIterable {
    case livingSupport = "livingSupport"
    case medical = "medical"
    case childcare = "childcare"
    case employment = "employment"
    case loan = "loan"
    case tax = "tax"

    var displayText: String {
        switch self {
        case .livingSupport: return "生活支援"
        case .medical: return "医療・年金"
        case .childcare: return "子育て"
        case .employment: return "就労・スキル"
        case .loan: return "貸付"
        case .tax: return "税制"
        }
    }

    var emoji: String {
        switch self {
        case .livingSupport: return "🏛️"
        case .medical: return "🏥"
        case .childcare: return "👶"
        case .employment: return "💼"
        case .loan: return "💴"
        case .tax: return "📑"
        }
    }
}

#Preview {
    SupportSystemView()
        .environmentObject({
            let s = AppState()
            s.loadDemoData()
            return s
        }())
}
