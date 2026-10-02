---
name: wrap-up
description: 終了・中断時に記録し desk/ を回収して commit。「しめて」「今日はここまで」で使う。
updated: 2026-10-02
---

## いつ使うか
- 終える・中断するとき(未完了でも)。「しめて」「終わり」「今日はここまで」「セーブして」。
- 起動時の表示に `[注意] 未commit` か `[棚卸し]` が出たとき。

## 手順
1. `git status --porcelain` と `git diff --stat` で変更宣言。エラー原文が work/ にあるか見る。
2. `work/<業務>/YYYYMMDD.md` に到達点・判断と理由・未解決を書く。1行目 `# <業務> YYYY-MM-DD`。STATUS の1行目を `次の一手: <具体的な1文>` にし、業務索引の行を直す(追記は10行・800字以内)。STATUS が `[棚卸し]` なら先に手順3の退避を。
3. 回答あり(判定は templates/review-ticket.md の回答欄)の票は反映し `mkdir -p` `git mv` で `work/<業務>/archive/` へ移す。再実行確認の票が はい なら AGENTS.md 7節の `(未検証)` を外す。新しく判断が要る件は票にする。承認で人間が行う操作の票は `ひとこと:` に実行済みとあるまで移さず判断待ちに残す(期限付き)。desk/TODAY.md を同じ見出しで作り直す。判断待ち=残票を期限順(期限切れに印)・現在地=文1行+Mermaid(図の書き方)・最終更新日。`[棚卸し]` なら STATUS 全文を `work/status-archive-YYYY-MM.md` へ写して(消さない)短くし、古い work/ ファイルを archive/ へ移す提案の票を1枚置く(移すのは回答の後)。
4. `git add -A` 後 `sh .claude/hooks/secret-guard.sh --staged`。exit 2(機密あり)なら commit せずファイルと行番号を報告し止まる。無ければ `docs: <業務> <到達点>` で commit。
5. 3行で報告: 到達点/次の一手/未回答数。同じ手順・注意が2回あれば1行だけ /skill-create を勧める(無ければ出さない)。

## 止まる線
- push しない。
- amend・rebase・reset で履歴を書き換えない。
- ファイルを削除しない(移動は回答ありの票の分だけ)。
- 票の回答・過去の日付メモ・archive/ の既存ファイルは書き換えない。

## 出力
commit 1つ。`git status --porcelain` が空で、STATUS の1行目が `次の一手: ` で始まる。回答 はい の票があれば AGENTS.md 7節の該当行から `(未検証)` が外れている。
失敗時: この手順の該当番号に1行足す
