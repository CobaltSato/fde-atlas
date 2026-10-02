#!/bin/sh
# hook 3本(guard-bash・secret-guard・session-start)の単体テスト。
# cases.json を読み、1件ずつ hook を実行して判定する。一時ファイルは mktemp -d の下だけ。
# 使い方: sh .atlas/tests/hooks/run.sh(別のケース表は CASES=<path> で渡す)。
# 出力: PASS|FAIL H<nn> <ID> <説明>。FAIL があれば exit 1。
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../../.." && pwd)
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT INT TERM
export REPO HERE T
python3 - <<'PY'
import json, os, shutil, subprocess, sys, tempfile, time

REPO, HERE, T = os.environ["REPO"], os.environ["HERE"], os.environ["T"]
GENV = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@e.com", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@e.com")
# トークンは実行時に連結で作る(生の値を置かない)
TOKENS = {
    "AKIA": "AK" + "IA" + "IOSFODNN7EXAMPLE", "GHP": "gh" + "p_" + "a1B2" * 9,
    "GHPAT": "github" + "_pat_" + "A1b2" * 6, "SK": "s" + "k-" + "abcd1234" * 3,
    "XOXB": "xo" + "xb-" + "1234567890" + "abcdef", "PRIVKEY": "RSA PRIVATE",
    "PEM": "-----BEGIN " + "RSA PRIVATE" + " KEY-----",
}
STATE = {"T02": "fresh", "T11": "normal", "T12": "worst"}  # バイト表の状態列
# setup の別名(cases.json の書き方 → 内部の名前)
ALIAS = {"status_bytes": "status", "work_files": "workfiles", "desk_tickets": "tickets",
         "desk_answered": "answered", "desk_expired": "expired"}
TICKET = "# 票\n種別: 承認\n{due}\n## 問い\nQ1: 送ってよいですか?\n\n## 回答\nQ1:{a}\nQ2:\nひとこと:\n検証用リンク:\n"
def sub(s):  # {{NAME}} も {NAME} も実値にする
    if not isinstance(s, str):
        s = json.dumps(s, ensure_ascii=False)
    for k, v in TOKENS.items():
        s = s.replace("{{%s}}" % k, v).replace("{%s}" % k, v)
    return s
def git(wd, *a):
    r = run(["git", "-c", "commit.gpgsign=false"] + list(a), wd)
    if r.returncode: raise RuntimeError("git %s が失敗: %s" % (a[0], r.stderr.decode("utf-8", "replace").strip()[-150:]))
def run(cmd, cwd, **kw):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, env=GENV, timeout=60, **kw)
def put(wd, rel, text):
    p = os.path.join(wd, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, "w", encoding="utf-8").write(text)
def apply_op(wd, op):
    kind, _, rest = op.partition(":")
    kind = ALIAS.get(kind, kind)
    if kind == "git_init": return  # prep.py が済ませている
    if kind == "fill1":  # AGENTS.md の1節だけ <未設定> を埋める
        lines, sec, out = open(os.path.join(wd, "AGENTS.md"), encoding="utf-8").read().split("\n"), 0, []
        for ln in lines:
            sec = (ln.startswith("## 1.")) if ln.startswith("## ") else sec
            out.append(ln.replace("<未設定>", "記入済み") if sec else ln)
        put(wd, "AGENTS.md", "\n".join(out))
    elif kind == "status_line1":  # STATUS.md の1行目を差し替える
        p = os.path.join(wd, "work/STATUS.md")
        put(wd, "work/STATUS.md", rest + "\n" + "\n".join(open(p, encoding="utf-8").read().split("\n")[1:]))
    elif kind in ("ticket_answers", "ticket_question"):  # 回答欄 / 問い を指定した票
        q = rest if kind == "ticket_question" else "送ってよいですか?"
        put(wd, "desk/20260106-%s.md" % kind, TICKET.replace("送ってよいですか?", q).format(due="", a=rest if kind == "ticket_answers" else ""))
    elif kind == "status":  # work/STATUS.md を指定バイトにする
        put(wd, "work/STATUS.md", "次の一手: 確認\n" + "x" * (int(rest) - 21))
    elif kind == "workfiles":  # work/<名前> に N ファイル
        name, n = rest.split(":")
        [put(wd, "work/%s/f%03d.md" % (name, i), "x\n") for i in range(int(n))]
    elif kind == "tickets":  # 未回答の票 N 枚
        [put(wd, "desk/20260101-t%02d.md" % i, TICKET.format(due="", a="")) for i in range(int(rest))]
    elif kind == "answered":  # 回答済みの票 N 枚
        [put(wd, "desk/20260102-a%02d.md" % i, TICKET.format(due="", a=" はい")) for i in range(int(rest))]
    elif kind == "expired":  # 期限付きの票 1枚(rest=日付)
        put(wd, "desk/20260103-e.md", TICKET.format(due="期限: " + rest, a=""))
    elif kind == "fixture":  # fixtures/ticket_<名前>.md を desk/ へ
        shutil.copy(os.path.join(REPO, ".atlas/tests/fixtures/ticket_%s.md" % rest), os.path.join(wd, "desk/20260104-fx.md"))
    elif kind == "ticket":  # ticket:<fixture ファイル名> または ticket:<名前>:<本文>
        fx = os.path.join(REPO, ".atlas/tests/fixtures", rest)
        if os.path.isfile(fx):
            shutil.copy(fx, os.path.join(wd, "desk/20260107-%s" % rest))
        else:
            name, _, body = rest.partition(":")
            put(wd, "desk/20260105-%s.md" % name, sub(body))
    elif kind == "dirty":  # 未commit の変更 N 件
        [put(wd, "dirty%d.txt" % i, "x\n") for i in range(int(rest))]
    elif kind == "commits":  # commit を N 件足す
        for i in range(int(rest)):
            put(wd, "c%d.txt" % i, "x\n")
            git(wd, "add", "-A"); git(wd, "commit", "-q", "-m", "chore: c%d" % i)
    elif kind == "stage":  # stage:<パス>:<本文> を git add する
        path, _, body = rest.partition(":")
        put(wd, path, sub(body.replace("\\n", "\n"))); git(wd, "add", "-f", path)
    else:
        raise ValueError("未知の setup: " + op)
