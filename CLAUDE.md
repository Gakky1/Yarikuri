# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# Xcodeで開く
open Yarikuri.xcodeproj

# ビルド（Xcode内）
Cmd+B

# シミュレータで実行（Xcode内）
Cmd+R

# ビルドキャッシュのクリア（Xcode内）
Cmd+Shift+K
```

外部依存ライブラリなし（Swift Package Manager 不使用）。

## アーキテクチャ

**MVVM + 中央集権型 AppState**

```
View → AppState (@EnvironmentObject) → LocalDataStore (UserDefaults)
```

- `AppState` が唯一のデータソース。`@Published` の `didSet` で自動保存される
- `LocalDataStore` は `UserDefaults` + JSONエンコードの薄いラッパー。将来 Supabase 等に差し替える際はここだけ変更する
- `OnboardingViewModel` はオンボーディング中の一時的な入力状態のみを管理し、完了時に `AppState.completeOnboarding()` へ渡す

**画面遷移フロー**

```
YarikuriApp
└── ContentView（ルーター）
    ├── SplashView（1.5秒）
    ├── OnboardingFlowView（userProfile == nil または isOnboardingCompleted == false）
    │   └── 8ステップ: Welcome → Payday → Income → FixedExpense → Debt → NextPayment → Concern → Complete
    └── MainTabView（オンボーディング完了後）
        ├── HomeView（ダッシュボード）
        ├── ProtectView（固定費・借金ナビ）
        ├── RecoverView（制度・副収入）
        └── MyPageView（設定・レポート）
```

## 主要ロジック（AppState）

**予算計算**
```
残予算 = 手取り - 固定費合計 - 今月の支払い予定合計
安全度 = 残予算 / 手取り  →  > 0.4: 安心 / > 0.15: 注意 / ≤ 0.15: 危険
1日あたりの目安 = 残予算 / 給料日まで日数
```

**今日やることの優先順位**（`generateTasks()`）
1. 3日以内の支払い
2. 借金情報が未入力
3. 固定費の見直し候補あり
4. 制度未確認
5. 副収入候補未閲覧
6. レポート未確認

**借金の返済優先度**（`Debt.priorityScore`）
金利（`interestRate`）が高い順。金利未入力の場合は残高と月返済額の比率から推算。

## データモデルの注意点

- `UserProfile.incomeAmount` は `customIncomeAmount ?? incomeRange.midValue` で計算される
- `Debt.estimatedMonthsToPayoff` は金利あり/なしで計算式が変わる（Foundationの `log()` を使用）
- `ScheduledPayment` は固定費とは別管理。固定費は毎月繰り返し、`ScheduledPayment` は単発または任意の繰り返し
- `DailyTask` は永続化されない（AppState上で毎回 `generateTasks()` から生成）。完了IDのみ `completedTaskIds: Set<String>` として保存

## デバッグ

```swift
// #if DEBUG ブロックでデモデータが自動ロードされる（YarikuriApp.swift）
// データをリセットしてオンボーディングからやり直すには：
appState.resetAllData()
// またはシミュレータでアプリを削除して再インストール
```

## 拡張時の指針

- 新しい支出カテゴリは `FixedExpenseCategory` または `PaymentCategory` に enum ケースを追加するだけ
- 新しい困りごとは `ConcernType` に追加し、`AppState.generateTasks()` に対応タスクを追加
- 通知の追加は `NotificationManager.swift` に新メソッドを追加し `scheduleAll()` から呼ぶ
- クラウド移行は `LocalDataStore` の各メソッドを Supabase クライアント呼び出しに置き換える
