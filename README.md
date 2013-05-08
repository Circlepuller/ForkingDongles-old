ForkingDongles
==============
An asynchronous, pluggable, evented IRC bot framework written using
EventMachine and Ruby.

To-Do
-----
* <b>Proper documentation</b>: Documentation that is formatted and understandable.
* <b>Modular plugins</b>: Plugins that are actually modular, getting rid of several issues:

```ruby
class ForkingDongles::Plugin::Counter < ForkingDongles::Plugin::Base
  def initialize bot
    super
    
    @bot.help['*count'] = '*count - Counts the amount the command has been called.'
    @count = 0
    
    privmsg? /^\*count$/, &count
  end
  
  def count matches, source, channel, line
    username, ident, hostname = source.to_user
    
    privmsg! [channel.is_channel? ? channel : username], "Counted #{@count += 1} times so far"
  end
end
```

Usage
-----
Barely any work is required to get the bot running. Edit the variables in
config.yml, and start the bot with `ruby forkingdongles.rb`. The script should
install required gems, unless you have added a plugin and forgot to add them to
the Gemfile.
