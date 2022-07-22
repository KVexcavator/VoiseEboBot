require 'telegram/bot'
require 'dotenv/load'
require 'json'
require 'uri'
require 'net/http'

module SetBot
  def self.tg_token
    ENV['TG_TOKEN']
  end

  def self.iam_token
    ENV['IAM_TOKEN']
  end

  def self.folder_id
    ENV['FOLDER_ID']
  end

  def self.duration_and_size_ok?(duration, size)
    max_voice_duration_sec = 30
    max_voice_file_size_bt = 1000000
    duration <= max_voice_duration_sec && size <= max_voice_file_size_bt
  end

end
