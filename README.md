# qat

![qat](https://raw.github.com/tomykaira/qiita_hackathon/master/qat.png)

Qiita + Jubatus(ネコ) + `cat` (Unix のコマンド)

毎日同じ言語を使い、Qiita でフォローするタグもふだんやっていること。qat = Qiita + ネコ + cat コマンドはシンプルなコマンドラインツールで、自分が知らなかった記事をリコメンドし、毎日のプログラミングに新しい風をふきこみます。

## 使い方

- jubatus をインストールする [odasatoshi/jubatus-installer](https://github.com/odasatoshi/jubatus-installer)
- `jutarecommener` を起動する
- `jubafeed.rb` を実行してユーザとストックの関係をダウンロードする
- 記事が読みたいときに `recommend_me.rb` を実行する

## 試したい場合

- 付属のデータセットを `train.rb` を実行して
- `recommend_me.rb` を実行する
