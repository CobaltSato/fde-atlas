# Contributing

保守者向けの変更ルールです。Issue と PR を歓迎します。日本語で書き、コミットは Conventional Commits(`feat:` `fix:` `docs:` など)にします。

## PR の前に

1. `.atlas/tests/lint.sh` を実行し、全項目を PASS にする。
2. コア・packs・hooks を変えたら `.atlas/tests/hooks/run.sh` も実行して通す。

## コアに足すもの

- コアに足すのは、全員が毎回使うものだけ。
- 「〜の場合に備えて」「万一〜なら」で正当化される追加は受け付けない。packs/ かフォーク先に回す。
- 常時読み込む面(AGENTS.md・スキルの description・session-start の出力)を増やす PR は、同じ PR で消す行を挙げる。

## 安全設計の変更

- 承認線・可逆性・機密・hooks・settings.json を変えるときは、先に Issue で議論する。
- lint L19・L20 の必須語を外す変更は、理由を PR に書く。

## このリポジトリのルート

- ルートは製品の作業フォルダそのもの。保守作業のセッションにも AGENTS.md と hooks がかかる。
- AGENTS.md の1節は埋めない。`[要記入]` が出続けるのが正常。
- 保守用の資料は .atlas/ に置く。

## 改訂のしかた

- 現場の観測は、一般化して .atlas/design/feedback/ に置く。改訂はそこから始める。
- fde-guide.md は300行以内。足すなら同じ量を消す。
