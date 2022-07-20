task :default => :botrun
task :botrun => %W[bot.rb]

%W[bot.rb].each do |bot|
  system("echo 'Telegram bot run now, press Ctl+C to exit'  && ruby #{bot}")
end
