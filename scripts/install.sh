#!/bin/sh
# FDE Atlas 導入スクリプト: template/ 一式 + fde-guide.md を導入先PJへコピーする。
# 使い方: scripts/install.sh <導入先パス>
# 方針: 既存ファイルは上書きせずスキップして報告。design/ は配布しない。依存は git/cp/find のみ。
set -eu

if [ $# -ne 1 ]; then
  echo "使い方: $0 <導入先パス>" >&2
  echo "例:     $0 ~/Documents/keiyaku-kanri" >&2
  exit 1
fi

SRC=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ ! -d "$SRC/template" ]; then
  echo "エラー: $SRC/template が見つかりません(FDE Atlas リポジトリの scripts/ から実行してください)" >&2
  exit 1
fi

mkdir -p "$1"
DST=$(CDPATH= cd -- "$1" && pwd)
if [ "$DST" = "$SRC" ]; then
  echo "エラー: 導入先が FDE Atlas 自身です" >&2
  exit 1
fi

echo "導入元: $SRC"
echo "導入先: $DST"
echo ""

IFS='
'
for rel in $(cd "$SRC/template" && find . -type f | sed 's|^\./||'); do
  if [ -e "$DST/$rel" ]; then
    echo "スキップ(既存): $rel"
  else
    mkdir -p "$DST/$(dirname "$rel")"
    cp "$SRC/template/$rel" "$DST/$rel"
    echo "コピー:         $rel"
  fi
done
unset IFS

# 規範の完全版(AGENTS.md が§参照する)
if [ -e "$DST/fde-guide.md" ]; then
  echo "スキップ(既存): fde-guide.md"
else
  cp "$SRC/fde-guide.md" "$DST/fde-guide.md"
  echo "コピー:         fde-guide.md"
fi

# hook は実行権限が無いと無反応になる(典型事故)
chmod +x "$DST/.claude/hooks/"*.sh 2>/dev/null || true

# Git = セーブデータ(fde-guide.md §8)。新規initのときだけ導入時点のセーブポイントも作る
# (既存リポジトリのstaging状態には触れない)
if ! git -C "$DST" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$DST" init >/dev/null
  git -C "$DST" add -A
  git -C "$DST" commit -q -m "chore: FDE Atlas導入(テンプレ一式)" >/dev/null 2>&1 || true
  echo ""
  echo "git init + 導入時点のセーブポイント(commit)を作りました。"
fi

echo ""
echo "導入完了。次の手順:"
echo "  1. cd \"$DST\""
echo "  2. claude を起動(初回は信頼確認ダイアログが出るので、内容を確認して承認)"
echo "  3. /setup を実行して、業務名・SoR・承認線などの記入欄を埋める"