def make_wd(case):
    d = os.path.join(tempfile.mkdtemp(dir=T), "pj")  # prep.py は未作成の場所にコピーする
    if case["hook"] == "session-start" or "setup" in case:
        ops = case.get("setup", [])
        kind = case.get("prep") or ("K00" if "nogit" in ops else "blank")
        r = run(["python3", os.path.join(REPO, ".atlas/tests/e2e/prep.py"), kind, d,
                 "--today", time.strftime("%Y-%m-%d")], REPO)
        if r.returncode != 0: raise RuntimeError("prep.py が失敗: " + r.stderr.decode("utf-8", "replace")[-200:])
        [apply_op(d, op) for op in ops if op != "nogit"]
    return d
def exec_hook(case, wd, stdin):
    hook = os.path.join(REPO, ".claude/hooks/%s.sh" % case["hook"])
    env = dict(GENV, CLAUDE_PROJECT_DIR=wd)
    args = [sub(a) for a in case.get("args", [])]
    kw = {"stdin": subprocess.DEVNULL} if stdin is None else {"input": stdin}
    return subprocess.run(["sh", hook] + args, cwd=wd, capture_output=True, env=env, timeout=60, **kw)
def judge(case, p, so, se):
    errs, out = [], so + se
    if p.returncode != case.get("expect_exit", 0):
        errs.append("exit %d(期待 %s)" % (p.returncode, case.get("expect_exit", 0)))
    for s in case.get("expect_contains", []):  # 実値で探し、メッセージには元の書き方(placeholder)を出す
        if sub(s) not in out: errs.append("含むべき文字列が無い: " + s)
    for s in case.get("expect_not_contains", []):
        if sub(s) in out: errs.append("含んではいけない文字列がある: " + s)
    pos = [out.find(s) for s in case.get("expect_order", [])]
    if pos and (min(pos) < 0 or pos != sorted(pos)): errs.append("出力の順序が違う")
    if len(p.stdout) > case.get("max_bytes", 10**9): errs.append("%dB > 上限 %dB" % (len(p.stdout), case["max_bytes"]))
    if len(p.stderr) > case.get("stderr_max_bytes", 10**9): errs.append("stderr %dB > 上限 %dB" % (len(p.stderr), case["stderr_max_bytes"]))
    for k, v in TOKENS.items():  # 毎回: 検知した文字列を出力に出していないか
        if v in out: errs.append("トークン {{%s}} が出力に出ている" % k)
    if case["hook"] == "session-start" and "/cleanup" in out: errs.append("出力に /cleanup がある")
    return errs
def main():
    cases = json.load(open(os.environ.get("CASES", os.path.join(HERE, "cases.json")), encoding="utf-8"))
    plain, fails, table = tempfile.mkdtemp(dir=T), 0, []
    for n, c in enumerate(cases, 1):
        try:
            wd = make_wd(c) if c["hook"] == "session-start" or "setup" in c else plain
            stdin = None if c["hook"] == "session-start" and "stdin" not in c else sub(c.get("stdin", "")).encode("utf-8")
            p = exec_hook(c, wd, stdin)
            so, se = p.stdout.decode("utf-8", "replace"), p.stderr.decode("utf-8", "replace")
            errs = judge(c, p, so, se)
            if c["hook"] == "session-start":
                table.append((c["id"], c.get("record_bytes") or STATE.get(c["id"], ""), len(p.stdout)))
                if c.get("same_output_for_stdin") or c.get("same_as_devnull"):  # JSON を渡しても出力が同じか
                    q = exec_hook(c, wd, b'{"hook_event_name":"SessionStart"}')
                    if q.stdout != p.stdout: errs.append("stdin が JSON のとき出力が違う")
        except Exception as e:
            errs = ["実行できない: %s" % " ".join(str(e).split())]
        errs = [" ".join(e.split()) for e in errs]; fails += bool(errs)
        print("%s H%02d %s %s%s" % ("FAIL" if errs else "PASS", n, c["id"], c.get("desc", c["hook"]),
                                    (" ← " + " / ".join(errs)) if errs else ""))
    print("\n| session-start ID | 状態(fresh/normal/worst) | 出力バイト数 |\n|---|---|---|")
    for i, r, b in table: print("| %s | %s | %d |" % (i, r, b))
    return 1 if fails else 0

try: code = main()
finally: shutil.rmtree(T, ignore_errors=True)
sys.exit(code)
PY
