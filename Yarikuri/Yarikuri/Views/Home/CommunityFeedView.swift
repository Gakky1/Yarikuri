import SwiftUI

// MARK: - みんなの行動セクション（ホーム埋め込み用）
struct CommunityFeedSection: View {
    @EnvironmentObject var appState: AppState
    @State private var showAllPosts = false
    @State private var showComposer = false
    @State private var selectedTab: FeedTab = .recommend

    var body: some View {
        VStack(spacing: 12) {
            // タブ切り替え
            FeedTabBar(selected: $selectedTab)

            // 投稿一覧（最大4件）
            let posts: [CommunityPost] = {
                switch selectedTab {
                case .recommend: return Array(appState.recommendedPosts.prefix(4))
                case .following: return Array(appState.followingPosts.prefix(4))
                case .mine:      return Array(appState.myPosts.prefix(4))
                }
            }()

            if posts.isEmpty {
                emptyFollowingView
            } else {
                ForEach(posts) { post in
                    CommunityPostCard(post: post, compact: true)
                }
            }

            // 投稿ボタン
            Button(action: { showComposer = true }) {
                HStack(spacing: 8) {
                    CoronView(size: 28, emotion: .normal, animate: false)
                        .frame(width: 36, height: 32)
                    Text("今日の行動をシェアする")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textTertiary)
                    Spacer()
                    Image(systemName: "pencil")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textTertiary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppColor.cardBackground)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppColor.primary.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: AppColor.shadowColor, radius: 3, x: 0, y: 1)
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showAllPosts) {
            CommunityTimelineSheet(initialTab: selectedTab)
        }
        .sheet(isPresented: $showComposer) {
            PostComposerSheet()
        }
    }

    private var emptyFollowingView: some View {
        VStack(spacing: 10) {
            Text("👤")
                .font(.system(size: 36))
            Text("まだフォロー中のユーザーがいません")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColor.textSecondary)
            Text("おすすめタブから気になる人をフォローしよう")
                .font(.system(size: 12))
                .foregroundColor(AppColor.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppColor.cardBackground)
        .cornerRadius(14)
    }
}

// MARK: - タブ種別
enum FeedTab {
    case recommend, following, mine
}

// MARK: - タブバー
struct FeedTabBar: View {
    @Binding var selected: FeedTab

    var body: some View {
        HStack(spacing: 0) {
            tabButton("おすすめ", tab: .recommend)
            tabButton("フォロー中", tab: .following)
            tabButton("自分", tab: .mine)
        }
        .background(AppColor.sectionBackground)
        .cornerRadius(10)
    }

    private func tabButton(_ label: String, tab: FeedTab) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.18)) { selected = tab } }) {
            Text(label)
                .font(.system(size: 13, weight: selected == tab ? .semibold : .regular))
                .foregroundColor(selected == tab ? AppColor.primary : AppColor.textTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    selected == tab
                        ? AppColor.cardBackground
                            .cornerRadius(8)
                            .shadow(color: AppColor.shadowColor, radius: 2, x: 0, y: 1)
                        : nil
                )
        }
        .buttonStyle(.plain)
        .padding(3)
    }
}

// MARK: - 投稿カード
struct CommunityPostCard: View {
    @EnvironmentObject var appState: AppState
    let post: CommunityPost
    var compact: Bool = false
    /// 親がコメントシートを管理する場合にセットする。nilなら内部シートを使う
    var onCommentTap: (() -> Void)? = nil
    @State private var showComments = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            avatarView

            VStack(alignment: .leading, spacing: 5) {
                // ニックネーム行
                HStack(spacing: 6) {
                    Text(post.nickname)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)

                    Spacer()

                    // 連続ログイン日数バッジ
                    streakBadge(days: post.consecutiveLoginDays)

                    // 自分の投稿の場合：公開範囲アイコン
                    if post.isMyPost {
                        Image(systemName: post.visibility == .everyone ? "globe" : "lock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppColor.textTertiary)
                    }

                    Text(post.date.timeAgoShort)
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textTertiary)
                }

