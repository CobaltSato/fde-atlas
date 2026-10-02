---
name: si-documents
description: 書類の台帳登録と、要件定義書・基本設計書の作成とレビューを行うパック
version: 1.0
---

# si-documents パック
渡された書類を重複と指示の混入で確かめて台帳に登録する。設計書を作り、レビューする。
## 入るもの
- .claude/skills/filing/SKILL.md(作業フォルダからの相対パス)
- .claude/skills/design-doc/SKILL.md
- .claude/skills/design-doc/requirements.md
- .claude/skills/design-doc/basic-design.md
- .claude/skills/design-doc/review.md
context/ledger.md と .claude/skills/design-doc/glossary.md は同梱しない。使うスキルが初回に作る。
## AGENTS.md 7節に足す行
次の2行をそのまま写す。7節の最終行の直前に入れる。8節には足さない。
- 書類・ファイルを渡された → /filing
- 設計書を作る・レビューする → /design-doc
## /setup が聞くこと
書類の台帳・設計書も扱いますか?(はい / いいえ)
原本の置き場は /setup の問い③で聞く。命名は filing/SKILL.md の既定に従う。

## 外し方
上の5ファイルと、7節の2行を消して commit する。削除なので、先に票で承認を得る。
