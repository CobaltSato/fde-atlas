---
name: setup
description: 初回導入(§2.1・§14.8)。新しいPJへ導入した直後、AGENTS.mdの記入欄をインタビュー形式で埋める。「セットアップして」「初期設定して」「このPJで使えるようにして」で使う。
type: 必殺技
sor: AGENTS.md記入欄・fde-guide.md
approval_line: なし(このスキルは記入欄の反映まで。実行を伴う操作はしない)
autonomy: L1
validated:
updated: 2026-07-11
---

# /setup — 初回導入

## いつ使うか
新しいプロジェクトへ導入した直後、AGENTS.mdの記入欄がまだ`<未設定>`のとき。
根拠: fde-guide.md §2.1(作業地図6項目)・§14.8(質問形式)。

## 入力
- なし(このスキル自身がインタビューで入力を集める)

## 手順
1. 前提を確認する: fde-guide.mdがあるか(Yes/No)。`.git`があるか(Yes/No、無ければ`git init`を提案する)。
2. templates/shitsumon.md の形式で一括質問する: 業務名/目的・完了条件/主なSoRと**書類原本の置き場**/承認線への追加/自律度(既定L1)/上限/運転モード(既定: 通常)/責任者。
3. 回答をAGENTS.mdの記入欄へ反映する(`<未設定>`を置換する)。答えが無い項目は「未設定」のまま残すことを宣言する。
4. source-map.md・context/rules.md(命名規則)・README.md・work/STATUS.mdへ反映する。
5. diffを提示する。
6. 初回commitを提案する。
7. 「新しいセッションを開き、SessionStartの注入(日付・STATUS)が出ることを確認する」ことを案内して完了する。

## ゲート(Yes/Noで自己確認)
- [ ] AGENTS.mdの記入欄(1.)以外を書き換えていないか
- [ ] 答えの無い項目を「未設定」のまま残したか(推測で埋めていないか)
- [ ] diffを提示してからcommitを提案したか

## 停止線(MUST NOT)
- 記入欄以外の書き換え(AGENTS.mdの規則部分を変えない)はしない

## 出力形式
AGENTS.md記入欄の反映diff+source-map.md/context/rules.md/README.md/work/STATUS.mdの反映diff。

## 完了条件
AGENTS.mdの記入欄が回答内容(または「未設定」)で埋まり、初回commitが提案され、次回セッションでのSessionStart確認手順が案内されている。

## 失敗時の更新先
インタビューで回答が曖昧だった・記入欄以外へ誤って反映した等の失敗は、本ファイルの「手順」該当番号へ1行注記を追記する。