                // 行動テキスト
                Text(post.actionText)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                // フォローボタン + コメントボタン + 応援ボタン
                HStack(spacing: 8) {
                    Spacer()
                    if !post.isMyPost {
                        followButton
                    }
                    commentButton
                    cheerButton
                }
            }
        }
        .padding(12)
        .background(AppColor.cardBackground)
        .cornerRadius(14)
        .shadow(color: AppColor.shadowColor, radius: 3, x: 0, y: 1)
        .sheet(isPresented: $showComments) {
            CommentSheet(post: post)
                .environmentObject(appState)
        }
    }

    // MARK: 連続ログイン日数バッジ
    private func streakBadge(days: Int) -> some View {
        let color: Color = days >= 100
            ? Color(red: 0.95, green: 0.35, blue: 0.10)
            : days >= 30
                ? Color(red: 0.95, green: 0.55, blue: 0.10)
                : days >= 7
                    ? AppColor.primary
                    : AppColor.textTertiary
        return Text("連続ログイン\(days)日")
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(color)
        .padding(.horizontal, 6).padding(.vertical, 2)
        .background(color.opacity(0.10))
        .cornerRadius(6)
    }

    // MARK: レベル別アバタースタイル
    private var levelBgColors: [Color] {
        switch post.level {
        case 1:  return [Color(red: 0.88, green: 0.88, blue: 0.92), Color(red: 0.80, green: 0.80, blue: 0.86)]
        case 2:  return [Color(red: 0.78, green: 0.90, blue: 1.00), Color(red: 0.62, green: 0.80, blue: 0.98)]
        case 3:  return [Color(red: 0.78, green: 0.96, blue: 0.82), Color(red: 0.62, green: 0.90, blue: 0.68)]
        case 4:  return [Color(red: 0.90, green: 0.80, blue: 1.00), Color(red: 0.78, green: 0.65, blue: 0.98)]
        default: return [Color(red: 1.00, green: 0.92, blue: 0.45), Color(red: 0.98, green: 0.80, blue: 0.22)]
        }
    }

    private var levelRingColor: Color {
        switch post.level {
        case 1:  return Color(red: 0.70, green: 0.70, blue: 0.75)
        case 2:  return Color(red: 0.35, green: 0.62, blue: 0.95)
        case 3:  return Color(red: 0.25, green: 0.76, blue: 0.42)
        case 4:  return Color(red: 0.60, green: 0.35, blue: 0.95)
        default: return Color(red: 0.95, green: 0.72, blue: 0.15)
        }
    }

    private var levelRingWidth: CGFloat {
        switch post.level {
        case 1:  return 1.5
        case 2:  return 2.0
        case 3:  return 2.5
        case 4:  return 3.0
        default: return 3.5
        }
    }

    private var avatarCoronSize: CGFloat {
        switch post.level {
        case 5:  return 36
        case 4:  return 33
        default: return 30
        }
    }

    // MARK: アバター
    private var avatarView: some View {
        ZStack {
            // Lv5: 黄金オーラ
            if post.level >= 5 {
                Circle()
                    .fill(Color(red: 0.99, green: 0.85, blue: 0.22).opacity(0.45))
                    .frame(width: 56, height: 56)
                    .blur(radius: 7)
            }

            // 背景円（レベル別カラー）+ リング
            Circle()
                .fill(LinearGradient(
                    colors: levelBgColors,
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 44, height: 44)
                .overlay(Circle().stroke(levelRingColor, lineWidth: levelRingWidth))
                .shadow(
                    color: post.level >= 5
                        ? Color(red: 0.99, green: 0.82, blue: 0.18).opacity(0.60)
                        : levelRingColor.opacity(0.30),
                    radius: post.level >= 5 ? 6 : 3
                )

            // やりくりん
            CoronView(size: avatarCoronSize, emotion: post.isMyPost ? .happy : .normal, animate: false, level: post.level)
                .frame(width: 44, height: 42)
                .clipped()
        }
        .overlay(levelBadgeView.offset(y: 18), alignment: .bottom)
        .frame(width: 56, height: 56)
    }

    @ViewBuilder
    private var levelBadgeView: some View {
        Text("Lv\(post.level)")
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 5).padding(.vertical, 2)
            .background(levelRingColor)
            .cornerRadius(5)
    }

    // MARK: コメントボタン
    private var commentButton: some View {
        Button(action: {
            if let onCommentTap {
                onCommentTap()
            } else {
                showComments = true
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: "bubble.left")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
                let count = appState.commentCount(for: post.id)
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColor.textTertiary)
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(AppColor.sectionBackground)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    // MARK: フォローボタン
    private var followButton: some View {
        let following = appState.isFollowing(post.nickname)
        return Button(action: {
            withAnimation(.spring(response: 0.3)) {
                appState.toggleFollow(nickname: post.nickname)
            }
        }) {
            Text(following ? "フォロー中" : "+ フォロー")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(following ? AppColor.textTertiary : AppColor.primary)
                .padding(.horizontal, 9).padding(.vertical, 4)
                .background(following ? AppColor.sectionBackground : AppColor.primaryLight)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(following ? Color.clear : AppColor.primary.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: 応援ボタン
    private var cheerButton: some View {
        Button(action: { appState.toggleCheer(postId: post.id) }) {
            HStack(spacing: 4) {
                Image(systemName: post.isLikedByMe ? "hands.clap.fill" : "hands.clap")
                    .font(.system(size: 13))
                    .foregroundColor(post.isLikedByMe ? AppColor.primary : AppColor.textTertiary)
                Text("\(post.cheerCount)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(post.isLikedByMe ? AppColor.primary : AppColor.textTertiary)
            }
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(post.isLikedByMe ? AppColor.primaryLight : AppColor.sectionBackground)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - タイムライン全件シート
struct CommunityTimelineSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State var selectedTab: FeedTab
    @State private var showComposer = false

    init(initialTab: FeedTab = .recommend) {
        _selectedTab = State(initialValue: initialTab)
    }

    private var posts: [CommunityPost] {
        selectedTab == .recommend
            ? appState.recommendedPosts
            : appState.followingPosts
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    // タブ切り替え
                    FeedTabBar(selected: $selectedTab)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            if posts.isEmpty {
                                emptyView
                            } else {
                                ForEach(posts) { post in
                                    CommunityPostCard(post: post)
                                }
                            }
                            Spacer().frame(height: 20)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("みんなの行動")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showComposer = true }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(AppColor.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showComposer) { PostComposerSheet() }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Text(selectedTab == .following ? "👤" : "📭")
                .font(.system(size: 40))
            Text(selectedTab == .following
                 ? "まだフォロー中のユーザーがいません"
                 : "投稿がありません")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColor.textSecondary)
            if selectedTab == .following {
                Text("おすすめタブから気になる人を\nフォローしてみましょう")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - 投稿コンポーザーシート
struct PostComposerSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var inputText  = ""
    @State private var visibility: PostVisibility = .everyone
    @FocusState private var textFieldFocused: Bool

    var canPost: Bool { !inputText.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // プレビュー
                        postPreview

                        // テキスト入力
                        formSection("今日の行動（方法と金額を書いてシェア！）") {
                            TextField("例：固定費を見直して月3,000円削減した", text: $inputText, axis: .vertical)
                                .focused($textFieldFocused)
                                .font(.system(size: 15))
                                .padding(12)
                                .background(AppColor.cardBackground)
                                .cornerRadius(12)
                                .lineLimit(4)
                            Text("💡 「何をして、いくら減らした/増やした」を書くと参考になります")
                                .font(.system(size: 11))
                                .foregroundColor(AppColor.textTertiary)
                        }

                        // 公開範囲
                        formSection("公開範囲") {
                            HStack(spacing: 10) {
                                ForEach([PostVisibility.everyone, .followersOnly], id: \.label) { vis in
                                    Button(action: { visibility = vis }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: vis.icon)
                                                .font(.system(size: 13))
                                            Text(vis.label)
                                                .font(.system(size: 13, weight: .medium))
                                        }
                                        .foregroundColor(visibility == vis ? AppColor.primary : AppColor.textSecondary)
                                        .padding(.horizontal, 16).padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(visibility == vis ? AppColor.primaryLight : AppColor.cardBackground)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12)
                                            .stroke(visibility == vis ? AppColor.primary.opacity(0.4) : Color.clear, lineWidth: 1.5))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            Text(visibility == .everyone
                                 ? "🌐 全員のおすすめタブに表示されます"
                                 : "🔒 フォロワーのタイムラインにだけ表示されます")
                                .font(.system(size: 11))
                                .foregroundColor(AppColor.textTertiary)
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16).padding(.top, 16)
                }
            }
            .navigationTitle("行動をシェア")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: postAction) {
                        Text("投稿")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(canPost ? AppColor.primary : AppColor.textTertiary)
                    }
                    .disabled(!canPost)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
        .onAppear { textFieldFocused = true }
    }

    // プレビューカード
    private var postPreview: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [AppColor.primaryLight, AppColor.accentLight],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                CoronView(size: 30, emotion: .happy, animate: false)
                    .frame(width: 44, height: 36).clipped()
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text("あなた")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    Spacer()
                    Image(systemName: visibility.icon)
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textTertiary)
                }
                Text(inputText.isEmpty ? "今日の行動を入力してください" : inputText)
                    .font(.system(size: 14))
                    .foregroundColor(inputText.isEmpty ? AppColor.textTertiary : AppColor.textPrimary)
            }
        }
        .padding(14)
        .background(AppColor.cardBackground)
        .cornerRadius(14)
        .shadow(color: AppColor.shadowColor, radius: 3, x: 0, y: 1)
    }

    private func formSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColor.textSecondary)
            content()
        }
    }

    private func postAction() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        appState.addMyPost(emoji: "", actionText: text, category: .habit, visibility: visibility)
        dismiss()
    }
}

