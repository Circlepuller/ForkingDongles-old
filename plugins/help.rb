$bot.help['*help'] = '*help [command] - Provides a list of commands and help documentation.'

privmsg? /^\*help$/ do |matches, sender, channel, line|
  username, ident, hostname = sender.to_user

  privmsg! [channel.is_channel? ? channel : username], "[\x02Help\x02] Commands: #{$bot.help.keys.sort.join ', '}"
end

privmsg? /^\*help (?<command>.+)$/ do |matches, sender, channel, line|
  username, ident, hostname = sender.to_user

  if not matches[:command].empty?
    if $bot.help.include? matches[:command]
      privmsg! [channel.is_channel? ? channel : username], "[\x02Help\x02] #{$bot.help[matches[:command]]}"
    else
      privmsg! [channel.is_channel? ? channel : username], "[\x02Help\x02] Could not find help documentation for command \"#{matches[:command]}\"!"
    end
  end
end