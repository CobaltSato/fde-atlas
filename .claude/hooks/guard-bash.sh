#!/bin/sh
# PreToolUse(Bash)。戻せない操作と削除を exit 2 で止める
CMD=$(tr '\n' ' ' | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p')
[ -z "$CMD" ] && exit 0
stop() { echo "止めました: $1。${2-戻せない操作です。}desk/ に承認の伺いを置いてください。承認後に${3-実行する}のは人間です。" >&2; exit 2; }
del() { stop 削除 "消さずに archive/ へ移すか、" 消す; }
# -c・eval の中身と "" の中の $( ) は残し、他の引用符の中身は Q
P='(^|[ ;&|(/])((ba|z)?sh( -[a-z]+)* -[a-z]*c|eval) '
# 継続行は空白、改行は ; に。heredoc の本文は、受け手がシェルでなければ捨てる
SEGS=$(printf '%s\n' "$CMD" | sed -E -e 's/\\\\\\"/E/g' -e "s/$P'([^']*)'/\\1\\2 ;\\5;/g" -e "s/$P\\\\\"(([^\\\\]|\\\\[^\"])*)\\\\\"/\\1\\2 ;\\5;/g" -e 's/\\"(\+[^ \\]*)\\"/\1/g' | awk '{gsub(/\\\\\\n/," ");gsub(/\\n/,"\n");n=split($0,L,"\n")
 for(j=n;j>0;j--){x[j]=f[L[j]];f[L[j]]=j}
 for(i=1;i<=n;i++){o=o L[i] ";"
 if(match(L[i],/<<-? *[\\"\047]*[A-Za-z_][A-Za-z_0-9]*/)&&L[i]!~/(^|[^A-Za-z0-9_.-])(ba|z)?sh([^A-Za-z0-9]|$)/){t=substr(L[i],RSTART,RLENGTH);sub(/^<<-? *[\\"\047]*/,"",t);k=(t in q)?q[t]:f[t];while(k&&k<=i)k=x[k];q[t]=k;if(k)i=k}}}
 END{while(match(o,/\047[^\047]*\047|\\"([^\\]|\\[^"])*\\"/)){d=substr(o,RSTART,RLENGTH);z=z substr(o,1,RSTART-1) "Q";o=substr(o,RSTART+RLENGTH)
 if(d~/^\\/)while(match(d,/\$\([^()]*\)|`[^`]*`/)){z=z ";" substr(d,RSTART,RLENGTH) ";";d=substr(d,RSTART+RLENGTH)}}
 z=z o;gsub(/[;&|()`]/,"\n",z);print z}')
set -f
printf '%s\n' "$SEGS" | sed -nE '/rm|git|delete/p' | sort -u | while IFS= read -r SEG; do
 set -- $SEG
 while [ $# -gt 0 ]; do
 case "$1" in
 -n|-s|-k|-o|-e|-I|-P|-u|-g) [ $# -ge 2 ] && shift 2 || shift ;;
 -delete) del ;;
 [0-9]*) shift ;;
 command) case ${2-} in -v|-V) break ;; esac; shift ;;
 *=*|-*|timeout|sudo|env|exec|nohup|time|nice|xargs|bash|sh|zsh|do|then|else|elif|if|while|until|!|{|{}|builtin|stdbuf|caffeinate|eval) shift ;;
 find) shift; while [ $# -gt 0 ]; do case "$1" in -delete) del ;; -exec*|-ok*) break ;; esac; shift; done; [ $# -gt 0 ] && shift ;;
 *) break ;;
 esac
 done; [ $# -eq 0 ] && continue; N=${1##*/}; shift
 case "$N" in
 rm|\\*rm) del ;;
 git) while [ $# -gt 0 ]; do case "$1" in -C|-c) [ $# -ge 2 ] || break; shift 2 ;; -*) shift ;; *) break ;; esac; done
 S=${1:-}; [ $# -gt 0 ] && shift; for A in "$@"; do
 case "$S:$A" in
 push:--force*|push:-f*|push:-[!-]*f*|push:+?*) stop "git push の強制" ;;
 reset:--har*) stop "git reset --hard" ;;
 clean:--f*|clean:-f*|clean:-[!-]*f*) stop "git clean の強制" ;;
 commit:--am*) stop "git commit --amend" ;;
 esac
 done; case $S in rm) del ;; rebase) stop "git rebase" ;; esac ;;
 esac
done
