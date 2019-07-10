# line_weather

![line_weather-top](https://user-images.githubusercontent.com/50007961/60940321-147f3600-a316-11e9-8285-3a40a884ef42.png)

It will teach you the necessary day of umbrella at JST 6:00
朝6時に傘の必要な日を教えます。

## Description

It is an application that uses LINE's Messaging API.
It refer to the probability of precipitation in Tokyo, and tell you the day when an umbrella is likely to be needed.
It will tell you the weather by reply, according to the words for sending a message.

LINEのMessaging APIを利用したアプリです。
東京の降水確率を参照し、傘が必要になりそうな日は自動で教えてくれます。
メッセージを送るとワードに合わせて、返信で天気を教えてくれます。

## Requirements
- ruby 2.5.1
- rails 5.2.0

## Usege

LINEアカウントをお持ちであることが前提となります。
登録する方は、こちらを参照ください。
[LINEの登録方法と注意点まとめ](https://appllio.com/line-account-registration)

- 自動送信メッセージ
  - LINEの友だち追加の検索より`@618ypybr`を検索し登録。以上です。

- 返信メッセージ
  - 登録後、チャット画面で`今日の天気`と送信いただくとその日の東京の天気を返信します。
  - `明日の天気`,`明後日の天気`と送信いただくと、その日の東京の降水確率を返信します。
  - 同様に`使い方を教えて`と送信いただくと、その他の使用方法を見ることが出来ます。








* Deployment instructions

  $ git push heroku master  
  $ heroku run rake db:migrate


