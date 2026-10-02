#!/bin/sh
# 鍵・トークンを書き込み前(引数なし)と commit 前(--staged)に止める。exit 2 で止める。
# 日本語の個人情報・口座番号は検知しない(AGENTS.md 中核則3が担当)。
PAT='AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|xox[bpars]-[A-Za-z0-9-]{10,}'
stop() {
  echo "[機密] $1 に鍵・トークンらしき文字列があります。値は書かず、保存場所だけを書いてください。" >&2
  exit 2
}

if [ "$1" = "--staged" ]; then
  git rev-parse --git-dir >/dev/null 2>&1 || exit 0
  BAD=$(git -c core.quotePath=false diff --cached --name-only 2>/dev/null | while IFS= read -r f; do
    case "${f##*/}" in
      (.env|.env.*|*.key|*.pem|id_rsa*|*.p12) printf '%s' "$f"; break ;;
    esac
  done)
  [ -n "$BAD" ] && { echo "コミットから外してください(git restore --staged)。" >&2; stop "$BAD"; }
  HIT=$(git -c core.quotePath=false diff --cached -U0 2>/dev/null | awk '
    /^diff --git/{ h=1; next }
    h && /^\+\+\+ /{ f=substr($0,5); sub(/\t$/,"",f); sub(/^"?b\//,"",f); sub(/"$/,"",f); next }
    /^@@/{ h=0; s=$3; sub(/^\+/,"",s); sub(/,.*/,"",s); n=s+0; next }
    !h && /^\+/{ print f ":" n ":" substr($0,2); n++ }
  ' | grep -E -m1 "$PAT" | cut -d: -f1,2)
  [ -n "$HIT" ] && stop "$HIT"
  exit 0
fi

IN=$(cat 2>/dev/null || true)
ONE=$(printf '%s' "$IN" | tr '\n' ' ')
pick() { printf '%s' "$ONE" | sed -nE 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p'; }
FP=$(pick file_path)
case "$FP" in .claude/hooks/secret-guard.sh|*/.claude/hooks/secret-guard.sh) exit 0 ;; esac
BODY=$(pick content)
[ -z "$BODY" ] && BODY=$(pick new_string)
case "$ONE" in *'"content"'*|*'"new_string"'*) ;; *) BODY=$IN ;; esac
LN=$(printf '%s' "$BODY" | sed 's/\\n/\
/g' | grep -nE -m1 "$PAT" | cut -d: -f1)
[ -n "$LN" ] && stop "${FP:-入力}:$LN"
exit 0
