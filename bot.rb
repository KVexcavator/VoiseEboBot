require 'telegram/bot'
require 'dotenv/load'
require 'json'
require 'uri'
require 'net/http'

tg_token = ENV['TG_TOKEN']
iam_token = ENV['IAM_TOKEN']
folder_id = ENV['FOLDER_ID']
botik = Telegram::Bot::Client
max_voice_duration_sec = 30
max_voice_file_size_bt = 1000000
chatter = ->(b,m,t="Непонятно ничего"){b.api.send_message(chat_id: m.chat.id, text: t)}

botik.run(tg_token) do |bot|
  bot.listen do |message|
    if message.text
      text = "Дай мне голосовое сообдение"
      chatter.call(bot, message, text)
    elsif message.voice
      msg_duration_sec = message.voice.duration
      msg_file_size_bt = message.voice.file_size
      service_open = false
      text = "Это слишком большое голосовое сообщение"

      if msg_duration_sec <= max_voice_duration_sec && msg_file_size_bt <= max_voice_file_size_bt
        service_open = true
        text = "Расшифровка будет сей момент ..."
      end
      chatter.call(bot, message, text)

      if service_open
        # path receiver
        uri = URI("https://api.telegram.org/bot"+tg_token+"/getFile?file_id=" + message.voice.file_id)
        response = Net::HTTP.get(uri)
        path = JSON.parse(response)["result"]["file_path"]

        # file receiver
        uri = URI("https://api.telegram.org/file/bot"+tg_token+"/" + path)
        system("curl #{uri} --output #{path} --silent")

        # catch text
        url = URI.parse("https://stt.api.cloud.yandex.net/speech/v1/stt:recognize?folderId=#{folder_id}&lang=ru-RU")
        header = {"Authorization": "Bearer #{iam_token}"}
        req = Net::HTTP::Post.new(url.request_uri, header)
        req.body = File.read(path)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == "https")
        response = http.request(req)

        # extruct text
        result = JSON.parse(response.body)["result"]
        chatter.call(bot, message, result)

        # cleaner tmp files
        system("rm -f voice/*")
      end
    else
      chatter.call(bot, message)
    end
  end
end
