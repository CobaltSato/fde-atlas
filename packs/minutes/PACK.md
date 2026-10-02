---
name: minutes
description: 会議メモから決定事項・宿題・リスクを抜き出すパック
version: 1.0
---

# minutes パック
会議のメモや書き起こしから、決定事項・宿題・リスクを抜き出し、議事録の案を docs/ に置く。

## 入るもの
- .claude/skills/minutes/SKILL.md(作業フォルダからの相対パス)

## AGENTS.md 7節に足す行
- 会議メモ・書き起こし → /minutes

## /setup が聞くこと
会議の議事録も扱いますか?(はい / いいえ)

## 外し方
.claude/skills/minutes/ と、AGENTS.md 7節に足した1行(- 会議メモ・書き起こし → /minutes)を消して commit(セーブ)する。削除なので、先に票(判断をお願いする紙)で承認を得る。AI に「minutes パックを外して」と頼んでもよい。
