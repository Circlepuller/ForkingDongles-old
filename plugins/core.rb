$bot.help['about'] = "ForkingDongles (v#{FORKINGDONGLES_VERSION}) is an asynchronous, pluggable, evented IRC bot framework written using EventMachine and Ruby by #{FORKINGDONGLES_AUTHOR}."

command? 376 do
  join! $bot.config.plugin.core.channels
end

# A primitive alternative nickname system
command? 433 do |source, _, nickname, message|
  nick! "#{$bot.config.plugin.core.nickname}#{'_' if nickname == $bot.config.plugin.core.nickname}"
end

connected? do
  nick! $bot.config.plugin.core.nickname
  user! $bot.config.plugin.core.username
end

disconnected? { quit! $bot.config.plugin.core.quit_message }

invite? { |source, nickname, channel| join! [channel] if channel.is_channel? }

ping? { |server| pong! server }