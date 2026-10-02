"""E2E の前提づくり。使い方: prep.py <case> <dest> --today YYYY-MM-DD [--stage 2]
case の正規形は K01a・K01b(K01'a・K01'b も受け付けて正規形にそろえる)。base.json・commit メッセージも正規形。"""
import argparse, hashlib, json, re, shutil, subprocess, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
FIX = ROOT / ".atlas/tests/fixtures"
PLACE = {  # case -> [(fixture, 置き場。{d}=YYYYMMDD)]
    "K01a": [("notice_injection.md", "work/inbox/notice_injection.md")], "K03": [("research_question.md", "work/inbox/research_question.md")],
    "K05": [("ticket_answered.md", "desk/{d}-差異メモの形.md"), ("ticket_open.md", "desk/{d}-差異の基準.md")],
    "KS1": [("@notes", "work/{g}/notes-{d}.md")], "KP3": [("sample_requirements.md", "docs/sample-requirements.md")],
    "K06": [("mail_draft.md", "work/mail/draft.md")], "K07": [(None, f"work/tmp/{n}.txt") for n in "abc"],
    "KP1": [("ledger_seed.md", "context/ledger.md")] + [(f"{n}.md", f"work/inbox/{n}.md") for n in ("invoice_dummy", "contract_dummy", "notice_injection")],
    "KP2": [("minutes_transcript.md", "work/inbox/minutes_transcript.md")]}
PLACE["K01b"], PLACE["K05b"] = PLACE["K01a"], PLACE["K05"]
PACKS = {"KP1": "si-documents", "KP2": "minutes", "KP3": "si-documents"}
COPY_ONLY = {"K00", "cold-start"}; CASES = set(PLACE) | COPY_ONLY | {"blank", "K04", "KH1"}
def canon(case): return case.replace("'", "").replace("\u2019", "").replace("\u2032", "")
def run(dest, *cmd):
    return subprocess.run(cmd, cwd=dest, check=True, capture_output=True, text=True).stdout
KEEP = {"desk/TODAY.md", "work/STATUS.md", "docs/.gitkeep"}  # desk/ work/ docs/ は製品に含まれるファイルだけ
def copy_root(case, dest):
    out = (".git/", ".atlas/", ".github/", ".claude/settings.local.json")
    ls = run(ROOT, "git", "-c", "core.quotepath=false", "ls-files", "--cached", "--others", "--exclude-standard", "-z")
    for rel in sorted(set(ls.split("\0")) - {""}):
        if not (rel.startswith(out) or not (ROOT / rel).is_file() or (rel.startswith(("desk/", "work/", "docs/")) and rel not in KEEP)):
            (dest / rel).parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / rel, dest / rel)
def write_base(case, dest):
    h = {p.relative_to(dest).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
         for p in sorted(dest.rglob("*")) if p.is_file()}
    (dest.parent / f"{case}.base.json").write_text(json.dumps(h, ensure_ascii=False, indent=1), encoding="utf-8")
def fill(dest):
    a = json.loads((FIX / "setup_answers.json").read_text(encoding="utf-8"))
    out, ag = [], dest / "AGENTS.md"
    for line in ag.read_text(encoding="utf-8").splitlines():
        k = line[2:].split(":")[0] if line.endswith(": <未設定>") else ""
        if k in a and k != "正本":
            line = f"- {k}: {a[k]}"
        elif k.startswith("正本"):
            line = f"- {k}:" + "".join(f"\n  - {s['情報']}: {s['場所']}(確かめ方: {s['確かめ方']})" for s in a["正本"][:3])
        out.append(line)
    ag.write_text("\n".join(out) + "\n", encoding="utf-8")
    st = dest / "work/STATUS.md"
    rows = st.read_text(encoding="utf-8").splitlines()
    rows[0] = f"次の一手: 「相談したい」と頼み {a['業務名']} の作業地図を作る"  # /setup 手順3の文面と一字一句そろえる
    st.write_text("\n".join(rows) + "\n", encoding="utf-8")
    t = dest / "desk/TODAY.md"
    for n, x in (("AGENTS.md 1節", ag.read_text(encoding="utf-8").split("## 1.")[1].split("\n## ")[0]), ("work/STATUS.md", st.read_text(encoding="utf-8"))):
        "<未設定>" in x and sys.exit(f"fill 後も {n} に <未設定> が残っています")
    old = "はじめに: このフォルダで claude を起動し「セットアップして」と入力してください。"
    txt = t.read_text(encoding="utf-8")
    old in txt or sys.exit("desk/TODAY.md に『はじめに』の文がありません。prep.py の fill と /setup 手順3を揃えてください")
    t.write_text(txt.replace(old, f"準備ができました: 次は {a['業務名']} の作業地図づくりです。「相談したい」と話しかけてください。"), encoding="utf-8")
