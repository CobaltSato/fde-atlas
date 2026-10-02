#!/bin/sh
# PreToolUse(Bash)。戻せない操作を exit 2 で止める
CMD=$(tr '\n' ' ' | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p')
[ -z "$CMD" ] && exit 0
stop() {
 echo "止めました: $1。戻せない操作です。必要なら desk/ に承認の票を置いて人間を待つか、人間が実行してください。" >&2
 exit 2
}
# -c の中身は残し、他の引用符の中身は Q
P='(^|[ ;&|(/])((ba|z)?sh) -c '
SEGS=$(printf '%s\n' "$CMD" | sed -E -e 's/\\n/;/g' -e "s/$P'([^']*)'/\\1\\2 -c ;\\4;/g" -e "s/$P\\\\\"(([^\\\\]|\\\\[^\"])*)\\\\\"/\\1\\2 -c ;\\4;/g" -e 's/\\"(\+[^ \\]*)\\"/\1/g' -e "s/'[^']*'|\\\\\"([^\\\\]|\\\\[^\"])*\\\\\"/Q/g" | sed 's/[;&|()`]/\
/g')
set -f
printf '%s\n' "$SEGS" | while IFS= read -r SEG; do
 set -- $SEG
 while [ $# -gt 0 ]; do
 case "$1" in
 -n|-s|-k|-o|-e) [ $# -ge 2 ] && shift 2 || shift ;;
 [0-9]*) shift ;;
 *=*|-*|timeout|sudo|env|command|exec|nohup|time|nice|xargs|bash|sh|zsh|do|then|else|elif|if|while|until|!|{|builtin|stdbuf|caffeinate|eval) shift ;;
 find) shift; while [ $# -gt 0 ]; do case "$1" in -exec*) break ;; esac; shift; done; [ $# -gt 0 ] && shift ;;
 *) break ;;
 esac
 done; [ $# -eq 0 ] && continue; N=${1##*/}; shift
 case "$N" in
 mail|sendmail|mutt) stop "メール送信" ;;
 rm) R=0; F=0; for A in "$@"; do
 case "$A" in
 --rec*) R=1 ;; --fo*) F=1 ;; --*) ;;
 -*) case "$A" in *[rR]*) R=1 ;; esac; case "$A" in *f*) F=1 ;; esac ;;
 esac
 done; if [ $R$F = 11 ]; then stop "rm の再帰削除と強制"; fi ;;
 git) while [ $# -gt 0 ]; do case "$1" in -C|-c) [ $# -ge 2 ] || break; shift 2 ;; -*) shift ;; *) break ;; esac; done
 S=${1:-}; [ $# -gt 0 ] && shift; for A in "$@"; do
 case "$S:$A" in
 push:--force*|push:-f*|push:-[!-]*f*|push:+?*) stop "git push の強制" ;;
 reset:--har*) stop "git reset --hard" ;;
 clean:--f*|clean:-f*|clean:-[!-]*f*) stop "git clean の強制" ;;
 commit:--am*) stop "git commit --amend" ;;
 esac
 done; if [ "$S" = rebase ]; then stop "git rebase"; fi ;;
 esac
done
