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
          when /.*(北海道|青森|岩手|宮城|秋田|山形|福島|茨城|栃木|群馬|埼玉|千葉|東京|神奈川|新潟|富山|石川|福井|山梨|長野|岐阜|静岡|愛知|三重|滋賀|京都|大阪|兵庫|奈良|和歌山|鳥取|島根|岡山|広島|山口|徳島|香川|愛媛|高知|福岡|佐賀|長崎|熊本|大分|宮崎|鹿児島|沖縄).*/
            when /.*(明日).*/
              prefecture = [{name:"明日の北海道の天気", num:"01",point:16}, {name:"明日の青森の天気", num:"02",point:3}, {name:"明日の岩手の天気", num:"03",point:3}, {name:"明日の宮城の天気", num:"04",point:2}, {name:"明日の秋田の天気", num:"05",point:2}, {name:"明日の山形の天気", num:"06",point:4},
                            {name:"明日の福島の天気", num:"07",point:3}, {name:"明日の茨城の天気", num:"08",point:2}, {name:"明日の栃木の天気", num:"09",point:2}, {name:"明日の群馬の天気", num:"10",point:2}, {name:"明日の埼玉の天気", num:"11",point:3}, {name:"明日の千葉の天気", num:"12",point:3},
                            {name:"明日の東京の天気", num:"13",point:3}, {name:"明日の神奈川の天気", num:"14",point:2}, {name:"明日の新潟の天気", num:"15",point:4}, {name:"明日の富山の天気", num:"16",point:2}, {name:"明日の石川の天気", num:"17",point:2}, {name:"明日の福井の天気", num:"18",point:2},
                            {name:"明日の山梨の天気", num:"19",point:2}, {name:"明日の長野の天気", num:"20",point:3}, {name:"明日の岐阜の天気", num:"21",point:2}, {name:"明日の静岡の天気", num:"22",point:4}, {name:"明日の愛知の天気", num:"23",point:2}, {name:"明日の三重の天気", num:"24",point:2},
                            {name:"明日の滋賀の天気", num:"25",point:2}, {name:"明日の京都の天気", num:"26",point:2}, {name:"明日の大阪の天気", num:"27",point:1}, {name:"明日の兵庫の天気", num:"28",point:2}, {name:"明日の奈良の天気", num:"29",point:2}, {name:"明日の和歌山の天気", num:"30",point:2},
                            {name:"明日の鳥取の天気", num:"31",point:2}, {name:"明日の島根の天気", num:"32",point:3}, {name:"明日の岡山の天気", num:"33",point:2}, {name:"明日の広島の天気", num:"34",point:2}, {name:"明日の山口の天気", num:"35",point:4}, {name:"明日の徳島の天気", num:"36",point:2},
                            {name:"明日の香川の天気", num:"37",point:1}, {name:"明日の愛媛の天気", num:"38",point:3}, {name:"明日の高知の天気", num:"39",point:3}, {name:"明日の福岡の天気", num:"40",point:4}, {name:"明日の佐賀の天気", num:"41",point:2}, {name:"明日の長崎の天気", num:"42",point:4},
                            {name:"明日の熊本の天気", num:"43",point:4}, {name:"明日の大分の天気", num:"44",point:4}, {name:"明日の宮崎の天気", num:"45",point:4}, {name:"明日の鹿児島の天気", num:"46",point:4}, {name:"明日の沖縄の天気", num:"47",point:7}]
                input_prefecture = event.message['text']
                number = prefecture.find{|x| x[:name].include?(input_prefecture)}[:num]
                name = prefecture.find{|x| x[:name].include?(input_prefecture)}[:name]
                point = prefecture.find{|x| x[:name].include?(input_prefecture)}[:point]
                url  = "https://www.drk7.jp/weather/xml/"+number+".xml"
                xml  = open( url ).read.toutf8
                doc = REXML::Document.new(xml)
                i = 1
                locals = []
                local_weather = ""
                while i <= point do
                  xpath = "weatherforecast/pref/area[#{i}]"
                  area = doc.elements[xpath].attributes['id']
                  maxtemp = doc.elements[xpath + '/info[2]/temperature/range'].text
                  mintemp = doc.elements[xpath + '/info[2]/temperature/range[2]l'].text
                  per6to12 = doc.elements[xpath + '/info[2]/rainfallchance/period[2]l'].text
                  per12to18 = doc.elements[xpath + '/info[2]/rainfallchance/period[3]l'].text
                  per18to24 = doc.elements[xpath + '/info[2]/rainfallchance/period[4]l'].text
                  locals << [area,per6to12,per12to18,per18to24,maxtemp,mintemp]
                  i += 1
                end
                locals.each do |local|
                  local_weather << "\n#{local[0]}の降水確率はこんな感じ！\n 6時 ~ 12時 ~ 18時\n #{local[1]}％ ~ #{local[2]}％ ~ #{local[3]}％\n気温は #{local[4]}~#{local[5]} °C\n"
                end
                push = "#{name}はね〜#{local_weather}くらいだよ(^^)"
            else
              prefecture = [{name:"今日の北海道の天気", num:"01",point:16}, {name:"今日の青森の天気", num:"02",point:3}, {name:"今日の岩手の天気", num:"03",point:3}, {name:"今日の宮城の天気", num:"04",point:2}, {name:"今日の秋田の天気", num:"05",point:2}, {name:"今日の山形の天気", num:"06",point:4},
                            {name:"今日の福島の天気", num:"07",point:3}, {name:"今日の茨城の天気", num:"08",point:2}, {name:"今日の栃木の天気", num:"09",point:2}, {name:"今日の群馬の天気", num:"10",point:2}, {name:"今日の埼玉の天気", num:"11",point:3}, {name:"今日の千葉の天気", num:"12",point:3},
                            {name:"今日の東京の天気", num:"13",point:3}, {name:"今日の神奈川の天気", num:"14",point:2}, {name:"今日の新潟の天気", num:"15",point:4}, {name:"今日の富山の天気", num:"16",point:2}, {name:"今日の石川の天気", num:"17",point:2}, {name:"今日の福井の天気", num:"18",point:2},
                            {name:"今日の山梨の天気", num:"19",point:2}, {name:"今日の長野の天気", num:"20",point:3}, {name:"今日の岐阜の天気", num:"21",point:2}, {name:"今日の静岡の天気", num:"22",point:4}, {name:"今日の愛知の天気", num:"23",point:2}, {name:"今日の三重の天気", num:"24",point:2},
                            {name:"今日の滋賀の天気", num:"25",point:2}, {name:"今日の京都の天気", num:"26",point:2}, {name:"今日の大阪の天気", num:"27",point:1}, {name:"今日の兵庫の天気", num:"28",point:2}, {name:"今日の奈良の天気", num:"29",point:2}, {name:"今日の和歌山の天気", num:"30",point:2},
                            {name:"今日の鳥取の天気", num:"31",point:2}, {name:"今日の島根の天気", num:"32",point:3}, {name:"今日の岡山の天気", num:"33",point:2}, {name:"今日の広島の天気", num:"34",point:2}, {name:"今日の山口の天気", num:"35",point:4}, {name:"今日の徳島の天気", num:"36",point:2},
                            {name:"今日の香川の天気", num:"37",point:1}, {name:"今日の愛媛の天気", num:"38",point:3}, {name:"今日の高知の天気", num:"39",point:3}, {name:"今日の福岡の天気", num:"40",point:4}, {name:"今日の佐賀の天気", num:"41",point:2}, {name:"今日の長崎の天気", num:"42",point:4},
                            {name:"今日の熊本の天気", num:"43",point:4}, {name:"今日の大分の天気", num:"44",point:4}, {name:"今日の宮崎の天気", num:"45",point:4}, {name:"今日の鹿児島の天気", num:"46",point:4}, {name:"今日の沖縄の天気", num:"47",point:7}]
              input_prefecture = event.message['text']
              number = prefecture.find{|x| x[:name].include?(input_prefecture)}[:num]
              name = prefecture.find{|x| x[:name].include?(input_prefecture)}[:name]
              point = prefecture.find{|x| x[:name].include?(input_prefecture)}[:point]
              url  = "https://www.drk7.jp/weather/xml/"+number+".xml"
              xml  = open( url ).read.toutf8
              doc = REXML::Document.new(xml)
              i = 1
              locals = []
              local_weather = ""
              while i <= point do
                xpath = "weatherforecast/pref/area[#{i}]"
                area = doc.elements[xpath].attributes['id']
                maxtemp = doc.elements[xpath + '/info/temperature/range'].text
                mintemp = doc.elements[xpath + '/info/temperature/range[2]l'].text
                per6to12 = doc.elements[xpath + '/info/rainfallchance/period[2]l'].text
                per12to18 = doc.elements[xpath + '/info/rainfallchance/period[3]l'].text
                per18to24 = doc.elements[xpath + '/info/rainfallchance/period[4]l'].text
                locals << [area,per6to12,per12to18,per18to24,maxtemp,mintemp]
                i += 1
              end
              locals.each do |local|
                local_weather << "\n#{local[0]}の降水確率はこんな感じ！\n 6時 ~ 12時 ~ 18時\n #{local[1]}％ ~ #{local[2]}％ ~ #{local[3]}％\n気温は #{local[4]}~#{local[5]} °C\n"
              end
              push = "#{name}はね〜#{local_weather}くらいだよ(^^)"
            end

          when /.*(今日|きょう).*/
            maxtemp = doc.elements[xpath + 'info/temperature/range'].text
            mintemp = doc.elements[xpath + 'info/temperature/range[2]l'].text
            per6to12 = doc.elements[xpath + 'info/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]l'].text
            if per6to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              word = ["雨だけど元気出していこうね！","雨に負けずファイト！！","雨だけどあなたの明るさでみんなを元気にしてあげて(^^)"].sample
              push = "今日の天気？\n今日は雨が降りそうだから傘があった方が安心だよ\n    6〜12時  #{per6to12}％\n  12〜18時  #{per12to18}％\n  18〜24時  #{per18to24}％\n気温は #{maxtemp}~#{mintemp} °Cだよ\n#{word}"
            else
              word = ["天気もいいから一駅歩いてみるのはどう？(^^)","今日会う人のいいところを見つけて是非その人に教えてあげて(^^)","素晴らしい一日になりますように(^^)","雨が降っちゃったらごめんね(><)"].sample
              push = "東京の今日の天気？\n今日は雨は降らなさそうだよ\n気温は #{maxtemp}~#{mintemp} °Cだよ\n#{word}"
            end
          when /.*(明日|あした).*/
            per6to12 = doc.elements[xpath + 'info[2]/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info[2]/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info[2]/rainfallchance/period[4]'].text
            if per6to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push = "東京の明日の天気？\n明日は雨が降りそうだよ(>_<)\n今のところ降水確率はこんな感じだよ\n    6〜12時  #{per6to12}％\n  12〜18時  #{per12to18}％\n  18〜24時  #{per18to24}％\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            else
              push = "東京の明日の天気？\n明日は雨が降らない予定だよ(^^)\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            end
          when /.*(明後日|あさって).*/
            per6to12 = doc.elements[xpath + 'info[3]/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info[3]/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info[3]/rainfallchance/period[4]l'].text
            if per6to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push = "東京の明後日の天気？\n明後日は雨が降りそう…\n当日の朝に雨が降りそうだったら教えるね！"
            else
              push = "東京の明後日の天気？\n明後日は雨は降らない予定だよ(^^)\nまた当日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            end

          # 使い方
          when /.*(使い方|使いかた|つかい方|つかいかた).*/
            push = "「今日の天気」って聞いてくれたら東京の降水確率と気温を教えられるよ(^^)\n明日と明後日もだいたいだったらわかるよ。明日は？って感じで聞いてみてね。\nでも変わっちゃうからその日になったらまた聞いてほしいな。\n\n全国の天気も明日までなら教えられるよ!\n「今日の大阪の天気」って感じで聞いてね。"


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

          # =======================
          else #何にも引っ掛からなかった場合
            push = "使い方がわからないのかな？\n「使いかた」って聞いてみて(^^)"
          end
        else
          push = "(  ๑  ╹  ◡  ╹  ๑  )"
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
