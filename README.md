# line_weather
![line_weather-top](https://user-images.githubusercontent.com/50007961/60940321-147f3600-a316-11e9-8285-3a40a884ef42.png)

We will tell you if you need an umbrella at JST 6:00  
朝6時に傘の必要な日の場合はお知らせします。

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
It is assumed that you have a LINE account.  
Please see here for registration.
https://appllio.com/line-account-registration
- Push message　function
  - Search for `@ 618ypybr` from LINE friend search.
  - If the probability of precipitation exceeds 20%, we will notify you by push message.
- Reply message　function
  - After registration, you can send `今日の天気` on the chat screen and the Tokyo weather will be replied that day.
  - If you send `明日の天気`,`明後日の天気`, it will return Tokyo's rainfall probability for that day.
  - In the same way, you can see `使い方を教えて` Teach me how to use.
- Uninstallation request  
There are conditions for the number of people that can be registered, so once specification confirmation etc. have been completed, please cooperate in the registration cancellation.  
The method only blocks you.  
Depending on the situation, please be aware that you may unsubscribe from me.  

---
---

LINEアカウントをお持ちであることが前提となります。  
登録する方は、こちらを参照ください。
[LINEの登録方法と注意点まとめ](https://appllio.com/line-account-registration)

- 自動送信メッセージ
  - LINEの友だち追加の検索より`@618ypybr`を検索し登録。
  - 降水確率が20%以上の日は、自動送信でおしらせします。

- 返信メッセージ
  - 登録後、チャット画面で`今日の天気`と送信いただくとその日の東京の天気を返信します。
  - `明日の天気`,`明後日の天気`と送信いただくと、その日の東京の降水確率を返信します。
  - 同様に`使い方を教えて`と送信いただくと、その他の使用方法を見ることが出来ます。

- アンインストールのお願い  
登録できる人数に条件があるため、仕様確認等が済みましたら登録解除のご協力をお願いします。  
方法はブロックしていただくだけです。  
状況によってはこちらから解除する場合もございますのでご了承ください。

## Anythink Else
#### 作った理由
理由はこの4点です。
- Rakeタスクの学習のため。  
- APIの学習のため。  
- LINEはスマートフォンを通して常に隣にあるものなので、実用的だと考えた。  
- 傘を忘れることがしばしばあり、受動的に知らせてもらえば解決すると考えた。  
#### さらにやりたいこと
- リッチメニューの導入  
![リッチメニュー](https://user-images.githubusercontent.com/50007961/61012702-8741ed00-a3ba-11e9-83be-3550ca2531cf.png)  
有料プランに加入する必要があったので断念しました。
#### 工夫点
降水量が20%以下の場合「降りません。」と一言表示にして、メッセージの簡略にしました。  
『明後日の天気』は非確定なため目安程度のメッセージとして、同じく簡略にしました。
#### 苦労した点
都道府県別の天気を返信メッセージで追加実装したのですが、『今日』『北海道』をキーワードにしたところ、『今日の天気』とかぶってしまい、意図しない返信が来ました。その改善のための、キーワード選びに苦労しました。




###### Deployment instructions memo

  $ git push heroku master  
  $ heroku run rake db:migrate


