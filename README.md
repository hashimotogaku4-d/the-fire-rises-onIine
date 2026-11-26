# The Fire Rises — Supabaseオンライン版

静的サイトです。ビルド不要。Vercelに `index.html` と `vercel.json` を配置してください。

## Supabase初期設定
1. Supabase Dashboard → SQL Editor → New query
2. `supabase_setup.sql` の内容をすべて貼り付けて Run
3. Authentication → URL Configuration で Site URL をVercelの公開URLに設定
4. 必要なら Redirect URLs に同じVercel URL（`https://...vercel.app/**`）を追加
5. Authentication → Providers → Email を有効化

ブラウザ側はProject URLとPublishable keyを使用します。Secret key / service_role keyは絶対にブラウザへ置かないでください。

## 現在のオンライン版の仕様
- メールアドレス・パスワード登録／ログイン
- 6桁ルームコードで2人が合流
- 既存のタクティクス（4対4・10ターン）をオンライン同期
- 盤面と手番をSupabase Realtime経由で同期

試作版のため、ページ再読み込み後の対戦復帰、ルーム退出・再戦、戦績保存、ゲーム中の不正操作対策はまだ実装していません。