def apply_pack(dest, name):  # /setup 手順4と同じ規則
    src = dest / "packs" / name
    for f in sorted(src.rglob("*")):
        rel = f.relative_to(src)
        if f.is_file() and rel.name != "PACK.md":
            to = dest / rel
            if not to.exists():
                to.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(f, to)
    sec = (src / "PACK.md").read_text(encoding="utf-8").split("## AGENTS.md 7節に足す行")[1].split("\n## ")[0]
    add = [l for l in sec.splitlines() if l.startswith("- ")]
    p = dest / "AGENTS.md"
    lines = p.read_text(encoding="utf-8").splitlines()
    i = next(n for n, l in enumerate(lines) if l.startswith("- 上に無い状況 →"))
    for l in reversed(add):
        if l not in lines:
            lines.insert(i, l)
    p.write_text("\n".join(lines) + "\n", encoding="utf-8")
NOTES = "# 作業ノート\n\n> 架空データ。回帰テスト用。\n\n" + "".join(f"## {n}回目\n手順: 請求書を確認し、宛先を照合し、PDFを書き出して送付する\n\n" for n in ("1", "2"))
def pad_status(dest):  # K05b: STATUS を 9,000B にする。詰め物の行は製品の最終行(人間への依頼は…)の直前に入れ、最終行を製品の行のまま残す(/wrap-up は末尾の1行を残すため)
    st = dest / "work/STATUS.md"; rows = st.read_text(encoding="utf-8").splitlines()
    base = "\n".join(rows[:-1] + ["<!---->"] + rows[-1:]) + "\n"; n = 9000 - len(base.encode())
    st.write_text("\n".join(rows[:-1] + ["<!--" + "x" * n + "-->"] + rows[-1:]) + "\n", encoding="utf-8")
def place(case, dest, today):
    g = json.loads((FIX / "setup_answers.json").read_text(encoding="utf-8"))["業務名"] if case != "blank" else ""
    for fx, to in PLACE.get(case, []):
        t = dest / to.format(d=today.replace("-", ""), g=g)
        t.parent.mkdir(parents=True, exist_ok=True)
        t.write_text(NOTES, encoding="utf-8") if fx == "@notes" else shutil.copy2(FIX / fx, t) if fx else t.write_text(f"> 架空データ。回帰テスト用。{t.name}\n", encoding="utf-8")
def commit(dest, msg):
    [run(dest, "git", *c) for c in (("add", "-A"), ("-c", "commit.gpgsign=false", "commit", "-q", "-m", msg))]
    (dest / ".git/prep-head").write_text(run(dest, "git", "rev-parse", "HEAD"))
def stage2(dest):
    for f in sorted((dest / "desk").glob("*.md")):
        txt = f.read_text(encoding="utf-8"); ls = txt.split("\n")
        if "種別: 承認" not in txt or "## 回答" not in ls: continue
        h = ls.index("## 回答")
        ix = {k: next((n for n in range(h, len(ls)) if ls[n].startswith(k)), None) for k in ("Q1:", "ひとこと:")}
        if ix["Q1:"] is not None:
            for k, v in (("Q1:", "Q1: はい"), ("ひとこと:", "ひとこと: 実行済み(送信しました)")): ix[k] is None or ls.__setitem__(ix[k], v)
            f.write_text("\n".join(ls), encoding="utf-8")
            return commit(dest, "test: prep K06 stage2")
    sys.exit("承認の伺いが desk/ にありません")
def check(case, dest, today, stage):
    re.fullmatch(r"\d{4}-\d{2}-\d{2}", today) or sys.exit(f"--today は YYYY-MM-DD です: {today}")
    case in CASES or sys.exit(f"不明なケース: {case}")
    stage == 1 or case == "K06" or sys.exit("--stage 2 は K06 だけです")
    stage == 2 or not dest.exists() or sys.exit(f"{dest} が既にあります")
    for fx in [f for f, _ in PLACE.get(case, []) if f and f[0] != "@"] + ["setup_answers.json"] * (case != "blank"):
        stage == 2 or (FIX / fx).exists() or sys.exit(f"fixture がありません: {fx}")
def main():
    ap = argparse.ArgumentParser(); ap.add_argument("case"); ap.add_argument("dest"); ap.add_argument("--today", required=True)
    ap.add_argument("--stage", type=int, choices=[1, 2], default=1); a = ap.parse_args(); a.case = canon(a.case); dest = Path(a.dest).resolve(); check(a.case, dest, a.today, a.stage)
    if a.stage == 2: return stage2(dest)
    copy_root(a.case, dest)
    if a.case in COPY_ONLY: return write_base(a.case, dest)
    run(dest, "git", "init", "-q"); [run(dest, "git", "config", k, v) for k, v in (("user.name", "FDE Atlas Test"), ("user.email", "fde-atlas@localhost"))]
    if a.case != "blank":
        fill(dest); a.case in PACKS and apply_pack(dest, PACKS[a.case])
        a.case == "K05b" and pad_status(dest); place(a.case, dest, a.today)
    commit(dest, f"test: prep {a.case}")
main()
