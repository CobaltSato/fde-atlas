#!/bin/sh
# PreToolUse(Bash)。戻せない操作を止める唯一の機械層。exit 2 で停止。
# 取り出せない・該当しないときは exit 0(fail-open)。push の確認は settings.json の ask。
CMD=$(tr '\n' ' ' | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p')
[ -z "$CMD" ] && exit 0

stop() {
  echo "止めました: $1。戻せない操作です。必要なら desk/ に承認の票を置いて人間の判断を待つか、人間が直接実行してください。" >&2
  exit 2
}
# 改行・; & | ( ) ` ごとに1行へ分ける。-c の中身と引用符つき +refspec は残し、他の引用符の中身は Q に置換(先に開く引用符を優先)
SEGS=$(printf '%s\n' "$CMD" | sed -E -e 's/\\n/;/g' -e "s/-c '([^']*)'/-c ;\\1;/g" -e 's/-c \\"/-c /g' -e 's/\\"(\+[^ \\]*)\\"/\1/g' -e "s/'[^']*'|\\\\\"([^\\\\]|\\\\[^\"])*\\\\\"/Q/g" | sed 's/[;&|()`]/\
/g')
set -f
printf '%s\n' "$SEGS" | while IFS= read -r SEG; do  # stop は subshell で exit する。このループを最後に置く
  set -- $SEG
  while [ $# -gt 0 ]; do  # 先頭の VAR=x・time・xargs 等を飛ばし、find は -exec の後ろを見る
    case "$1" in
      -n) [ $# -ge 2 ] && shift 2 || shift ;;  # nice -n 5 の 5
      *=*|-*|sudo|env|command|exec|nohup|time|nice|xargs|bash|sh|zsh) shift ;;
      find) shift; while [ $# -gt 0 ]; do case "$1" in -exec|-execdir) break ;; esac; shift; done; [ $# -gt 0 ] && shift ;;
      *) break ;;
    esac
  done; [ $# -eq 0 ] && continue; CMDNAME=${1##*/}; shift
  case "$CMDNAME" in
    mail|sendmail|mutt) stop "メール送信" ;;
    rm)
      R=0; F=0; for A in "$@"; do
        case "$A" in
          --) break ;; --rec*) R=1 ;; --fo*) F=1 ;; --*) ;;
          -*r*|-*R*) R=1; case "$A" in -*f*) F=1 ;; esac ;;
          -*f*) F=1 ;;
        esac
      done; if [ $R -eq 1 ] && [ $F -eq 1 ]; then stop "rm の再帰削除と強制"; fi ;;
    git)
      while [ $# -gt 0 ]; do case "$1" in -C|-c|--git-dir|--work-tree) [ $# -ge 2 ] || break; shift 2 ;; -*) shift ;; *) break ;; esac; done
      SUB=${1:-}; [ $# -gt 0 ] && shift; for A in "$@"; do
        case "$SUB:$A" in
          push:--f*|push:-f*|push:-[!-]*f*|push:+?*) stop "git push の強制" ;;
          reset:--har*) stop "git reset --hard" ;;
          clean:--fo*|clean:-f*|clean:-[!-]*f*) stop "git clean の強制" ;;
          commit:--am*) stop "git commit --amend" ;;
        esac
      done; if [ "$SUB" = rebase ]; then stop "git rebase"; fi ;;
  esac
done || exit 2
