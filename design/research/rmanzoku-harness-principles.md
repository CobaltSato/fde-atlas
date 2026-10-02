# rmanzoku.net に学ぶ薄いハーネスの設計原則(調査結果)

> 調査日: 2026-10-02 / 方法: 記事19本を抽出役(適用役モデル)が1本ずつ読み、統合役(上位役モデル)が原則へまとめ、別の抽出役が各原則を出典へ遡って検証した。
> 出典は https://rmanzoku.net/ の記事。dotfiles(https://github.com/rmanzoku/dotfiles)の AGENTS.md・common-rules.md・ADR 0046 も併読した。

# 薄く汎用的なAIハーネスの設計原則(rmanzoku.net 記事群からの抽出)

## 結論

- ハーネスは「AIを強くする装置」ではなく「安心して任せられる範囲を定義する装置」。品質を決めるのはモデルより環境([ai-harness](https://rmanzoku.net/articles/ai-harness/), [about](https://rmanzoku.net/about/))。
- 薄く始める。最小構成は「作業フォルダ+目的・正本・制約・出力形式・完了条件の5項目」と「作成者と点検者の分離」と「成果物をファイルに残すこと」([ai-harness](https://rmanzoku.net/articles/ai-harness/), [multi-ai-unix-philosophy](https://rmanzoku.net/articles/multi-ai-unix-philosophy/))。
- AGENTS.mdは短いハブにする(目安は約60行。要約経由の数値)。理由・手順・履歴は別の場所に置く([agents-md-tips](https://rmanzoku.net/articles/agents-md-tips/))。
- 作るのと同じ重さで捨てる。書かれたものはすべて前例として増幅されるので、掃除が増幅に負けると幻滅期に入る([ai-disillusionment](https://rmanzoku.net/articles/ai-disillusionment/), [ai-markov-chain](https://rmanzoku.net/articles/ai-markov-chain/))。
- 健全性の指標は1つ。履歴なしの新規セッションが、正本だけで代表業務を完走できるか(コールドスタート成功率)。
- 人間の席は「責任の終端」と「保留判断」。加えて、盤(ループの切り方と完成定義)を引き直す役を持つ([loop-engineering-conway](https://rmanzoku.net/articles/loop-engineering-conway/), [loop-silos](https://rmanzoku.net/articles/loop-silos/))。

## 設計原則

| # | 原則 | 薄いハーネスへの含意 | 出典 |
|---|---|---|---|
| P1 | 投資先はpromptやモデルではなく環境(5要素: Context / SoR / Artifacts / Bounded Autonomy / Review) | 5要素の置き場を1つずつ用意するだけにする | [ai-harness](https://rmanzoku.net/articles/ai-harness/), [about](https://rmanzoku.net/about/) |
| P2 | 小さく始め、運用で育てる。1業務1ワークフロー | 同梱物を最小にし、成功例からskillを生やす | [ai-harness](https://rmanzoku.net/articles/ai-harness/), [ai-bpo](https://rmanzoku.net/articles/ai-bpo/), [multi-ai](https://rmanzoku.net/articles/multi-ai-unix-philosophy/) |
| P3 | AGENTS.mdは現在形のルールと入口リンクだけを置くハブ | 背景・理由・手順を外へ出す | [agents-md-tips](https://rmanzoku.net/articles/agents-md-tips/), [claude-md-views](https://rmanzoku.net/articles/claude-md-views/) |
| P4 | 意図の種類ごとに置き場を分け、正本を固定する。一時知識と永続知識を分ける | フォルダは「正本/作業中/成果物/アーカイブ」程度にする | [agents-md-tips](https://rmanzoku.net/articles/agents-md-tips/), [ai-agents](https://rmanzoku.net/articles/ai-agents/) |
| P5 | 追加と削除を1つの変更にする。例外には解除条件を付ける | ファイル数は掃除の負債。少ないほど掃除が回る | [ai-harness](https://rmanzoku.net/articles/ai-harness/), [ai-disillusionment](https://rmanzoku.net/articles/ai-disillusionment/) |
| P6 | コールドスタート成功率で測る。セッションはいつでも捨てられる状態にする | 受け入れ試験はこの1本にする | [ai-harness](https://rmanzoku.net/articles/ai-harness/), [ai-markov-chain](https://rmanzoku.net/articles/ai-markov-chain/) |
| P7 | 決定論的な処理はコード、曖昧な解釈はAI、不可逆な判断は人間 | hookは「書いても守られない」と分かった項目に限る | [ai-bpo](https://rmanzoku.net/articles/ai-bpo/), [agents-md-tips](https://rmanzoku.net/articles/agents-md-tips/) |
| P8 | 停止線は損害の深さと責任の宛先で引く。保留率込みで価値を定義する | 汎用部分は少数の停止線だけを固定する | [ai-harness](https://rmanzoku.net/articles/ai-harness/), [loop-engineering-conway](https://rmanzoku.net/articles/loop-engineering-conway/) |
| P9 | 完了は証跡で判断する。工程の移行はファイルの存在を条件にする(Artifact Gate) | 「完了報告には成果物のパスを添える」の1ルール | [ai-agents](https://rmanzoku.net/articles/ai-agents/), [agents-md-tips](https://rmanzoku.net/articles/agents-md-tips/) |
| P10 | 生成役と批判役を分ける。効くのはモデルの数ではなく役割分離 | 汎用部分は「作成者≠点検者」だけを持つ | [ai-agents](https://rmanzoku.net/articles/ai-agents/), [ai-answer-space-skills](https://rmanzoku.net/articles/ai-answer-space-skills/) |
| P11 | Skillは回答空間の制御テンプレート。置いたら必ず使う。モデル名は書かない | 同梱skillを必ず使われるものに絞る | [ai-answer-space-skills](https://rmanzoku.net/articles/ai-answer-space-skills/), [claude-md-views](https://rmanzoku.net/articles/claude-md-views/) |
| P12 | 境界では要約ではなく正本への参照を渡し、必須項目を検証する | 引き継ぎの書式は数項目にする | [loop-silos](https://rmanzoku.net/articles/loop-silos/), [ai-markov-chain](https://rmanzoku.net/articles/ai-markov-chain/) |
| P13 | 1ループに1つの完成定義、1案件に1つの作業場所 | 案件ごとにフォルダを分け、完了条件は1つにする | [loop-engineering-conway](https://rmanzoku.net/articles/loop-engineering-conway/), [multi-ai](https://rmanzoku.net/articles/multi-ai-unix-philosophy/) |
| P14 | 実装と審判を同じ手に持たせない。審判は人間が持ち、定期的に引き直す | 承認基準はAIが編集しない人間所有のファイルにする | [ai-markov-chain](https://rmanzoku.net/articles/ai-markov-chain/) |
| P15 | 導入の完了定義に「掃除が回っていること」を含める。完成度は盤を引き直す速度で測る | 同梱量ではなく棚卸しが回ることで評価する | [ai-disillusionment](https://rmanzoku.net/articles/ai-disillusionment/), [loop-silos](https://rmanzoku.net/articles/loop-silos/) |

## AGENTS.md

- 位置づけ: 説明文ではなく、毎回渡される前提コンテキスト。書いた内容は出力を通じて増幅される([claude-md-views](https://rmanzoku.net/articles/claude-md-views/))。
- 書くもの: 目的、用語、正本の場所、制約、避けたい不可逆な失敗、出力形式、完了条件、入口リンク([ai-harness](https://rmanzoku.net/articles/ai-harness/), [future-context](https://rmanzoku.net/articles/future-context/))。
- 書かないもの: 理由(決定記録へ)、経緯(履歴へ)、手順(Skillへ)、未完了(タスク台帳へ)、機械で検出できる違反(validatorへ)([agents-md-tips](https://rmanzoku.net/articles/agents-md-tips/))。
- 層を分ける: 個人の文体・出力形式はユーザーレベルに、業務の前提はフォルダ直下に置く([claude-md-views](https://rmanzoku.net/articles/claude-md-views/))。
- 例外には理由・適用範囲・解除条件を付ける。矛盾した古いルールは消す。
- 事務職向けには、会社の言葉・正本・権限・承認線を「AIが読める地図」として持たせる([about](https://rmanzoku.net/about/))。

## Skills

- 種類: ドメイン特化型、ワークフロー型(探索の順序まで固定)、スタイル型([ai-answer-space-skills](https://rmanzoku.net/articles/ai-answer-space-skills/))。
- 成功した依頼をskillにする。失敗はルール・承認ゲートの更新に回す([ai-harness](https://rmanzoku.net/articles/ai-harness/))。
- 素朴なMarkdownでよい。重要なのは「置いたら必ず使う」運用([claude-md-views](https://rmanzoku.net/articles/claude-md-views/))。
- モデル名は書かずroleで指定する([multi-ai](https://rmanzoku.net/articles/multi-ai-unix-philosophy/))。手順は正本に任せ、複製しない([agents-md-tips](https://rmanzoku.net/articles/agents-md-tips/))。
- 修正したら過去の成功事例で回帰確認してから再配布する([ai-disillusionment](https://rmanzoku.net/articles/ai-disillusionment/))。

## サブエージェントとモデルの使い分け

記事が言っていること:
- 「どのモデルが最強か」ではなく「どこを誰に担当させるか」を考える([ai-agents](https://rmanzoku.net/articles/ai-agents/))。
- 親は統合判断に集中し、実作業は子に任せる。調査は並列のresearcherに分け、統合artifactにまとめる([ai-dev-environment-mbp](https://rmanzoku.net/articles/ai-dev-environment-mbp/))。
- 委任では、親が目的・制約・期待する出力・検証方法を渡す。子は親の文脈を引き継がない。最終判断は親が持つ。secretは渡さない([agents-md-tips](https://rmanzoku.net/articles/agents-md-tips/))。
- レビューには別モデルを1回挟むと見落としの種類が変わる。ただし常に精度が上がるとは限らない([ai-answer-space-skills](https://rmanzoku.net/articles/ai-answer-space-skills/))。
- role→モデルの対応はregistryで一元管理する。モデル変更を運用変更として扱える([multi-ai](https://rmanzoku.net/articles/multi-ai-unix-philosophy/))。
- 単純な並列委譲はシェル並列が速い(約101.7秒。Subagentは約191.5秒)。失敗隔離・再試行・分岐が要る運用はSubagentが向く([subagent-review-orchestration](https://rmanzoku.net/articles/subagent-review-orchestration/))。
- 機密案件にはローカルLLM(27B〜40B級)を分ける([ai-dev-environment-mbp](https://rmanzoku.net/articles/ai-dev-environment-mbp/))。

記事が決めていないこと: フロンティア/中位/小型の具体的な割り当ては論じられていない。言えるのは次の範囲に限る(推論)。roleで定義して差し替え可能にする。統合判断と最終判断は親に残す。決定論的な部分はモデルではなくコードにする。

## コンテキスト衛生(増幅と掃除)

- AIは経緯を知らず、現在の状態だけで出力する。状態は追記でしか変わらず、撤回済みの前提も同じ権威で残る([ai-markov-chain](https://rmanzoku.net/articles/ai-markov-chain/))。
- 概念式はE(t+1)=α(1−c)E(t)+(1−d)(L+N)。掃除率c=0なら誤りは増幅しながら積もる(係数は概念装置で、実測値ではない)。
- 幻滅期とは、ゴミの発生速度が検出と掃除の速度を上回った状態。待っても治らず、処方は掃除([ai-disillusionment](https://rmanzoku.net/articles/ai-disillusionment/))。
- 掃除の型: Active/Archiveの分離、棚卸しの定例、失効条件の明記、追加と削除のセット、解除条件付きの例外。
- 地図はチャットの外のファイルに置く。MEMORYは揮発するキャッシュ。要約・compactionは非可逆で、誤りは残り意図は残らない。
- 詰め込まない。入力が長いだけで性能が落ちる計測がある。地図とログ検索の併用は、全件投入に近いスコアを少ないトークンで出した(119点対125点)。
- 問題は同じ部屋にいるうちに直す。境界を越えると、直すコストが上がる。

## 人間の役割(人間の席)

- 席は2つ: 責任の終端と保留判断。停止線は「責任の宛先が要るか」で引く([loop-engineering-conway](https://rmanzoku.net/articles/loop-engineering-conway/))。
- 残る仕事: 何を作るか決めること、基準を保持すること、署名すること([painter-without-brush](https://rmanzoku.net/articles/painter-without-brush/))。決める・止める・損を引き受けること([fractional-cto](https://rmanzoku.net/articles/fractional-cto/))。
- 未来のコンテキストを持ち、制約として渡す。違和感の段階で止める([future-context](https://rmanzoku.net/articles/future-context/))。
- 統制点はレビューではなく検証系の設計に置く([fractional-cto](https://rmanzoku.net/articles/fractional-cto/))。検証は選別弁であり、撤退の決裁速度が律速になる。速度は誤放流率と対にして見る([selection-valve](https://rmanzoku.net/articles/selection-valve/))。
- 全員をAI習熟させない。少数の分解者と、業務知識を持つ多数の検証者で分担する([selection-valve](https://rmanzoku.net/articles/selection-valve/))。
- 検証できない業務は、担当者と再訪トリガー付きの保留リストで持つ。盤は定期的に引き直す([loop-silos](https://rmanzoku.net/articles/loop-silos/))。
- 基準は手を動かした経験からしか育たない。承認するだけの運用は基準を劣化させる([painter-without-brush](https://rmanzoku.net/articles/painter-without-brush/))。

## アンチパターン

- AGENTS.mdを百科事典にする。理由や経緯まで常時コンテキストに載せる。
- ルールを足すだけで消さない。解除条件のない例外を作る。
- 地図やテンプレートを納品して終わりにし、掃除機構を持ち込まない。「貯めれば資産」と考える。
- 単一AIの自己レビューで閉じる。モデルを並べること自体を目的にする。
- Skillにモデル名を直書きする。置いたskillを使ったり使わなかったりする。
- 要約で引き継ぐ。MEMORYを正本扱いする。コンテキストに詰め込む。
- 「やりました」で完了とみなす。不可逆な判断をAIに任せる。実装と審判を同じ手に持たせる。
- 全社に一斉導入する。全員をAI習熟させようとする。
- 単純な並列委譲のためだけにSubagentを使う。

## 未決の問い

- 階層別モデルをどのroleに割り当てるか(記事は示していない)。
- 約60行という目安の逐語根拠と、事務職向けの適正な長さ。
- 事務業務でテストやCIに相当する検出装置の最小構成。棚卸しの頻度と担当者。
- 非エンジニアが保守できるhookやvalidatorの範囲。
- 同梱skillの適正数。人間検証者の優位が時限的であることを踏まえた見直しのタイミング。

## FDE Atlas V2 への示唆

以下は、上の原則を現状の数字(約47ファイル、AGENTS.md 155行、長い規範ガイド、skill 10、チェックリスト6、テンプレート12、hook 3)に当てはめた推論です。

1. **AGENTS.mdをハブ化する**: 155行を、5項目(目的・正本・制約・出力形式・完了条件)、停止線、入口リンクに削る。目安は約60行(P3)。規範ガイドの「理由」部分は、必要なときだけ読む資料へ降格させる。
2. **同梱物を「掃除できる量」に絞る**: ファイル数は掃除の負債になる(P5)。「置いたら必ず使う」と両立しないskillやテンプレートは同梱から外し、利用者の成功例から生やす前提にする(P2, P11)。
3. **チェックリストは審判として人間が所有する**: AIが編集しない場所に置き、所有者と見直し周期を明記する。数よりも所有の明確さを優先する(P14)。
4. **hookは守られなかった項目に限る**: AGENTS.mdとhookで同じルールを二重に持たない(P7)。
5. **汎用部分に残す仕組みは4つ**: 作成者≠点検者(P10)、成果物ファイルによる完了(P9)、案件ごとのフォルダ分離(P13)、棚卸し(P5, P15)。
6. **受け入れ試験はコールドスタート1本**: 新規セッションで代表業務を完走できるかを、V2の完成判定と定期点検に使う(P6)。
7. **モデル名を本文から排除する**: role指定と、1か所の対応表で管理する(P11)。
8. **導入の完了定義に「掃除が回っていること」を入れる**: テンプレート配布で終わらせない(P15)。


## 検証注記(出典へ遡れなかった・推論と明示すべき箇所)

検証役の判定: All 15 principles have at least one source extraction that supports them, and every number in the report's source-derived sections matches the extractions' concrete_numbers or quotes. Four things should be marked as inference or summary-only: P1's framing, P3's 60-line target, P7's agents-md-tips claims, and the repo-state figures in the V2 section.

- **P1**: The framing 'not a device to make AI stronger but one that defines the range you can safely delegate' appears in no extraction quote. The nearest support is about/ai-harness: quality is decided by the surrounding environment, and design where to return to a human. The slogan is the synthesizer's wording, presented as the article's claim.
  - 扱い: Rewrite as: 'AI quality is decided by the surrounding environment (about, ai-harness)'. Mark the 'defines the safe range' framing as the synthesizer's paraphrase.
- **P3**: The main source, agents-md-tips, has no verbatim quote ('原文の逐語は取得できず'). The 約60行 target and the 'hub' claim rest on a summary only. The explanation's 'amplified as input that conditions later output' comes from ai-markov-chain and ai-harness, not from claude-md-views. claude-md-views has no line count.
  - 扱い: Keep the 'via summary, unverified' label on 60 lines. Add ai-markov-chain as a source for the amplification claim. Do not present the 60-line figure as the author's own number.
- **P7**: Several agents-md-tips quotes are '逐語は取得できず'. 'Self-discipline rarely works' and 'put only unobeyed rules in AGENTS.md' rest on a summary only. ai-bpo and ai-harness support the code/AI/human split and the validator/hook point.
  - 扱い: Lead with ai-bpo and ai-harness as the source. Mark agents-md-tips as summary-based.
- **markdown_report/FDE Atlas V2**: The figures 約47ファイル, AGENTS.md 155行, skill 10, チェックリスト6, テンプレート12, hook 3 do not appear in any extraction's concrete_numbers or quotes. They come from the current repo state, not from the sources. The report labels the section as inference, so this is not a fabrication, but they are not verifiable against the extractions.
  - 扱い: Annotate the figures as 'measured in this repo (not from the articles)' and cite the file or command that produced them.
- **markdown_report/約60行**: 約60行 is repeated as a firm target in the conclusions, in P3 and in the V2 section. The extraction says only '要約による', with no verbatim quote and 'no token or file-count figures confirmed'. The report does flag this in the conclusions and the open questions.
  - 扱い: Keep the 'summary-derived' note wherever the number appears, including the V2 section item 1.
- **P11**: The 'always use skills you place' operating rule comes from claude-md-views. The 'one-skill-one-role' and 'no model names' parts come from multi-ai. The implication 'limit bundled skills to a number compatible with always using them' is an inference, not in any source.
  - 扱い: Mark the implication as the synthesizer's inference.
- **P14**: 'Reviewer's criteria are held by a human and redrawn periodically' is supported by ai-markov-chain. 'Human-owned files the AI does not edit' and 'owner and review cycle' for checklists are the synthesizer's extension. They are not in the sources.
  - 扱い: Label the implication as inference. The citation to ai-disillusionment (regression check) is valid for the regression-check clause only.

## 読んだ記事

| 記事 | URL | 抽出した原則数 |
|---|---|---|
| AI-BPO / FDE | https://rmanzoku.net/articles/ai-bpo/ | 8 |
| AI Agent Operations | https://rmanzoku.net/articles/ai-agents/ | 10 |
| CLAUDE.md、下から見るか？横から見るか？ | https://rmanzoku.net/articles/claude-md-views/ | 11 |
| AI Harness | https://rmanzoku.net/articles/ai-harness/ | 14 |
| AGENTS.md/CLAUDE.md、全文公開 | https://rmanzoku.net/articles/agents-md-tips/ | 14 |
| Subagentはいつ使うべきか マルチAIレビュー比較のメモ | https://rmanzoku.net/articles/subagent-review-orchestration/ | 7 |
| 単一AIではなく実行基盤で考える AI開発環境とUNIX哲学 | https://rmanzoku.net/articles/multi-ai-unix-philosophy/ | 13 |
| AIと「回答空間」の旅 | https://rmanzoku.net/articles/ai-answer-space-skills/ | 13 |
| 開発は一番高いコストではなかった | https://rmanzoku.net/articles/selection-valve/ | 8 |
| ループエンジニアリングとコンウェイの法則 | https://rmanzoku.net/articles/loop-engineering-conway/ | 9 |
| 筆を置くハッカー | https://rmanzoku.net/articles/painter-without-brush/ | 9 |
| 生成AIとマルコフ連鎖 | https://rmanzoku.net/articles/ai-markov-chain/ | 14 |
| ループ間のサイロ化 | https://rmanzoku.net/articles/loop-silos/ | 7 |
| AIと幻滅期、その正体 | https://rmanzoku.net/articles/ai-disillusionment/ | 13 |
| Work | https://rmanzoku.net/work/ | 4 |
| About（満足亮 / Ryo Manzoku） | https://rmanzoku.net/about/ | 7 |
| MBP M5 Maxを買ったのでAI開発環境を棚卸しした | https://rmanzoku.net/articles/ai-dev-environment-mbp/ | 13 |
| 未来のコンテキスト | https://rmanzoku.net/articles/future-context/ | 10 |
| fractional CTOという生き方 | https://rmanzoku.net/articles/fractional-cto/ | 10 |

## dotfiles で直接確認した実物(2026-10-02 時点)

- 入口ファイルの行数上限を validator で固定: AGENTS.md 60行、docs 索引 100行(記事「AGENTS.md/CLAUDE.md、全文公開」の7つのコツ: ハブにして全集にしない / 現在形だけを書く / 書かないことを決める / 例外には範囲と解除条件 / 失効したルールを消す / 書くだけでは守られない→機械検査へ / コールドスタートで試す)。
- ADR 0046「グローバル指示は薄く保つ」: グローバルは「repo ローカルの docs/Skill があればそれを優先せよ」とだけ書き、詳細は repo 側へ。
- runner-skill-governance: 新しい Skill/runner は便利化では足さない。順序は docs/AGENTS → 薄い wrapper guard → 既存 runner の option → 新 runner → 新 Skill。AGENTS=行動規則、docs=理由、Skill=実行手順、wrapper=前提条件の強制。
- common-rules.md: 可逆性の3条件(巻き戻しが自分だけで完結/影響が管理境界の内側/巻き戻しコストが時間で増えない)。委譲は並列化・隔離・専門性・独立性があるときだけ。委譲先に secret を渡さない。複数AIの比較は作成者を伏せて中立ラベルで。
