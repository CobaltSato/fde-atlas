#!/bin/sh
# FDE Atlas 導入スクリプト: template/ 一式 + fde-guide.md を「新規フォルダ」へコピーする。
# 使い方: scripts/install.sh <新規に作る導入先パス>
# 方針: 新規フォルダ作成専用。導入先が既に存在する場合はエラーで停止する(中途半端な混在を防ぐ)。
#       design/ は配布しない。依存は git/cp/find のみ。
set -eu

if [ $# -ne 1 ]; then
  echo "使い方: $0 <新規に作る導入先パス>" >&2
  echo "例:     $0 ~/Documents/keiyaku-kanri" >&2
  exit 1
fi

SRC=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ ! -d "$SRC/template" ]; then
  echo "エラー: $SRC/template が見つかりません(FDE Atlas リポジトリの scripts/ から実行してください)" >&2
  exit 1
fi

if [ -e "$1" ]; then
  echo "エラー: 導入先 '$1' は既に存在します。" >&2
  echo "        install.sh は新規フォルダ作成専用です。既存プロジェクトへの導入は、" >&2
  echo "        別の新規フォルダに導入してから中身を手動で移動/参照してください。" >&2
  exit 1
fi

mkdir -p "$1"
DST=$(CDPATH= cd -- "$1" && pwd)
if [ "$DST" = "$SRC" ]; then
  echo "エラー: 導入先が FDE Atlas 自身です" >&2
  exit 1
fi

echo "導入元: $SRC"
echo "導入先: $DST(新規作成)"
echo ""

IFS='
'
for rel in $(cd "$SRC/template" && find . -type f | sed 's|^\./||'); do
  mkdir -p "$DST/$(dirname "$rel")"
  cp "$SRC/template/$rel" "$DST/$rel"
  echo "コピー: $rel"
done
unset IFS

# 規範の完全版(AGENTS.md が§参照する)
cp "$SRC/fde-guide.md" "$DST/fde-guide.md"
echo "コピー: fde-guide.md"

# hook は実行権限が無いと無反応になる(典型事故)
chmod +x "$DST/.claude/hooks/"*.sh 2>/dev/null || true

# Git = セーブデータ(fde-guide.md §8)。新規フォルダなので必ず初期化する
git -C "$DST" init >/dev/null
git -C "$DST" add -A
git -C "$DST" commit -q -m "chore: FDE Atlas導入(テンプレ一式)" >/dev/null 2>&1 || true
echo ""
echo "git init + 導入時点のセーブポイント(commit)を作りました。"

echo ""
echo "導入完了。次の手順:"
echo "  1. cd \"$DST\""
echo "  2. claude を起動(初回は信頼確認ダイアログが出るので、内容を確認して承認)"
echo "  3. /setup を実行して、業務名・SoR・承認線などの記入欄を埋める"
