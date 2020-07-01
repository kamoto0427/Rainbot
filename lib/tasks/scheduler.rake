namespace :scheduler do
  require 'line/bot'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

  client ||= Line::Bot::Client.new { |config|
  config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
  config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
}

  url  = "https://www.drk7.jp/weather/xml/13.xml"

  xml  = open( url ).read.toutf8
  doc = REXML::Document.new(xml)

  xpath = 'weatherforecast/pref/area[4]/info/rainfallchance/'

  per06to12 = doc.elements[xpath + 'period[2]'].text
  per12to18 = doc.elements[xpath + 'period[3]'].text
  per18to24 = doc.elements[xpath + 'period[4]'].text

  min_per = 20
  if per06to12._to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
    word1 =
      ["今日やることは決まってる？",
       "よく眠れた？"].sample
    word2 =
      ["「きっかけ」をつくれてる？",
       "雨に負けずに今日のベストを尽くしてね"].samaple

    mid_per = 50
    if per06to12.to_i >= mid_per || per12to18.to_i >= mid_per || per18to24.to_i >= mid_per
      word3 = "今日は雨が降りそうだから忘れずに傘を持っていってね！"
    else
      word3 = "今日は雨が降るかもしれないから足元に気をつけてね！"
    end

    push =
      "#{word1}\n#{word3}\n降水確率チェックしてね\n6〜12時 #{per06to12}%\n 12〜18時 #{per12to18}%\n 18〜24時 #{per18to24}\n#{word2}%"
    
    user_ids = User_all.pluck(:line_id)
    message = {
      type: 'text',
      text: push
    }
    response = client.multicast(user_ids, message)
  end
  "OK"
end