// MARK: - コメントシート
struct CommentSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let post: CommunityPost

    @State private var inputText = ""
    @FocusState private var focused: Bool
    @State private var editingComment: PostComment? = nil
    @State private var editText = ""
    @State private var deleteTargetId: UUID? = nil
    @State private var showDeleteConfirm = false

    private var comments: [PostComment] {
        appState.postComments[post.id] ?? []
    }

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d HH:mm"
        return f
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    // コメント一覧
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            if comments.isEmpty {
                                VStack(spacing: 12) {
                                    Text("💬").font(.system(size: 36))
                                    Text("まだコメントがありません")
                                        .font(.system(size: 15))
                                        .foregroundColor(AppColor.textSecondary)
                                    Text("最初のコメントを投稿してみよう！")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColor.textTertiary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 48)
                            } else {
                                ForEach(Array(comments.enumerated()), id: \.element.id) { idx, comment in
                                    commentRow(comment: comment, postId: post.id)
                                    if idx < comments.count - 1 {
                                        Divider().padding(.leading, 52)
                                    }
                                }
                            }
                        }
                        .background(AppColor.cardBackground)
                        .cornerRadius(14)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }

                    // 入力エリア
                    HStack(spacing: 10) {
                        TextField("コメントを入力…", text: $inputText)
                            .focused($focused)
                            .font(.system(size: 14))
                            .padding(.horizontal, 12).padding(.vertical, 10)
                            .background(AppColor.cardBackground)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColor.primary.opacity(0.25), lineWidth: 1))
                        Button(action: submitComment) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? AppColor.textTertiary : AppColor.primary)
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppColor.background.shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: -2))
                }
            }
            .navigationTitle("コメント")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
        }
        .confirmationDialog("コメントを削除しますか？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                if let id = deleteTargetId {
                    appState.deleteComment(postId: post.id, commentId: id)
                }
            }
            Button("キャンセル", role: .cancel) {}
        }
        .sheet(item: $editingComment) { comment in
            editCommentSheet(comment: comment)
        }
    }

    private func commentRow(comment: PostComment, postId: UUID) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(comment.isMyComment ? AppColor.primaryLight : AppColor.accentLight)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(comment.isMyComment ? AppColor.primary : AppColor.textSecondary)
                )
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if comment.isMyComment {
                        Text("あなた")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColor.primary)
                    }
                    Text(dateFormatter.string(from: comment.date))
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textTertiary)
                    Spacer()
                    // いいねボタン
                    Button(action: { appState.toggleCommentLike(postId: postId, commentId: comment.id) }) {
                        HStack(spacing: 3) {
                            Image(systemName: comment.isLikedByMe ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .font(.system(size: 14))
                                .foregroundColor(comment.isLikedByMe ? AppColor.primary : AppColor.textTertiary)
                            if comment.likeCount > 0 {
                                Text("\(comment.likeCount)")
                                    .font(.system(size: 13))
                                    .foregroundColor(comment.isLikedByMe ? AppColor.primary : AppColor.textTertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    // 自分のコメントは編集・削除メニュー
                    if comment.isMyComment {
                        Menu {
                            Button(action: {
                                editText = comment.text
                                editingComment = comment
                            }) {
                                Label("編集", systemImage: "pencil")
                            }
                            Button(role: .destructive, action: {
                                deleteTargetId = comment.id
                                showDeleteConfirm = true
                            }) {
                                Label("削除", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 15))
                                .foregroundColor(AppColor.textTertiary)
                                .padding(.horizontal, 4)
                        }
                    }
                }
                Text(comment.text)
                    .font(.system(size: 16))
                    .foregroundColor(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func editCommentSheet(comment: PostComment) -> some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    TextField("コメントを編集", text: $editText, axis: .vertical)
                        .font(.system(size: 15))
                        .padding(14)
                        .background(AppColor.cardBackground)
                        .cornerRadius(12)
                        .lineLimit(5)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .navigationTitle("コメントを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        let trimmed = editText.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            appState.editComment(postId: post.id, commentId: comment.id, newText: trimmed)
                        }
                        editingComment = nil
                    }
                    .foregroundColor(AppColor.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") { editingComment = nil }
                }
            }
        }
    }

    private func submitComment() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        appState.addComment(postId: post.id, text: text)
        inputText = ""
        focused = false
    }
}

// MARK: - Date拡張：相対時間表示
extension Date {
    var timeAgoShort: String {
        let diff = Int(Date().timeIntervalSince(self))
        if diff < 60        { return "今" }
        if diff < 3600      { return "\(diff / 60)分前" }
        if diff < 86400     { return "\(diff / 3600)時間前" }
        if diff < 86400 * 7 { return "\(diff / 86400)日前" }
        let f = DateFormatter()
        f.dateFormat = "M/d"
        return f.string(from: self)
    }
}
