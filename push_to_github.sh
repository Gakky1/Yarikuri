#!/bin/bash
# やりくりん GitHubプッシュスクリプト
# 使い方: bash ~/Desktop/Yarikuri/push_to_github.sh

# ---- GitHubリポジトリURLを設定 ----
# 下の GITHUB_URL を作成したリポジトリのURLに変更してください
# 例: https://github.com/inagakiryokuto/Yarikuri.git
GITHUB_URL="https://github.com/Gakky1/Yarikuri.git"

echo "🚀 やりくりん GitHubプッシュを開始します..."

# Yarikuriフォルダに移動
cd ~/Desktop/Yarikuri || { echo "❌ Yarikuriフォルダが見つかりません"; exit 1; }

# 既存の壊れた.gitがあれば削除
if [ -d ".git" ]; then
  echo "🗑️  既存の.gitフォルダを削除中..."
  rm -rf .git
fi

# git初期化
echo "📁 git initを実行中..."
git init
git branch -M main

# gitユーザー設定
git config user.email "iwtba.no.1.trad.co.m@gmail.com"
git config user.name "inagakiryokuto"

# ファイルを追加してコミット
echo "📦 ファイルを追加中..."
git add .
git commit -m "Initial commit: やりくりん iOS app"

# リモートを追加してプッシュ
echo "🌐 GitHubにプッシュ中..."
git remote add origin "$GITHUB_URL"
git push -u origin main

echo ""
echo "✅ 完了！GitHubを確認してください: ${GITHUB_URL%.git}"
