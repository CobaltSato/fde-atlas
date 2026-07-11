#!/bin/sh
# 対の規範: AGENTS.md「1. 承認線」「5. 可逆性」(fde-guide.md §6.3 §6.4 §8)
# 二次防壁。一次防壁は .claude/settings.json の permissions(deny/ask)。
# 方針: JSON抽出に失敗したら fail-open(一次防壁が残るため安全側は保たれる)。
IN=$(cat 2>/dev/null || true)
CMD=$(printf '%s' "$IN" | tr '\n' ' ' | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')
[ -z "$CMD" ] && exit 0

# 破壊系1: rm の再帰+強制フラグ(順不同・結合フラグ対応)
if printf '%s' "$CMD" | grep -qE '(^|[;&|[:space:]])rm[[:space:]][^;&|]*-[a-zA-Z]*(r[a-zA-Z]*f|f[a-zA-Z]*r)'; then
  echo "[承認線 §6] rm の再帰強制削除は不可逆です。削除は対象と理由を templates/approval-request.md で人間へ承認依頼するか、人間が直接実行してください。" >&2
  exit 2
fi

# 破壊系2: Git 履歴・強制系(セーブデータ保護 §8)
if printf '%s' "$CMD" | grep -qE 'git[[:space:]]+(push[[:space:]]+(-f|--force)|reset[[:space:]]+--hard|clean[[:space:]]+-[a-zA-Z]*f)'; then
  echo "[承認線 §6/§8] Git 履歴を壊す・強制上書きする操作です。セーブデータ保護のため停止しました。必要なら人間が直接実行してください。" >&2
  exit 2
fi

# 送信系: 送信はドラフトまで(承認線の既定)
if printf '%s' "$CMD" | grep -qE '(^|[;&|[:space:]])(mail|sendmail|mutt)[[:space:]]'; then
  echo "[承認線 §6] 送信は自動実行しません。ドラフトを作り、templates/approval-request.md で人間の承認を得てください。" >&2
  exit 2
fi

exit 0
