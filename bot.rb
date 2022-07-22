require_relative 'config/require'

chatter = ->(b,m,t="Непонятно ничего"){b.api.send_message(chat_id: m.chat.id, text: t)}

Telegram::Bot::Client.run(SetBot::tg_token) do |bot|
  bot.listen do |message|
    if message.text
      text = "Дай мне голосовое сообдение"
      chatter.call(bot, message, text)
    elsif message.voice
      service_open = false
      text = "Это слишком большое голосовое сообщение"

      if SetBot::duration_and_size_ok?(message.voice.duration, message.voice.file_size)
        service_open = true
        text = "Расшифровка будет сей момент ..."
      end
      chatter.call(bot, message, text)

      if service_open
        # path receiver
        uri = URI("https://api.telegram.org/bot"+SetBot::tg_token+"/getFile?file_id=" + message.voice.file_id)
        response = Net::HTTP.get(uri)
        path = JSON.parse(response)["result"]["file_path"]

        # file receiver
        uri = URI("https://api.telegram.org/file/bot"+SetBot::tg_token+"/" + path)
        system("curl #{uri} --output #{path} --silent")

        # catch text
        url = URI.parse("https://stt.api.cloud.yandex.net/speech/v1/stt:recognize?folderId=#{SetBot::folder_id}&lang=ru-RU")
        header = {"Authorization": "Bearer #{SetBot::iam_token}"}
        req = Net::HTTP::Post.new(url.request_uri, header)
        req.body = File.read(path)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == "https")
        response = http.request(req)

        # extruct text
        if result = JSON.parse(response.body)["result"]
          chatter.call(bot, message, result)
          # cleaner tmp files
          system("rm -f voice/*")
        else
          chatter.call(bot, message, "Разраб спит, заходите позже")
        end
      end
    else
      chatter.call(bot, message)
    end
  end
end
