#!/bin/sh
# 対の規範: AGENTS.md 中核規則8「機密・個人情報を作業フォルダに置かない」(fde-guide.md §3.3)
# 検知するのは定型 credential のみ。日本語の個人情報は正規表現では守れないため検知しない
# (checklists/gate.md の機密区分判定と /shime の機密チェック、.gitignore が担当)。
# PostToolUse は実行後に走るため、これはブロックではなく是正フィードバックである。
IN=$(cat 2>/dev/null || true)
FP=$(printf '%s' "$IN" | tr '\n' ' ' | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$FP" ] && exit 0
[ -f "$FP" ] || exit 0

# 自己言及の誤検知を避ける除外パス(パターン定義や訓練用データを含む場所)
case "$FP" in
  */templates/*|*/checklists/*|*/.claude/hooks/*) exit 0 ;;
esac

HITS=$(grep -nE 'AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY|ghp_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9_-]{20,}|xox[bpars]-[A-Za-z0-9-]{10,}' "$FP" 2>/dev/null | head -3)
if [ -n "$HITS" ]; then
  {
    echo "[機密 §3.3] credential らしき文字列を検知しました: $FP"
    echo "$HITS"
    echo "該当行を削除し、SoR(正しい保管場所)への参照リンクに置き換えてください。作業フォルダに置いてよいのは参照だけです。"
  } >&2
  exit 2
fi

exit 0
