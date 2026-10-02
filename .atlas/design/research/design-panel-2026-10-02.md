# V2 設計パネルの記録(2026-10-02)

> 3つの観点(最小主義・非エンジニアUX・実証済み規則の保全)で独立に全ファイル仕様案を作り、2名の審査役が作成者を伏せた中立ラベル(案A/B/C)で採点した。勝ち案「最小主義」を土台に、他案の良点を接ぎ木したものが blueprint-v2.md。その後、責任者の方針(世話を焼きすぎない・root を作業フォルダに・コア17ファイル)で削り直した。blueprint の sources にある「wfb-proposal-0/1/2」はこの3案を指す(0=UX、1=最小主義、2=保全。全文は作業ファイルで、ここには要旨だけを残す)。

## 各案の主張

### 最小主義(ファイル仕様 46件、AGENTS.md 草案 53行・3,746B)

この案は、常時読み込む面と同梱ファイル数を減らし、守らせたい境界は道具に任せることを優先します。AGENTS.md は 53行・約3,750B にします。中核則10、承認線と可逆性、desk/ の規則だけを残し、理由・閾値・書式・失効の書き方はそれぞれ1つのファイルにだけ置きます。閾値は session-start.sh、票の型は review-ticket.md、失効は decisions.md、機密の正規表現は secret-guard.sh です。secret-guard.sh を残すと計画の木構造は 25ファイルになり、上限の23を超えます。そこで作業地図とスキル雛形を独立ファイルにせず、各 SKILL.md の「出力」節に見出しとして固定します。こうするとコアはちょうど23ファイル・約31.5KB に収まり、「雛形を誰も使わない」型の食い違いも起きなくなります。代わりに、自律度表・場所の地図・hook やスキル説明と重なる道具の行は常時読み込みから外します。そのため AGENTS.md 単体では、人間向けの見取り図としての網羅性が下がります。この不足は README・スキル説明・注入メッセージで補い、その前提はコールドスタート試験(K00)で確かめます。

### 非エンジニアUX(ファイル仕様 58件、AGENTS.md 草案 60行・3,662B)

ターミナルを触ったことのない事務職が、初日に README と desk/TODAY.md だけで迷わず動けることを最優先にする。人間側の入口は「desk/ を開いて票に答える」「AI に日本語で頼む(セットアップして/前回の続きをやって/しめて)」の3つだけに固定し、スラッシュコマンド名・ファイル構造・Git 用語は AI 側に閉じ込める。専門語は AGENTS.md・README・票の中で必ず括弧1句で言い換え、票の回答形式(`Q1:` のあとに書く)を機械で検出できる形にして、会話で答えても票に書き写される経路を残す。代わりに、日本語の言い換えで AGENTS.md は内部予算 3,500B を超えて 3,662B になる。その分はスキル description を全本 127B 以下、新規導入時の起動表示を 600B 以下に締めて吸収し、常時読み込みを 5,185B(上限 5,600B)に収める。

### 実証済み規則の保全(ファイル仕様 53件、AGENTS.md 草案 62行・3,719B)

V2 を薄くするときも、実運用で効いた止まる境界と機械の発火装置は1つも落とさない。これをこの設計の最優先にした。V1 の19則、FB1・FB2 で有効と確かめられた項目、desk の4結論には、すべて次のどれかの行き先がある: AGENTS.md の1行、hook・settings・lint による機械検査、スキルの手順、パック、理由付きの削除。止まる線は散文より機械で守る。AGENTS.md 4節の必須語、各スキルの止まる線の必須語、settings の deny を lint(L19・L20)で固定するので、後の「薄くする」改訂で黙って消えることはない。引き受けるトレードオフは1つ。AGENTS.md は下書きの内部予算 3,500B より大きい約3,720B になる。その分はスキル説明を1本 ≤120B、CLAUDE.md を ≤60B、SessionStart 出力の上限を 1,000B に締めて相殺し、常時読み込み ≤5,600B は守る。

## 採点(各5点満点)

| 審査役 | 案 | 薄さ | 汎用性 | 規則の保全 | rmanzoku原則 | 可読性 | 計 |
|---|---|---|---|---|---|---|---|
| 1 | 最小主義 | 5 | 5 | 4 | 5 | 4 | 23 |
| 1 | 非エンジニアUX | 3 | 4 | 4 | 4 | 5 | 20 |
| 1 | 実証済み規則の保全 | 4 | 4 | 5 | 4 | 3 | 20 |
| 2 | 実証済み規則の保全 | 4 | 4 | 5 | 4 | 3 | 20 |
| 2 | 最小主義 | 5 | 5 | 3 | 4 | 4 | 21 |
| 2 | 非エンジニアUX | 4 | 4 | 4 | 4 | 5 | 21 |

