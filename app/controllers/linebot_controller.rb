class LinebotController < ApplicationController
  require 'line/bot'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)
    events.each { |event|
      case event

      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          input = event.message['text']
          url  = "https://www.drk7.jp/weather/xml/13.xml"
          xml  = open( url ).read.toutf8
          doc = REXML::Document.new(xml)
          xpath = 'weatherforecast/pref/area[4]/'

          min_per = 30
          case input
          when /.*(今日|きょう).*/
            maxtemp = doc.elements[xpath + 'info/temperature/range'].text
            mintemp = doc.elements[xpath + 'info/temperature/range[2]l'].text
            per6to12 = doc.elements[xpath + 'info/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]l'].text
            if per6to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              word = ["雨だけど元気出していこうね！","雨に負けずファイト！！","雨だけどあなたの明るさでみんなを元気にしてあげて(^^)"].sample
              push = "今日の天気？\n今日は雨が降りそうだから傘があった方が安心だよ\n　  6〜12時　#{per6to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\n気温は #{maxtemp}~#{mintemp} °Cだよ\n#{word}"
            else
              word = ["天気もいいから一駅歩いてみるのはどう？(^^)","今日会う人のいいところを見つけて是非その人に教えてあげて(^^)","素晴らしい一日になりますように(^^)","雨が降っちゃったらごめんね(><)"].sample
              push = "今日の天気？\n今日は雨は降らなさそうだよ\n気温は #{maxtemp}~#{mintemp} °Cだよ\n#{word}"
            end
          when /.*(明日|あした).*/
            per6to12 = doc.elements[xpath + 'info[2]/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info[2]/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info[2]/rainfallchance/period[4]'].text
            if per6to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push = "明日の天気？\n明日は雨が降りそうだよ(>_<)\n今のところ降水確率はこんな感じだよ\n　  6〜12時　#{per6to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            else
              push = "明日の天気？\n明日は雨が降らない予定だよ(^^)\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            end
          when /.*(明後日|あさって).*/
            per6to12 = doc.elements[xpath + 'info[3]/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info[3]/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info[3]/rainfallchance/period[4]l'].text
            if per6to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push = "明後日の天気？\n明後日は雨が降りそう…\n当日の朝に雨が降りそうだったら教えるね！"
            else
              push = "明後日の天気？\n明後日は雨は降らない予定だよ(^^)\nまた当日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            end

          # 使い方
          when /.*(使い方|使いかた|つかい方|つかいかた).*/
            push = "「(今日, 明日, 明後日)の天気」って聞いてくれたらその日の天気を教えるよ(^^)"


          # おまけ
          when /.*(かわいい|きれい|すてき|ありがと|すごい|好き|頑張|がんば).*/
            push = "ありがとう！！！\n優しい言葉をかけてくれるあなたも素敵です(^^)"
          when /.*(こんにちは|こんばんは|初めまして|はじめまして|おはよう).*/
            push = "こんにちは\n今日があなたにとっていい日になりますように(^^)"
          
            # ======test field======
          when /.*(test1).*/
            temptoday = doc.elements[xpath + 'info[2]/temperature/range'].text
            tempyesterday = doc.elements[xpath + 'info/temperature/range'].text
            tempdifference = temptoday.to_i - tempyesterday.to_i

            test1 = "今日は昨日の気温と同じくらいだよ〜"
            if tempdifference <= -3
              test1 = "今日は昨日より少し寒いよ"
            elsif tempdifference >= 3
              test1 = "今日は昨日より少し暑いよ"
            end
            push = "#{test1}\n#{tempdifference}"

          when /.*(北海道|青森|岩手|宮城|秋田|山形|福島|茨城|栃木|群馬|埼玉|千葉|東京|神奈川|新潟|富山|石川|福井|山梨|長野|岐阜|静岡|愛知|三重|滋賀|京都|大阪|兵庫|奈良|和歌山|鳥取|島根|岡山|広島|山口|徳島|香川|愛媛|高知|福岡|佐賀|長崎|熊本|大分|宮崎|鹿児島|沖縄).*/
            prefecture = [{name:"北海道",num:01},{name:"青森",num:02},{name:"岩手",num:03},{name:"宮城",num:04},{name:"秋田",num:05},{name:"山形",num:06},{name:"福島",num:07},
                          {name:"茨城",num:08},{name:"栃木",num:09},{name:"群馬",num:10},{name:"埼玉",num:11},{name:"千葉",num:12},{name:"東京",num:13},{name:"神奈川",num:14},
                          {name:"新潟",num:15},{name:"富山",num:16},{name:"石川",num:17},{name:"福井",num:18},{name:"山梨",num:19},{name:"長野",num:20},{name:"岐阜",num:21},
                          {name:"静岡",num:22},{name:"愛知",num:23},{name:"三重",num:24},{name:"滋賀",num:25},{name:"京都",num:26},{name:"大阪",num:27},{name:"兵庫",num:28},
                          {name:"奈良",num:29},{name:"和歌山",num:30},{name:"鳥取",num:31},{name:"島根",num:32},{name:"岡山",num:33},{name:"広島",num:34},{name:"山口",num:35},
                          {name:"徳島",num:36},{name:"香川",num:37},{name:"愛媛",num:38},{name:"高知",num:39},{name:"福岡",num:40},{name:"佐賀",num:41},{name:"長崎",num:42},
                          {name:"熊本",num:43},{name:"大分",num:44},{name:"宮崎",num:45},{name:"鹿児島",num:46},{name:"沖縄",num:47}]
            input_prefecture = event.message['text']
            push = input_prefecture
          # =======================
          else #何にも引っ掛からなかった場合
            push = "使い方がわからないのかな？\n「使いかた」って聞いてみて(^^)"
          end
        else
          push = "(　๑　╹　◡　╹　๑　)"
        end
        message = {
          type: 'text',
          text: push
        }
        client.reply_message(event['replyToken'], message)

      when Line::Bot::Event::Follow
        line_id = event['source']['userId']
        User.create(line_id: line_id)

      when Line::Bot::Event::Unfollow
        line_id = event['source']['userId']
        User.find_by(line_id: line_id).destroy
      end
    }
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
