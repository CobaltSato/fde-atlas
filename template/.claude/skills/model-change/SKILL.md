---
name: model-change
description: モデル交代(§13.5・§14.12)。モデル・Agent・ツールが変わったとき、回帰確認から縮退切替・自律度調整までを行う。「モデルが変わった」「Agentを交代した」「新しいモデルに切り替えて」で使う。
type: 必殺技
sor: checklists/kaiki-cases.md・fixtures/・context/registry.md
approval_line: 自律度の昇格・維持の最終決定
autonomy: L1
validated:
updated: 2026-07-11
---

# /model-change — モデル交代

## いつ使うか
モデル・Agent・ツールが交代したとき。
根拠: fde-guide.md §13.5(モデル・Agent交代のプロトコル)・§14.12(モデル交代チェックリスト)。

## 入力
- 交代内容(旧→新、理由)

## 手順
1. 交代内容を確認する(旧→新、理由)。
2. checklists/model-koutai.md を上から順に実行する(回帰→縮退切替→自律度-1→クセ追記→上限見直し→registry記録)。
3. 回帰は checklists/kaiki-cases.md × fixtures/ で再実行し、「期待される出力の要点」と比較して差分を表で報告する。
4. AGENTS.md記入欄の運転モード・自律度を更新する(これが唯一書き換えてよいAGENTS.md箇所)。
5. 完了報告する(回帰n/n合格、変わった点)。

## ゲート(Yes/Noで自己確認)
- [ ] kaiki-cases.mdの全ケースを再実行し差分を表で報告したか
- [ ] 回帰に差があった場合、該当Skillのvalidatedをクリアし運転モードを「縮退」へ変更したか
- [ ] registry.mdの交代履歴へ1行(日付|旧→新|確認結果)を追記したか

## 停止線(MUST NOT)
- 回帰不合格のまま自律度を維持・昇格しない

## 出力形式
回帰結果の差分表+AGENTS.md記入欄(運転モード・自律度)の更新diff+registry.mdへの追記行。

## 完了条件
kaiki-cases.mdの全ケースの結果が記録され、AGENTS.mdの運転モード・自律度が更新され、registry.mdの交代履歴へ1行追記されている。

## 失敗時の更新先
回帰不一致の見落とし・新モデルのクセの記録漏れ等の失敗は、本ファイルの「手順」該当番号へ1行注記を追記する。
