$bot.help['*reload'] = '*reload - Reload all plugins.'

privmsg? /^\*reload$/ do |matches, source, channel, line|
  username, ident, hostname = source.to_user

  privmsg! [channel.is_channel? ? channel : username], "[\x02Reload\x02] Reloading all plugins..."
  
  loader = $bot.load_plugins

  loader.errback do |plugins, results|
    $bot.handle :LOAD

    privmsg! [channel.is_channel? ? channel : username], "[\x02Reload\x02] Reloaded #{results.count true} plugins, while #{results.count false} failed."
  end

  loader.callback do |plugins, results|
    $bot.handle :LOAD

    privmsg! [channel.is_channel? ? channel : username], "[\x02Reload\x02] Reloaded all plugins!"
  end
end