平均: 最小主義 22.0 / 非エンジニアUX 20.5 / 実証済み規則の保全 20.0。審査役1は最小主義、審査役2は保全を1位にした(平均差 1.5 以上のため決選なし)。

## 致命的とされた欠陥(審査役の指摘)

- [最小主義] The tree does not list template/.gitignore (the V1 .env/*.key/*.pem exclusions) or docs/.gitkeep, yet the claimed 'exactly 23 files' only works if both exist. The first-line secret defence is left unspecified.
- [最小主義] AGENTS.md section 1 omits the 自律度 line (L1, changed only by the 責任者) that the plan requires, so the rule that the AI does not raise its own autonomy is no longer always loaded.
- [最小主義] Section 2 sends only embedded instructions to the 違和感 ticket. The V1 stop-and-report triggers for a conflicting 正本 and a suspected double run (V1 現在地表 row) are weakened.
- [最小主義] `Bash(git commit *)` is allowed but guard-bash does not block `--amend` or `rebase`. Not rewriting history is enforced only by the wrap-up prose.
- [最小主義] With a 1,000B worst-case session-start output, always-on reaches 5,755B (> 5,600). This is reported only as a metric and never fails.
- [非エンジニアUX] The budgets cannot add up: 3,662 + 140 + 901 + 900 (its own normal-day design value) = 5,603B > 5,600, so L03 fails on a normal day. With the 1,200B cap the total is 5,903B.
- [非エンジニアUX] The description-byte claim is understated: 892 claimed vs 901 measured. wrap-up's description is 130B, exactly at the limit.
- [非エンジニアUX] secret-guard.sh skips any file_path under templates/, so a token written there gets past the pre-write block.
- [非エンジニアUX] research step 4 and minutes step 2 restate the injection rule, duplicating the AGENTS.md section 2 canonical home.
- [非エンジニアUX] Section 2 omits the conflicting-正本 and double-run triggers (same as A). guard-bash does not block amend or rebase.
- [実証済み規則の保全] L03 measures only the fresh-install session-start output. The plan requires the larger of fresh and normal. The normal day is about 5,505B and the 1,000B cap gives 5,675B (> 5,600), which is never checked.
- [実証済み規則の保全] The core file count excludes .gitignore and .gitkeep, so there are 25 real files; the strict '≤23 files' target is met only by redefining the count.
- [実証済み規則の保全] PACK.md lines go into AGENTS.md section 8 (PJ追記) instead of section 7, so removing a pack means editing project-specific rules. The core/pack boundary is less clean.
- [実証済み規則の保全] The template README has a slash-command table and a 'chmod +x .claude/hooks/*.sh' fix, which is jargon for the target non-engineer reader.
- [実証済み規則の保全] Not fatal: core '23 files' depends on not counting .gitignore and docs/.gitkeep; the real count is 25. It is the same metric definition as the plan's tree, but it should be stated in README/lint metrics
- [実証済み規則の保全] Force push, -f, amend, rebase, mail and sendmail are in settings deny and also in guard-bash. Plan decision 4 says to remove the duplication, and lint L19 makes keeping it mandatory
- [実証済み規則の保全] Worst case (STATUS 9KB + 8 tickets, OUT_MAX 1,000) is about 5,620B by description only and about 5,675B with skill names, so it exceeds 5,600 (L03 only WARNs)
- [実証済み規則の保全] The 5 V1 fixtures moved to tests/fixtures (minutes_transcript, notice_injection, invoice/contract) appear only in deletions and have no tree spec entries, so the Build/Prune step can lose them
- [最小主義] `Bash(git commit *)` is allowed and guard-bash does not stop --amend or rebase, so history rewrites now run with no prompt. The V1 stop line is weakened and kept only in prose
- [最小主義] The tree has no spec entry for template/.gitignore or template/docs/.gitkeep. The first defense against committing key files and the docs/ folder are unspecified, and the count 23 assumes both files exist
- [最小主義] Autonomy L1 is not in AGENTS at all (V1 rule 7 and the autonomy table vanish from the delivered template). cleanup no longer has the item that proposes changing autonomy
- [最小主義] deliverable-review drops the FB1 2.7 check (grep every occurrence of a fixed value, including generators and other documents), the regenerated-number check and sequential source numbering
- [最小主義] secret-guard regex has no github_pat_ pattern
- [非エンジニアUX] Same as B: `git commit *` is allowed and amend/rebase are not blocked by the hook, so history rewrites go through silently
- [非エンジニアUX] OUT_MAX 1,200 puts the worst-case always-on at about 5,850 to 5,900B, over 5,600 (lint only WARNs)
- [非エンジニアUX] The [未commit] (uncommitted changes) warning is the last line of output, so when STATUS is long, head -c cuts it first
- [非エンジニアUX] secret-guard skips paths under templates/, so a key written into templates/ is not stopped
- [非エンジニアUX] The 'adoption take-on items' rule is not in AGENTS section 4. It is only in deliverable-review item 2, so it does not apply to work that is not a deliverable
- [非エンジニアUX] skill-create records '(試験中)' (trial) in README instead of AGENTS. Unverified skills are invisible to the AI's always-on side, and cleanup has to read the human-facing document

## 勝ち案へ接ぎ木した点

- 実証済み規則の保全 → `tests/lint.sh`: Add lint checks L19/L20 that lock the must-words (AGENTS.md section 4 stop-line words, the sudo/force-push/.env-class deny entries, each core skill's stop-line words). A later thinning edit can then never silently remove a proven boundary.(理由: Turns the preservation criterion into an automated check. Today A protects these boundaries only through the reviewLens prose.)
- 実証済み規則の保全 → `template/AGENTS.md`: Widen section 2's 違和感 triggers to 'embedded instructions, a conflicting 正本, or a suspected double run → stop and file a ticket quoting the original'.(理由: Restores the V1 現在地表 row (指示混入・SoR矛盾・二重実行の疑い → 即停止). A dropped two of its three triggers.)
- 実証済み規則の保全 → `template/AGENTS.md`: Add the line '自律度: L1(読む・下書きまで)。変えるのは責任者' to section 1, and prefix the section 4 approval line with '自律度に関係なく'.(理由: The plan requires 自律度 in section 1. Without it, the rule that the AI never raises its own autonomy is not always loaded. Costs about 90B, still under 4,000B.)
- 実証済み規則の保全 → `template/.claude/hooks/guard-bash.sh`: In guard-bash, split the command into segments at ; && || |, and block split or long rm flags (-r -f, --recursive --force), `+<ref>` push, `git commit --amend` and `git rebase`. Add the matching cases.(理由: A allows `git commit *` without a prompt, so history rewriting is stopped only by prose. Per FB2 2.0, prose that was not followed should be mechanized.)
- 実証済み規則の保全 → `template/.claude/hooks/secret-guard.sh`: Give secret-guard a `--staged` mode that checks added lines and staged filenames (.env, .env.*, *.key, *.pem, id_rsa*, *.p12), add the github_pat_ pattern, and never echo the matched string.(理由: Removes the separate filename check from wrap-up step 6 so the whole secret check has one home, and stops leaking the detected value into the context.)
- 非エンジニアUX → `template/.gitignore`: Specify template/.gitignore explicitly (the V1 10 lines) and docs/.gitkeep in the tree.(理由: A's '23 files' count already depends on these two files, but neither is specified. The .gitignore is the first defence for secrets.)
- 実証済み規則の保全 → `template/checklists/deliverable-review.md`: Add deliverable-review items for numbering sources, for re-running the generator and grepping every occurrence of a confirmed value (including generators and other documents), and for leaving archive/ and decisions.md history unedited.(理由: Covers FB1 2.7 and FB2 2.2③ (反映漏れ and rewriting historical records). A sends these only to the guide, which is not distributed.)
- 非エンジニアUX → `template/README.md`: Add a short 'はじめての日' block (start claude, answer the trust prompt with はい, say 'セットアップして', say 'しめて') and a note that answering a ticket in conversation is fine because the AI copies it into the ticket.(理由: A's README never says what to do on day one, so 'what do I do now' is not always answerable without the install.sh output.)
- 非エンジニアUX → `template/desk/TODAY.md`: Set TODAY.md's initial お知らせ to 'はじめに: このフォルダで claude を起動し「セットアップして」と入力してください。'(理由: desk/ is the only place the human looks, so the next step must appear there before /setup runs.)
- 非エンジニアUX → `template/.claude/settings.json`: Deny `Edit(.claude/hooks/**)` and `Edit(.claude/settings.json)` (probe that the pattern format works).(理由: Stops the agent from weakening its own enforcement layer, which A currently leaves to trust.)
- 非エンジニアUX → `scripts/install.sh`: Have install.sh set a local fallback git user.name/email when none is configured (no `|| true`) and set core.quotepath false.(理由: Without this, the first commit fails silently on a non-engineer's fresh machine and K00 cannot pass.)
- 非エンジニアUX → `tests/regression-cases.md`: Add a day-one cold-start check: in a fresh session after install, say only 'こんにちは'. Pass if the AI recommends /setup.(理由: Tests the [記入欄] injection path, which is the only way A's thin README leads the user to setup.)
- 非エンジニアUX → `template/templates/review-ticket.md`: In the ticket template, require one plain-text sentence before the Mermaid block that says the same thing as the diagram.(理由: The ticket stays decidable in viewers that do not render Mermaid (desk conclusion 4: 絞る≠削る).)
- 非エンジニアUX → `template/README.md`: Replace the README's command table with a 4-step 'はじめての日' (first day) section and a 'こんなときは、こう言う' table (what to say, no slash-command names). Move troubleshooting such as chmod out of README(理由: Lets a non-engineer answer 'what do I do now' in plain Japanese. This is A's weakest score (readability 3))
- 非エンジニアUX → `template/templates/review-ticket.md`: Add to the ticket: an answer-instruction line right after the header, a '結論(AIのおすすめ)' (AI's recommendation) section, one sentence before each Mermaid diagram, and a 回答 section using `Q1:` and `ひとこと:` lines (change session-start's answered-ticket check and lint L18 to match)(理由: Answering after a `> ` line is hard for non-engineers. Labeled lines keep answered/unanswered detection mechanical)
- 非エンジニアUX → `template/desk/TODAY.md`: Make TODAY.md's initial notice say 'このフォルダで claude を起動し「セットアップして」と入力' (start claude in this folder and type 'set it up'). Mark overdue tickets with (期限切れ), and have session-start count overdue tickets(理由: Even on the first day, the desk shows the next step)
- 非エンジニアUX → `scripts/install.sh`: If git user.name/email are not set, set a temporary value scoped to this folder only and print one line saying so. Add core.quotepath false. Remove V1's `|| true` on the first commit(理由: Stops the initial commit from failing silently on a fresh machine (v1-audit-history 1e42368))
- 非エンジニアUX → `tests/cold-start.md`: Add a first-day scenario: right after install, in a new session, the user says only 'こんにちは'. Pass if the AI suggests /setup(理由: Puts cold-start acceptance on the first day as well as on resume)
- 非エンジニアUX → `template/.claude/settings.json`: Add `Edit(.claude/settings.json)` and `Edit(.claude/hooks/**)` to settings deny (check in Probe that they take effect)(理由: Stops the AI from weakening the enforcement layer itself. Mechanizes it rather than writing it as prose)
- 最小主義 → `template/CLAUDE.md`: Make CLAUDE.md the single line `@AGENTS.md` (11B), with no comment line(理由: Cuts always-on bytes. The comment line is not needed for behavior)
- 最小主義 → `template/.claude/settings.json`: Per plan decision 4, remove `git push --force*`/`-f*`/mail/sendmail from settings deny so guard-bash is the single mechanical layer (keep the hook blocking amend and rebase). Drop the matching deny items from lint L19 and require the hook strings instead(理由: Removes the settings-plus-hook duplication and matches rmanzoku 'do not hold the same rule twice')
- 最小主義 → `template/.claude/skills/brainstorm/SKILL.md`: Fix brainstorm's work-map headings in the SKILL.md output section and delete workmap.md, so core comes to 22 by the metric and 24 real files(理由: Closes the gap with the 23-file target and removes one more 'template nobody uses' file)
- 最小主義 → `tests/lint.sh`: In lint L13 (reference check), exclude paths created at run time (work/log.md, work/status-archive-*, .claude/packs/, context/ledger.md, context/glossary.md)(理由: Prevents false FAILs on references to files that are not shipped)
- 非エンジニアUX → `fde-guide.md`: Put the user-facing glossary (commit=セーブ, push=共有先への送り出し, 正本, 票, diff, and so on; up to 8 terms) as the canonical source in guide chapter 9. Gloss each term in parentheses once, at its first use in AGENTS/README(理由: Gives one canonical home for glosses and keeps glossing consistent across files)
