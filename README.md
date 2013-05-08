ForkingDongles
==============
An asynchronous, pluggable, evented IRC bot framework written using
EventMachine and Ruby.

To-Do
-----
* ''Proper documentation'': Documentation that is formatted and understandable.
* ''Modular plugins'': Plugins that are actually modular, getting rid of several issues:

```ruby
class ForkingDongles::Plugin::H < ForkingDongles::Plugin::Base
  def initialize bot
    super
    
    privmsg? /^h+$/, &h
  end
  
  def h matches, source, channel, line
    username, ident, hostname = source.to_user
    
    privmsg! [channel.is_channel? ? channel : username], 'h'
  end
end
```

Usage
-----
Barely any work is required to get the bot running. Edit the variables in
config.yml, and start the bot with `ruby forkingdongles.rb`. The script should
install required gems, unless you have added a plugin and forgot to add them to
the Gemfile.
