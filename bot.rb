require 'telegram/bot'
require 'dotenv/load'
require 'json'
require 'net/http'

tg_token = ENV['TG_TOKEN']
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
        text = "Да это волшебный голос.
                Длительность #{msg_duration_sec} секунд.
                Размер файла #{msg_file_size_bt} байт.
                Расшифровка будет сей момент ..."
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
        chatter.call(bot, message, "Сходим на яндекс чтоли")

        # extruct text
        chatter.call(bot, message, "Здесь мы извлечем текст и выведем")

        # cleaner tmp files
        chatter.call(bot, message, "Приберемся за собой")
      end
    else
      chatter.call(bot, message)
    end
  end
end
