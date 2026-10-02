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
AI に「minutes パックを外して」と頼む。AI は `mkdir -p` のあと .claude/skills/minutes/ を work/ の下の archive/packs/ へ `git mv` で移し(消さない)、AGENTS.md 7節に足した1行(- 会議メモ・書き起こし → /minutes)を外して commit(セーブ)する。
