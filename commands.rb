# coding: utf-8

class Hash
  def to_ostruct_recursive options={}
    convert_to_ostruct_recursive self, options
  end

  def with_sym_keys
    self.inject({}) do |memo, (k, v)|
      memo[k.to_sym] = v
      memo
    end
  end

  private

  def convert_to_ostruct_recursive obj, options
    result = obj

    if result.is_a? Hash
      result = result.dup.with_sym_keys

      result.each do |k, v|
        result[k] = convert_to_ostruct_recursive v, options unless options.has_key? :exclude and options[:exclude].try :include?, k
      end

      result = OpenStruct.new result
    elsif result.is_a? Array
      result = result.map { |r| convert_to_ostruct_recursive r, options }
    end

    result
  end
end

module Kernel
  def returning value
    yield value
    value
  end unless defined? returning
end

class String
  def bold
    "\x02#{self}\x02"
  end

  ##
  # Checks if the String is a valid IRC channel.
  #
  # Returns +true+ if the String is a valid IRC message, +false+ otherwise.

  def is_channel?
    self.match /^([#&]+)(.+)$/
  end

  ##
  # Checks if the String is a valid IRC user.
  #
  # Returns +true+ if the String is a valid IRC user, +false+ otherwise.

  def is_user?
    self.match /[!@]/
  end

  def sanitize
    CGI.unescapeHTML Nokogiri.HTML(self).text.gsub /\s+/, ' '
  end

  def to_message
    prefix, command, raw_params = self.match(/(^:(\S+) )?(\S+)(.*)/).captures[1..-1]

    raw_params.strip!

    if match = raw_params.match(/:(.*)/)
      params = match.pre_match.split ' '
      params << match[1]
    else
      params = raw_params.split ' '
    end

    return prefix, command, params
  end

  def to_user
    self.split(/[!@]/, 3)
  end

  def truncate limit=100
    too_long = self.length > limit
    text = too_long ? self[0..(limit - 1)] : self

    too_long ? "#{text[0..text.rindex(' ') - 1]}..." : text
  end

  def unhighlight
    self.length > 1 ? (self.split.map { |token| "#{token[0]}\u2063#{token[1..-1]}" }.join ' ') : self
  end
end

def command? command, &handler
  return unless command.is_a? Numeric

  command = command.to_i.to_s.to_sym

  $bot.handlers[command] = [] unless $bot.handlers.has_key? command
  $bot.handlers[command] << handler
end

def connected? &handler
  $bot.handlers[:CONNECTED] << handler
end

def disconnected? &handler
  $bot.handlers[:DISCONNECTED] << handler
end

def invite? &handler
  $bot.handlers[:INVITE] << handler
end

##
# Sends an RFC 1459 compliant JOIN message.

def join! channels, keys=[]
  $bot.send_line "JOIN #{channels.join ','} #{keys.join ','}"
end

##
# Called when ForkingDongles receives a JOIN message.

def join? &handler
  $bot.handlers[:JOIN] << handler
end

##
# Sends an RFC 1459 compliant KILL message.

def kill! nickname, comment=''
  $bot.send_line "KILL #{nickname} #{comment}"
end

def load? &handler
  $bot.handlers[:LOAD] << handler
end

##
# Sends an RFC 1459 compliant NICK message.

def nick! nickname
  $bot.send_line "NICK #{nickname}"
end

##
# Called when ForkingDongles receives a NICK message.

def nick? &handler
  $bot.handlers[:NICK] << handler
end

##
# Sends an RFC 1459 compliant PART message.

def part! channels
  $bot.send_line "PART #{channels.join ','}"
end

##
# Called when ForkingDongles receives a PART message.

def part? &handler
  $bot.handlers[:PART] << handler
end

##
# Sends an RFC 1459 compliant PING message.

def ping! server1, server2=''
  $bot.send_line "PING #{server1} #{server2}"
end

def ping? &handler
  $bot.handlers[:PING] << handler
end

##
# Sends an RFC 1459 compliant PONG message.

def pong! daemon, daemon2=''
  $bot.send_line "PONG #{daemon} #{daemon2}"
end

##
# Sends an RFC 1459 compliant PRIVMSG message.

def privmsg! receivers, text
  $bot.send_line "PRIVMSG #{receivers.join ','} :#{text}"
end

##
# Called when ForkingDongles receives a PRIVMSG message.

def privmsg? pattern, &handler
  $bot.handlers[:PRIVMSG] << [pattern, handler]
end

##
# Sends an RFC 1459 compliant QUIT message.

def quit! message
  $bot.send_line "QUIT :#{message}"
end

##
# Called when ForkingDongles receives a QUIT message.

def quit? &handler
  $bot.handlers[:QUIT] << handler
end

def unload? &handler
  $bot.handlers[:UNLOAD] << handler
end

##
# Sends an RFC 1459 compliant USER command.

def user! username, hostname='0', servername='*', realname=nil
  $bot.send_line "USER #{username} #{hostname} #{servername} :#{realname ? realname : username}"
end