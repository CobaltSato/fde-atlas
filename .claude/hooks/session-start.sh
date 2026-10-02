#!/bin/sh
# 起動時の表示。失敗しても作業は止めない(常に exit 0)。stdin は読まない。ファイルは書かない。
# 閾値はコアでここだけに置く。
STATUS_MAX=8192
WORK_MAX=50
DESK_MAX=7
AGENTS_MAX=80
STATUS_HEAD=500
OUT_MAX=1000
cut8() { iconv -c -f UTF-8 -t UTF-8 2>/dev/null || cat; } # 切り詰めで割れた末尾の文字を落とす
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
TODAY=$(date +%Y-%m-%d)
{
  echo "[今日] $TODAY"
  GIT=1
  if [ ! -e .git ]; then
    GIT=0
    echo "[注意] git がありません。"
  fi
  # 1節だけを見る(## 1. から次の ## まで)
  if awk '/^## 1\./{f=1;next} /^## /{f=0} f&&/<未設定>/{found=1} END{exit !found}' AGENTS.md; then
    echo "[要記入] AGENTS.md の1節が未記入です。「セットアップして」と頼むと /setup が始まります。"
  fi
  if [ "$GIT" = 1 ]; then
    N=$(git status --porcelain | wc -l | tr -d ' ')
    if [ "${N:-0}" -gt 0 ]; then
      echo "[注意] 未commit の変更 ${N}件。前回「しめて」が済んでいない可能性があります。"
    fi
  fi
  # 棚卸し(当たったものだけ)
  TAIL="。次回の /wrap-up で退避・整理"
  TK="。伺いは動かさない"
  if [ -f work/STATUS.md ]; then
    B=$(wc -c < work/STATUS.md | tr -d ' ')
    [ "${B:-0}" -gt "$STATUS_MAX" ] && echo "[棚卸し] STATUS.md が ${B}B${TAIL}"
  fi
  A=$(wc -l < AGENTS.md | tr -d ' ')
  [ "${A:-0}" -gt "$AGENTS_MAX" ] && echo "[棚卸し] AGENTS.md が ${A}行。8節の行を消すか統合する案を伺いに"
  BIG=""
  C=0
  for d in work/*/; do
    [ -d "$d" ] || continue
    F=$(find "$d" -maxdepth 1 -type f | wc -l | tr -d ' ')
    if [ "${F:-0}" -gt "$WORK_MAX" ] && [ "$C" -lt 3 ]; then
      BIG="$BIG $d"
      C=$((C + 1))
    fi
  done
  [ -n "$BIG" ] && echo "[棚卸し] 件数超過の作業フォルダ:${BIG}${TAIL}"
  T=0; EXP=0; ANS=0; ANSLIST=""
  for f in desk/*.md; do
    [ -f "$f" ] || continue
    [ "$f" = "desk/TODAY.md" ] && continue
    T=$((T + 1))
    D=$(head -5 "$f" | sed -n 's/.*期限: *\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\).*/\1/p' | head -1)
    # 回答あり: ## 回答 より後の Q<数字>: か ひとこと: の行で、コロンの後に空白以外がある
    if awk '/^## 回答/{r=1;next} r&&/^(Q[0-9]+|ひとこと)(:|：)/{sub(/^(Q[0-9]+|ひとこと)(:|：)/,"");gsub(/[ \t]/,"");gsub(/　/,""); if(length($0)>0)found=1} END{exit !found}' "$f"; then
      ANS=$((ANS + 1))
      [ "$ANS" -le 3 ] && ANSLIST="$ANSLIST ${f#desk/}"
    elif [ -n "$D" ] && awk -v a="$D" -v b="$TODAY" 'BEGIN{exit !(a<b)}'; then
      EXP=$((EXP + 1))
    fi
  done
  [ "$T" -gt "$DESK_MAX" ] && echo "[棚卸し] desk/ の伺いが ${T}枚${TK}"
  [ "$EXP" -gt 0 ] && echo "[棚卸し] 期限切れの伺い ${EXP}枚${TK}"
  LINE="[机] 未回答 $((T - ANS))枚"
  [ "$ANS" -gt 0 ] && LINE="$LINE / 回答あり:$ANSLIST"
  echo "$LINE"
  if [ -f work/STATUS.md ]; then
    echo "[STATUS] work/STATUS.md 先頭:"
    head -c "$STATUS_HEAD" work/STATUS.md | cut8
    echo ""
  fi
  if [ "$GIT" = 1 ]; then
    echo "[セーブ] 直近の commit:"
    git log --oneline -3
  fi
} 2>/dev/null | head -c "$OUT_MAX" | cut8
exit 0
