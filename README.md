# Mastodon Markov bot for AWS Lambda (mmb-lambda)

## これはなに？

AWS Lambda上で動く、マストドン用のマルコフ連鎖Botプログラムです。

指定アカウントのこれまでのトゥートを蓄積し、MeCabによる日本語形態素解析を実施、それらをもとに文章を自動生成、定期的にトゥートを投稿します。

サーバーレス環境で動作するため、より気軽にBotを稼働させることが可能です。

## 必要となる環境
 - Docker
   - 19.03.8で動作を確認済

## インストール

### ローカルにリポジトリをcloneする

```
$ git clone https://github.com/aquarla/mmb-lambda
```

### 環境変数の設定

ディレクトリ直下の ```.env.example``` ファイルを ```.env``` としてコピーし、必要な環境変数を追加する。

```
$ cd ./mmb-lambda
$ cp .env.example .env
$ vim .env
```

#### ローカル環境で指定する変数一覧
キー|値|必須|備考
----|----|----|----
DOMAIN|対象となるマストドンサーバのドメイン名|〇|例) iwatedon.net
READ_ACCESS_TOKEN|トゥートを取得するアカウントのアクセストークン|〇|マストドン管理画面の「開発」→「新規アプリ」からトークンを生成する
WRITE_ACCESS_TOKEN|トゥートを投稿するアカウントのアクセストークン|〇|マストドン管理画面の「開発」→「新規アプリ」からトークンを生成する
AWS_ACCESS_KEY|Amazon S3アクセス用のアクセストークン|〇|本番環境では代わりにIAMロールにS3アクセス権限を付与する
AWS_SECRET_ACCESS_KEY|Amazon S3アクセス用のシークレット|〇|本番環境では代わりにIAMロールにS3アクセス権限を付与する
AWS_S3_BUCKET_NAME|データ保存に使用するAmazon S3のバケット名|〇|
INTERVAL|トゥート取得間隔＆投稿間隔||デフォルトは10分


###  MeCab、および必要となる各種Gemのインストール

```
$ docker build -t mylambda .
$ docker run -v `pwd`:/var/task -it mylambda
```

ディレクトリ直下にデプロイ用パッケージ ``` function.zip ``` が生成されていることを確認します。

### ローカル環境で試しに動かしてみる

```
$ docker run -v `pwd`:/var/task --env-file .env -it lambci/lambda:ruby2.7 function.handler
```

### 本番環境へデプロイ

上で生成された ``` function.zip ``` をデプロイパッケージとして、新規AWS Lambda関数を作成およびパッケージのデプロイを行います。

必要な設定一覧

項目|値
----|----
ランタイム| ```Ruby 2.7```
ハンドラ| ```function.handler```
タイムアウト| 30秒以上を指定(デフォルトだとおそらくタイムアウトする)

### 環境変数を設定
上の ```.env``` ファイルで指定したものと同じキー/値を、AWS管理コンソールの「環境変数」欄に指定します。

#### 本番環境で指定する環境変数一覧
キー|値|必須|備考
----|----|----|----
DOMAIN|対象となるマストドンサーバのドメイン名|〇|例) iwatedon.net
READ_ACCESS_TOKEN|トゥートを取得するアカウントのアクセストークン|〇|マストドン管理画面の「開発」→「新規アプリ」からトークンを生成する
WRITE_ACCESS_TOKEN|トゥートを投稿するアカウントのアクセストークン|〇|マストドン管理画面の「開発」→「新規アプリ」からトークンを生成する
AWS_S3_BUCKET_NAME|データ保存に使用するAmazon S3のバケット名|〇|
INTERVAL|トゥート取得間隔＆投稿間隔||デフォルトは10分

### Lamdba実行用のIAMロールに、S3バケットへのアクセス権限を付与

Lambda実行用のIAMロールの設定画面を開き、当該Amazon S3バケットへのアクセス権限を付与します。

### テスト実行

Lambda設定画面の「テスト」機能を使って、実際にトゥートされるか確認を行います。

### トリガーを作成

AWS管理コンソール上で「トリガーを追加」からトリガーを追加します。

項目|値|備考
----|----|----
トリガーの種類|EventBridge(CloudWatch Events)|
トリガー名|任意の名前を入力|
トリガー式|```rate(10 minutes)```|上で設定したINTERVAL環境変数に値を合わせる

以上