#!/bin/sh
# 対の規範: AGENTS.md「6. セッションの開始と終了」「9. 数字・日付」(fde-guide.md §5.4 §7.6)
# 方針: fail-open — このスクリプトの失敗で作業を止めない。出力は30行以内。
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

echo "[ハーネス] 今日: $(date +%Y-%m-%d)"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "[ハーネス] git が未初期化です。/setup を実行してください。"
  exit 0
fi

if grep -q '<未設定>' AGENTS.md 2>/dev/null; then
  echo "[ハーネス] AGENTS.md に <未設定> が残っています(/setup が未完了)。"
fi

if [ -f work/STATUS.md ]; then
  echo "[現在地] work/STATUS.md(先頭2000バイトまで):"
  head -c 2000 work/STATUS.md
  echo ""
fi

# 棚卸しの機械チェック(§13.2 — 規範を仕組みへ)
if [ -f work/STATUS.md ]; then
  status_bytes=$(wc -c < work/STATUS.md 2>/dev/null | tr -d ' ')
  if [ "${status_bytes:-0}" -gt 8192 ] 2>/dev/null; then
    echo "[棚卸し] STATUS.md が 8KB 超(${status_bytes}B)。/wrap-up の手順で work/status-archive-YYYY-MM.md へ全文退避してください。"
  fi
fi
for d in work/*/; do
  [ -d "$d" ] || continue
  n=$(find "$d" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
  if [ "${n:-0}" -gt 50 ] 2>/dev/null; then
    echo "[棚卸し] ${d} 直下が ${n} ファイル(目安50超)。/cleanup を実行してください(checklists/cleanup.md)。"
  fi
done

echo "[セーブ] 直近のcommit:"
git log --oneline -5 2>/dev/null

if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  echo "[注意] 未commitの変更があります(前回の /wrap-up 未実施の可能性)。git diff で差分確認から始めてください(§5.4)。"
  git diff --stat 2>/dev/null | tail -5
fi

exit 0
