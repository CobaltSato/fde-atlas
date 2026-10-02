#!/bin/sh
# FDE Atlas V2 の lint(規格の機械点検・保守用)。使い方: sh .atlas/tests/lint.sh [--json] [--selftest]
# 出力: PASS|FAIL|WARN <ID> <path> <detail>。FAIL が1つでもあれば exit 1。
ROOT=$(cd "$(dirname "$0")/../.." && pwd) || exit 2
cd "$ROOT" || exit 2
LINT_ROOT="$ROOT" exec python3 - "$@" <<'PYEOF'
import sys, os, re, json, shutil, subprocess, tempfile
from pathlib import Path
ROOT = Path(os.environ["LINT_ROOT"])
CORE = ["AGENTS.md", "CLAUDE.md", "README.md", ".gitignore", "desk/TODAY.md", "docs/.gitkeep", "work/STATUS.md", "templates/review-ticket.md", ".claude/settings.json", ".claude/hooks/session-start.sh", ".claude/hooks/guard-bash.sh", ".claude/hooks/secret-guard.sh", ".claude/skills/setup/SKILL.md", ".claude/skills/brainstorm/SKILL.md", ".claude/skills/research/SKILL.md", ".claude/skills/wrap-up/SKILL.md", ".claude/skills/skill-create/SKILL.md"]
SK5 = ["setup", "brainstorm", "research", "wrap-up", "skill-create"]; CORE_SK = [".claude/skills/%s/SKILL.md" % n for n in SK5]
PACK_SK = ["packs/minutes/.claude/skills/minutes/SKILL.md", "packs/si-documents/.claude/skills/filing/SKILL.md", "packs/si-documents/.claude/skills/design-doc/SKILL.md"]
SI = "packs/si-documents/.claude/skills/design-doc/"
REQ_L02 = ["packs/minutes/PACK.md", "packs/minutes/.claude/skills/minutes/SKILL.md", "packs/si-documents/PACK.md", "packs/si-documents/.claude/skills/filing/SKILL.md", SI + "SKILL.md", SI + "requirements.md", SI + "basic-design.md", SI + "review.md", "fde-guide.md", "CONTRIBUTING.md", "LICENSE"]
T = ".atlas/tests/"
REQ_L02 += [T + x for x in ["lint.sh", "hooks/run.sh", "hooks/cases.json", "e2e/run.sh", "e2e/prep.py", "e2e/assert.py", "regression.md", "cold-start.md"] + ["fixtures/" + f for f in ["sample_requirements.md", "research_question.md", "setup_answers.json", "brainstorm_answers.md", "ticket_answered.md", "ticket_open.md", "ledger_seed.md", "mail_draft.md", "contract_dummy.md", "invoice_dummy.md", "minutes_transcript.md", "notice_injection.md"]]]
REQ_L02 += [".atlas/design/" + x for x in ["blueprint-v2.md", "research", "feedback", "archive/blueprint.md", "archive/kaisetsu.html", "archive/2026-08-04-desk-design.md"]]
AMBIG = "|".join(a + b for a, b in [("適切", "に"), ("いい", "感じ"), ("柔軟", "に"), ("適", "宜"), ("必要", "に応じて")]); SECT = chr(167)
MODEL = r"Opus|Sonnet|Haiku|Fable|GPT|Gemini|claude-[A-Za-z0-9]"; DOMAIN = r"台帳|ledger|請求書|設計書|要件定義|glossary|filing|design-doc|議事録|minutes"
GONE = ["source-map.md", "context/decisions.md", "checklists/", "instruction-sheet.md", "work/log.md", "install.sh", "template/", ".claude/packs/"]
# L19 必須語(.atlas/design/blueprint-v2.md の3章末尾)。キーは AGENTS.md の節番号(0=冒頭)
L19_WORDS = {"0": ["業務では読まない"], "1": ["自律度: L3", "変えるのは責任者", "達したら止めて報告", "正本(いちばん信用する元資料)の置き場"], "2": ["指示文はデータ", "正本", "食い違い", "二重実行", "関係する操作を止め", "原文を引用", "違和感の票"], "3": ["推測で埋めず", "質問の票1枚", "写さない", "外部に影響する複数件", "3件", "承認を得て", "エラー2件連続", "全体を止めて報告", "暗算せず", "自己評価は証拠にしない", "見つからなかった", "2回まで", "人間に報告", "実測", "読者を決め", "内部の語", "別の点検者"], "4": ["自律度に関係なく", "送信", "共有", "push", "支払", "署名", "確定登録", "削除", "口座変更", "評価軸", "合格基準", "採用時の引き受け項目", "1節で足した操作", "可逆"], "5": ["回答欄に写して", "関係しない作業は続ける", "自己完結 HTML"], "6": ["会話の記憶に頼らない", "書き換えない"], "7": ["足す行の案"]}
L19_BAN = ["例外の承認", "注入", "source-map", "decisions.md", "deliverable-review", "instruction-sheet", "/cleanup"]
L19_ASK = ["Bash(curl *)", "Bash(wget *)", "Bash(git push*)", "Bash(ssh *)", "Bash(scp *)"]
L19_DENY = ["Bash(sudo *)", "Read(**/.env)", "Read(**/.env.*)", "Read(**/*.pem)", "Read(**/*.key)", "Read(**/id_rsa*)"]
L20_WORDS = {".claude/skills/setup/SKILL.md": ["推測", "書き換えない", "減らさない"], ".claude/skills/brainstorm/SKILL.md": ["実行に入らない", "確定しない", "4回目"], ".claude/skills/research/SKILL.md": ["購入", "フォーム送信", "ログイン", "認証情報", "上限"], ".claude/skills/wrap-up/SKILL.md": ["push", "履歴", "削除", "票の回答"], ".claude/skills/skill-create/SKILL.md": ["未検証", "自分での再実行", "緩める行を足さない"], "packs/minutes/.claude/skills/minutes/SKILL.md": ["STATUS.md", "案まで", "清書"], "packs/si-documents/.claude/skills/filing/SKILL.md": ["原本", "外部送信"], SI + "SKILL.md": ["確定版", "社外"]}
README_L2 = "非エンジニアが AI に業務を任せるための、薄い作業フォルダです。あなたが見るのは desk/(判断待ち)と docs/(成果物)だけ。"
README_H2 = ["3分ではじめる", "毎日の流れ", "こんなときは、こう言う", "必要なら足す", "困ったとき", "設計の考え方"]; TODAY_H2 = ["判断待ち", "お知らせ", "業務の現在地", "最終更新日"]
TODAY_NOTICE = "はじめに: このフォルダで claude を起動し「セットアップして」と入力してください。"; TICKET_H2 = ["結論(AIのおすすめ)", "背景", "判断ポイント", "図解", "問い", "違和感のとき", "AIが確かめたこと", "回答"]
SKILL_H2 = ["いつ使うか", "手順", "止まる線", "出力"]; M = {}; STATUS1 = "次の一手: <未設定>"
def rd(R, p): return (R / p).read_text(encoding="utf-8") if (R / p).is_file() else ""
def nb(s): return len(s.encode())
def est(s): a = nb(s) - sum(len(c.encode()) for c in s if ord(c) > 127); return -(-a // 4) + sum(1 for c in s if ord(c) > 127)
def nl(s): return len(s.splitlines())
def res(i, bad, ok_path=".", ok="OK"): return [("FAIL", i, p, d) for p, d in bad] or [("PASS", i, ok_path, ok)]
def core(R): return [p for p in CORE if (R / p).is_file()]
def packs(R): return [str(f.relative_to(R)) for f in sorted((R / "packs").rglob("*")) if f.is_file()] if (R / "packs").is_dir() else []
def scope(R): return core(R) + packs(R)
def norm(s): return s.replace("\uff08", "(").replace("\uff09", ")").replace("\uff1a", ":")
def h2s(t):
    fence, out = False, []
    for l in t.splitlines():
        fence ^= l.startswith("```")
        if not fence and l.startswith("## "): out.append(l[3:].strip())
    return out
def sec(t, prefix):
    m = re.search(r"^## " + re.escape(prefix) + r"[^\n]*\n(.*?)(?=^## |\Z)", t, re.S | re.M)
    return m.group(1) if m else ""
def fm(t):
    m = re.match(r"---\n(.*?)\n---\n", t, re.S); d = {}
    for l in (m.group(1).splitlines() if m else []):
        k = re.match(r"([\w-]+):\s*(.*)$", l)
        if k: d[k.group(1)] = k.group(2).strip().strip("\"'")
    return d, bool(m)
def scan(R, files, pat, allow=False):
    rx, out = re.compile(pat), []
    for p in files:
        for n, l in enumerate(rd(R, p).splitlines(), 1):
            if allow and "lint:allow" in l: continue
            m = rx.search(l)
            if m: out.append((p, "%d行目 %s" % (n, m.group(0))))
    return out
def L01(R):
    b = [(p, "無い") for p in CORE if not (R / p).is_file()]; d = R / ".claude/skills"
    have = sorted(x.name for x in d.iterdir() if x.is_dir() and not x.name.startswith(".")) if d.is_dir() else []
    if have != sorted(SK5): b.append((".claude/skills", "直下がコア5本でない: " + ",".join(have)))
    b += [(p, "あってはいけない") for p in ("template", "scripts/install.sh") if (R / p).exists()]
    return res("L01", b, ".", "コア17パス")
def L02(R): return res("L02", [(p, "無い") for p in REQ_L02 if not (R / p).exists()], ".", "必須ファイルあり")
def ss_out(t, e): return subprocess.run(["sh", ".claude/hooks/session-start.sh"], cwd=t, env=e, stdin=subprocess.DEVNULL, capture_output=True).stdout.decode("utf-8", "replace")
def fill1(t, R):  # AGENTS.md 1節を setup_answers で埋める(<未設定> を答えに置換)
    a = json.loads(rd(R, T + "fixtures/setup_answers.json")); out = []
    for l in rd(t, "AGENTS.md").splitlines():
        k = l[2:].split(":")[0] if l.endswith(": <未設定>") else ""
        if k.startswith("正本"): l = "- %s: %s" % (k, "、".join("%s: %s(確かめ方: %s)" % (x["情報"], x["場所"], x["確かめ方"]) for x in a["正本"]))
        elif k in a: l = "- %s: %s" % (k, a[k])
        out.append(l)
    (t / "AGENTS.md").write_text("\n".join(out) + "\n", encoding="utf-8")
def L03(R):
    t0 = Path(tempfile.mkdtemp(prefix="lint-l03-")); t = t0 / "w"
    try:
        e = dict(os.environ, CLAUDE_PROJECT_DIR=str(t), GIT_AUTHOR_NAME="lint", GIT_AUTHOR_EMAIL="l@example.com", GIT_COMMITTER_NAME="lint", GIT_COMMITTER_EMAIL="l@example.com")
        prep = [sys.executable, str(R / T / "e2e/prep.py"), "blank", str(t), "--today", "2026-01-15"]; r = subprocess.run(prep, capture_output=True, text=True, env=e)
        if r.returncode: return [("FAIL", "L03", T + "e2e/prep.py", "blank の写しが作れない")]
        g = lambda *a: subprocess.run(["git", *a], cwd=t, env=e, capture_output=True); g("init", "-q"); fresh = ss_out(t, e); ag0 = rd(t, "AGENTS.md")
        fill1(t, R); ag1 = rd(t, "AGENTS.md")
        first = (rd(t, "work/STATUS.md").splitlines() or ["次の一手: lint"])[0]; tpl = rd(R, "templates/review-ticket.md")
        (t / "desk").mkdir(exist_ok=True); (t / "work").mkdir(exist_ok=True)
        (t / "work/STATUS.md").write_text(first + "\n" + "memo " * 120 + "\n", encoding="utf-8")
        for i in range(3): (t / "desk" / ("20990101-t%d.md" % i)).write_text(tpl, encoding="utf-8")
        cm = [g("add", "-A")] + [g("-c", "commit.gpgsign=false", "commit", "-q", "--allow-empty", "-m", "chore: lint%d" % k) for k in (1, 2, 3)]
        if any(c.returncode for c in cm): return [("FAIL", "L03", ".", "状態が作れない(git commit 失敗)")]
        normal = ss_out(t, e); (t / "work/STATUS.md").write_text(first + "\n" + "memo " * 1800 + "\n", encoding="utf-8")
        for i in range(3, 8): (t / "desk" / ("20990101-t%d.md" % i)).write_text(tpl, encoding="utf-8")
        worst = ss_out(t, e)
    finally:
        shutil.rmtree(t0, ignore_errors=True)
    sigma = ""; cl = rd(R, "CLAUDE.md")
    for p in CORE_SK: d, _ = fm(rd(R, p)); sigma += d.get("name", "") + d.get("description", "")
    st = {"fresh": (fresh, ag0), "normal": (normal, ag1), "worst": (worst, ag1)}; a = {"sigma_name_description": {"bytes": nb(sigma), "tokens": est(sigma)}}
    for k, (o, ag) in st.items(): txt = ag + cl + sigma + o; a[k] = {"tokens": est(txt), "bytes": nb(txt), "session_start_out": {"tokens": est(o), "bytes": nb(o)}}
    M["always_read"] = a; f = lambda k: "%s=%dトークン/%dB" % (k, a[k]["tokens"], a[k]["bytes"])
    d = "%s %s %s sigma=%dトークン/%dB" % (f("fresh"), f("normal"), f("worst"), a["sigma_name_description"]["tokens"], a["sigma_name_description"]["bytes"])
    out = [("FAIL" if a["normal"]["tokens"] > 2500 or a["fresh"]["tokens"] > 2500 else "PASS", "L03", ".", d)]
    if a["worst"]["tokens"] > 2500: out.append(("WARN", "L03", ".", "worst >2,500トークン: %d(%dB)" % (a["worst"]["tokens"], a["worst"]["bytes"])))
    if nb(sigma) > 620: out.append(("WARN", "L03", ".claude/skills", "Σ(name+description) >620B: %d" % nb(sigma)))
    return out
def L04(R):
    s = rd(R, "AGENTS.md"); M["agents"] = {"lines": nl(s), "bytes": nb(s)}
    return res("L04", [("AGENTS.md", "%d行・%dB・推定%dトークン(上限 62行・4,800B・1,600トークン)" % (nl(s), nb(s), est(s)))] if nl(s) > 62 or nb(s) > 4800 or est(s) > 1600 else [], "AGENTS.md", "%d行・%dB" % (nl(s), nb(s)))
def L05(R):
    fs = core(R); tot = sum(nb(rd(R, p)) for p in fs); M["core"] = {"files": len(fs), "bytes": tot}
    b = [(".", "17ファイルでない: %d" % len(fs))] if len(fs) != 17 else []
    if tot > 32000: b.append((".", "合計 %dB(上限 32,000B)" % tot))
    return res("L05", b, ".", "%dファイル・%dB" % (len(fs), tot))
def L06(R):
    s = rd(R, "fde-guide.md"); b = []; nums = [int(m.group(1)) for m in (re.match(r"(\d+)\.", h) for h in h2s(s)) if m]
    if nl(s) > 300: b.append(("fde-guide.md", "%d行(上限 300)" % nl(s)))
    if nums != list(range(13)): b.append(("fde-guide.md", "章見出しが0〜12の13個でない: %s" % nums))
    M["guide_lines"] = nl(s)
    return res("L06", b, "fde-guide.md", "%d行" % nl(s))
def L07(R):
    b = []
    for p in CORE_SK + PACK_SK:
        s = rd(R, p); d, ok = fm(s)
        if not ok or sorted(d) != ["description", "name", "updated"]: b.append((p, "frontmatter が name・description・updated の3つでない"))
        if nb(d.get("description", "")) > 130: b.append((p, "description >130B"))
        if h2s(s) != SKILL_H2: b.append((p, "H2 が いつ使うか・手順・止まる線・出力 の順でない"))
        if len(re.findall(r"^\d+\.\s", sec(s, "手順"), re.M)) > 7: b.append((p, "番号付き手順 >7"))
        if nl(s) > 40: b.append((p, "%d行(上限 40)" % nl(s)))
        last = [l for l in sec(s, "出力").splitlines() if l.strip()]
        if not last or not last[-1].startswith("失敗時:"): b.append((p, "出力節の最終行が 失敗時: で始まらない"))
    return res("L07", b, ".", "8本")
def word_check(i, pat, allow=False): return lambda R: res(i, scan(R, scope(R) + ["fde-guide.md"], pat, allow), ".", "0件")
L08, L09, L10 = word_check("L08", AMBIG, True), word_check("L09", SECT), word_check("L10", MODEL)
def L11(R): return res("L11", scan(R, [p for p in core(R) if p != "README.md"], DOMAIN), ".", "0件")
def L12(R):
    b = []
    for p in scope(R):
        if p in (".claude/hooks/session-start.sh", ".claude/skills/setup/SKILL.md"): continue
        s = rd(R, p)
        if p == "AGENTS.md": s = s.replace(sec(s, "1."), "")
        if p == "work/STATUS.md": s = "\n".join(s.splitlines()[1:])
        if "<未設定>" in s: b.append((p, "<未設定> の置き場が違う"))
    return res("L12", b, ".", "2か所だけ")
SKIP_MD = {"SKILL.md", "PACK.md", "STATUS.md", "TODAY.md", "kaisetsu.html"}; LATER_NAMES = {"glossary.md", "ledger.md", "map.md"}; LATER = ("docs/review", ".claude/skills/design-doc/glossary.md", "work/status-archive-")
def L13(R):
    b = []; px = re.compile(r"(?<![\w/.\-])((?:templates|desk|docs|work|\.claude|\.atlas|\.github|packs)/[^\s`'\"()\[\]{}$、。,|]*)"); mx = re.compile(r"(?<![\w/.\-])([A-Za-z][\w\-]*\.(?:md|html))(?![\w/])")
    for p in scope(R):
        s = rd(R, p)
        for g in GONE:
            if g in s: b.append((p, "削除したはずの名前: " + g))
        pk = re.match(r"(packs/[^/]+)/", p); bases = [R / pk.group(1), R] if pk else [R]
        def found(x, bare=False): return any((x_b / x).exists() for x_b in bases) or bool(bare and pk and any((R / pk.group(1)).rglob(x)))
        for m in px.finditer(s):
            x = m.group(1)
            if any(c in x for c in ("<", "*", "YYYY")) or x.startswith(LATER): continue
            x = x.rstrip(".:;!?、")
            if not found(x.rstrip("/")): b.append((p, "参照切れ: " + x))
        for m in mx.finditer(s):
            n = m.group(1)
            if n not in SKIP_MD | LATER_NAMES and not any(c in n for c in ("<", "*", "YYYY")) and not found(n, True): b.append((p, "参照切れ: " + n))
    return res("L13", sorted(set(b)), ".", "切れなし")
def L14(R):
    b = []
    for f in sorted(R.rglob("*.sh")):
        rel = f.relative_to(R)
        if rel.parts[0] != ".git" and subprocess.run(["sh", "-n", str(f)], capture_output=True).returncode: b.append((str(rel), "sh -n 失敗"))
    try: cfg = json.loads(rd(R, ".claude/settings.json"))
    except Exception: return res("L14", b + [(".claude/settings.json", "json.load できない")])
    def walk(o): return [o["command"]] if isinstance(o, dict) and "command" in o else sum([walk(v) for v in (o.values() if isinstance(o, dict) else o if isinstance(o, list) else [])], [])
    cmds = walk(cfg.get("hooks", {})); rx = re.compile(r'^sh "\$CLAUDE_PROJECT_DIR/(\.claude/hooks/[\w-]+\.sh)"$')
    for c in cmds:
        m = rx.match(c)
        if not m or not (R / m.group(1)).is_file(): b.append((".claude/settings.json", "hook の書式違いか先が無い: " + c))
    if not cmds: b.append((".claude/settings.json", "hook が1つも無い"))
    return res("L14", b, ".", "構文と配線")
def L15(R):
    b = []
    for pat, only in [(r"8192|8 ?KB|50 ?(件|ファイル)|7 ?(枚|件)", ".claude/hooks/session-start.sh"),
                      (r"AKIA\[|ghp_|github_pat_|xox\[", ".claude/hooks/secret-guard.sh"), (r"Web検索5回", "AGENTS.md")]:
        b += scan(R, [p for p in scope(R) if p != only], pat)
    return res("L15", b, ".", "正本は1か所")
def L16(R):
    t = tempfile.mkdtemp(prefix="lint-l16-")
    try:
        r = subprocess.run(["sh", str(R / T / "hooks/run.sh")], cwd=str(R), capture_output=True, text=True, env=dict(os.environ, TMPDIR=t))
    finally: shutil.rmtree(t, ignore_errors=True)
    return res("L16", [(T + "hooks/run.sh", "exit %d: %s" % (r.returncode, (r.stdout + r.stderr).strip()[-120:]))] if r.returncode else [], T + "hooks/run.sh", "exit 0")
def readme_head(s):
    ls = s.splitlines() + ["", ""]; return [] if ls[0] == "# FDE Atlas" and ls[1] == README_L2 else ["1・2行目が仕様と違う"]
def L17(R):
    s = rd(R, "README.md"); b = [("README.md", x) for x in readme_head(s)]
    if nl(s) > 60 or nb(s) > 4000: b.append(("README.md", "%d行・%dB(上限 60行・4,000B)" % (nl(s), nb(s))))
    if h2s(s) != README_H2: b.append(("README.md", "H2 が仕様の順でない: %s" % h2s(s)))
    b += [("README.md", "書いてはいけない語: " + w) for w in ("chmod", "install.sh") if w in s]
    refs = dict(re.findall(r"^\s*\[([^\]]+)\]:\s*(\S+)", s, re.M)); imgs = re.findall(r"!\[[^\]]*\]\([^)]*\)|<img[^>]*>", s) + [m.group(0) + refs.get(m.group(1), "") for m in re.finditer(r"!\[[^\]]*\]\[([^\]]*)\]", s)]
    b += [("README.md", "数値入りのバッジ") for x in imgs if "image.png" not in x and re.search(r"\d", x)]
    M["readme"] = {"lines": nl(s), "bytes": nb(s)}
    return res("L17", b, "README.md", "%d行・%dB" % (nl(s), nb(s)))
def L18(R):
    b = []
    if rd(R, "CLAUDE.md") != "@AGENTS.md\n": b.append(("CLAUDE.md", "中身が @AGENTS.md と改行だけでない"))
    b += [("README.md", x) for x in readme_head(rd(R, "README.md"))]
    st = (rd(R, "work/STATUS.md").split("\n") or [""])[0]; fresh = "- 業務名: <未設定>" in rd(R, "AGENTS.md").splitlines()  # 未記入の写しは1行目を完全一致で見る
    if (st != STATUS1) if fresh else not st.startswith("次の一手: "): b.append(("work/STATUS.md", "1行目が %s でない" % (STATUS1 if fresh else "次の一手: で始まるもの")))
    td = rd(R, "desk/TODAY.md")
    if not td.startswith("# 今日の机\n") or h2s(td) != TODAY_H2: b.append(("desk/TODAY.md", "1行目か H2 の順が違う"))
    if TODAY_NOTICE not in td.splitlines(): b.append(("desk/TODAY.md", "初期のお知らせ行が違う"))
    tk = rd(R, "templates/review-ticket.md"); P = "templates/review-ticket.md"
    if [norm(h) for h in h2s(tk)] != [norm(h) for h in TICKET_H2]: b.append((P, "H2 の順が違う"))
    ans = [l for l in sec(tk, "回答").splitlines() if l.strip()]
    if [l.split(":")[0] for l in map(norm, ans[:4])] != ["Q1", "Q2", "Q3", "ひとこと"]: b.append((P, "回答4行が違う"))
    last = [l for l in tk.splitlines() if l.strip()]
    if not last or not last[-1].startswith("検証用リンク:"): b.append((P, "最終行が 検証用リンク: でない"))
    return res("L18", b, ".", "書式どおり")
def L19(R):
    b, ag = [], norm(rd(R, "AGENTS.md")); parts = {"0": ag.split("\n## ", 1)[0]}
    for n in "1234567": parts[n] = sec(ag, n + ".")
    for n, ws in L19_WORDS.items():
        b += [("AGENTS.md", "%s節に必須語が無い: %s" % (n, w)) for w in ws if norm(w) not in parts[n]]
    b += [("AGENTS.md", "禁止語がある: " + w) for w in L19_BAN if w in ag]
    try: pm = json.loads(rd(R, ".claude/settings.json")).get("permissions", {})
    except Exception: return res("L19", b + [(".claude/settings.json", "読めない")])
    b += [(".claude/settings.json", "deny に無い: " + w) for w in L19_DENY if w not in pm.get("deny", [])]
    b += [(".claude/settings.json", "ask に無い: " + w) for w in L19_ASK if w not in pm.get("ask", [])]
    b += [(".claude/settings.json", "置いてはいけない項目: " + w) for k in ("allow", "ask", "deny") for w in pm.get(k, []) if re.search(r"force|\bmail\b|sendmail|mutt", w) or (k == "deny" and re.match(r"(Edit|Write)\(", w))]
    try: cs = {c.get("id"): c for c in json.loads(rd(R, T + "hooks/cases.json")) if isinstance(c, dict)}
    except Exception: return res("L19", b + [(T + "hooks/cases.json", "json として読めない")])
    stop = lambda c: c.get("hook") == "guard-bash" and c.get("expect_exit") == 2 and "止めました" in c.get("expect_contains", [])
    b += [(T + "hooks/cases.json", "ケースが無いか止めるケースでない: G%02d" % i) for i in range(1, 18) if not stop(cs.get("G%02d" % i, {}))]
    return res("L19", b, ".", "停止線あり")
def L20(R):
    b = []
    for p, ws in L20_WORDS.items():
        body = norm(sec(rd(R, p), "止まる線")); b += [(p, "止まる線に必須語が無い: " + w) for w in ws if norm(w) not in body]
    return res("L20", b, ".", "必須語あり")
CHECKS = {"L%02d" % i: f for i, f in enumerate([L01, L02, L03, L04, L05, L06, L07, L08, L09, L10, L11, L12, L13, L14, L15, L16, L17, L18, L19, L20], 1)}
def app(s): return lambda R, p: (R / p).open("a", encoding="utf-8").write(s)
def setf(s): return lambda R, p: (R / p).write_text(s, encoding="utf-8")
def drop(w): return lambda R, p: (R / p).write_text(rd(R, p).replace(w, ""), encoding="utf-8")
def rm(R, p): (R / p).unlink()
SK_SETUP = ".claude/skills/setup/SKILL.md"
MUT = {"L01": ("CLAUDE.md", rm), "L02": ("LICENSE", rm), "L03": ("AGENTS.md", app("x" * 4000)), "L04": ("AGENTS.md", setf("a" * 5000 + "\n")), "L05": ("README.md", app("x" * 32000)),
       "L06": ("fde-guide.md", app("\n" * 400)), "L07": (SK_SETUP, app("x\n" * 45)), "L08": ("AGENTS.md", app("\n" + "適切" + "に\n")), "L09": ("AGENTS.md", app("\n" + SECT + "\n")),
       "L10": ("AGENTS.md", app("\nOpus\n")), "L11": ("AGENTS.md", app("\n台帳\n")), "L12": ("README.md", app("\n<未設定>\n")), "L13": ("AGENTS.md", app("\n`work/no-such-file.md`\n")),
       "L14": (".claude/hooks/guard-bash.sh", app("\nif then\n")), "L15": ("AGENTS.md", app("\n8192\n")), "L16": (T + "hooks/run.sh", setf("exit 1\n")), "L17": ("README.md", app("x\n" * 70)),
       "L18": ("CLAUDE.md", setf("x\n")), "L19": ("AGENTS.md", app("\n/cleanup\n")), "L19b": (T + "hooks/cases.json", lambda R, p: (R / p).write_text(rd(R, p).replace('"expect_exit": 2', '"expect_exit": 0', 1), encoding="utf-8")), "L20": (SK_SETUP, drop("推測"))}
def selftest():
    out = []
    for i, (p, fn) in MUT.items():
        d = Path(tempfile.mkdtemp(prefix="lint-self-")) / "w"
        try:
            shutil.copytree(ROOT, d, ignore=shutil.ignore_patterns(".git", "image.png", "__pycache__"))
            (d / ".github").mkdir(exist_ok=True); (d / ".github/image.png").write_bytes(b"x")
            ge = dict(os.environ, GIT_AUTHOR_NAME="lint", GIT_AUTHOR_EMAIL="l@example.com", GIT_COMMITTER_NAME="lint", GIT_COMMITTER_EMAIL="l@example.com")
            for c in (["init", "-q"], ["add", "-A"], ["-c", "commit.gpgsign=false", "commit", "-qm", "base"]): subprocess.run(["git", *c], cwd=d, env=ge, capture_output=True)
            base = [x for x in CHECKS[i[:3]](d) if x[0] == "FAIL"]
            if base: out.append(("FAIL", i, "selftest", "selftest 前提が FAIL: %s %s" % (base[0][2], base[0][3]))); continue
            fn(d, p); r = CHECKS[i[:3]](d); ok = any(x[0] == "FAIL" for x in r)
        except Exception as ex:
            ok, r = False, [("", "", "", "例外: %s" % ex)]
        finally:
            shutil.rmtree(d.parent, ignore_errors=True)
        out.append(("PASS" if ok else "FAIL", i, "selftest", "壊した写しで FAIL を確認" if ok else "壊しても FAIL にならない"))
    return out
def safe(i, f):
    try: return f(ROOT)
    except Exception as ex: return [("FAIL", i, ".", "検査が例外で止まった: %s %s" % (type(ex).__name__, str(ex)[:60]))]
def main():
    a = sys.argv[1:]; rows = selftest() if "--selftest" in a else [x for i, f in CHECKS.items() for x in safe(i, f)]; rows = [(*x[:3], " ".join(str(x[3]).split())) for x in rows]
    if "--json" in a:
        print(json.dumps({"checks": [dict(zip(("status", "id", "path", "detail"), x)) for x in rows], "metrics": M}, ensure_ascii=False, indent=1))
    else:
        for x in rows: print("%s %s %s %s" % x)
    return 1 if any(x[0] == "FAIL" for x in rows) else 0
sys.exit(main())
PYEOF
