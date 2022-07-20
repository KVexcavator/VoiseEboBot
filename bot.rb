require 'telegram/bot'
require_relative 'env'

botik = Telegram::Bot::Client
max_voice_duration_sec = 30
max_voice_file_size_bt = 1000000

botik.run(TG_TOKEN) do |bot|
  bot.listen do |message|
    if message.text
      text = "Дай мне голосовое сообдение"
      bot.api.send_message(chat_id: message.chat.id, text: text)
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
      bot.api.send_message(chat_id: message.chat.id, text: text)

      if service_open
        bot.api.send_message(chat_id: message.chat.id, text: "Сезам откройся!")
      end
    else
      text = "Непонятно ничего"
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end
end
