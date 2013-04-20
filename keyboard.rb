# coding: utf-8

module ForkingDongles
  class Keyboard < EventMachine::Connection
    include EventMachine::Protocols::LineProtocol

    def receive_line line
      if $bot.connected
        $bot.send_line line
      else
        $bot.logger.error 'You are not connected to any networks!'
      end
    end
  end
end