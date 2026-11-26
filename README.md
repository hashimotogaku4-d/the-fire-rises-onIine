# The Fire Rises

中世ファンタジーのターン制戦略ゲームです。対AI戦、同じ端末での2人対戦、タクティクス／ストラテジーモードを収録しています。

## 6桁ルームマッチ

別々の端末から対戦するには、Vercelで公開したページを開き、メニューの「6桁ルームマッチ」を選びます。

1. 両方の端末で同じSupabase Project URLとPublishable keyを入力します。
2. ホスト側がモードを選んで部屋を作成し、表示された6桁コードを相手に伝えます。
3. 相手側は同じ画面で6桁コードを入力して参加します。
4. ホストが「対戦準備を開始」を押すと、元のゲームの準備・戦闘フローに入ります。

このオンライン機能はSupabase Realtime Broadcastを使います。追加のテーブルやSQLは不要です。Supabase側でRealtimeが利用可能である必要があります。

**重要:** ブラウザに入力するのは `sb_publishable_...` のPublishable keyだけです。`service_role` やSecret keyは絶対に入力・公開しないでください。接続情報は各端末のブラウザ内に保存されます。

## Vercelへの更新

GitHubリポジトリの `index.html` を更新してCommit changesすると、Git連携済みのVercelプロジェクトが自動で再デプロイします。
