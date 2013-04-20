# coding: utf-8

module ForkingDongles
  class Bot < EventMachine::Connection
    include EventMachine::Protocols::LineProtocol

    ##
    # OStruct containing configuration variables.

    attr_reader :config

    ##
    # Boolean that indicates whether the bot is connected to the server or not.

    attr_reader :connected

    ##
    # Hash containing event handlers for plugins loaded by ForkingDongles.

    attr_reader :handlers

    ##
    # Hash containing help documentations for plugin commands.

    attr_reader :help

    ##
    # Logger used by ForkingDongles.

    attr_reader :logger

    ##
    # Time that ForkingDongles was started at.

    attr_reader :start_time

    ##
    # Initializes all the variables used by the bot.

    def initialize config
      @config = config.to_ostruct_recursive
      @connected = false
      @handlers = {
        :CONNECTED    => [],
        :DISCONNECTED => [],
        :INVITE       => [],
        :JOIN         => [],
        :LOAD         => [],
        :NICK         => [],
        :PART         => [],
        :PING         => [],
        :PRIVMSG      => [],
        :QUIT         => [],
        :UNLOAD       => []
      }
      @help = Hash.new
      @logger = Logger.new STDOUT
      @start_time = Time.new

      loader = load_plugins
      loader.errback { handle :LOAD }
      loader.callback { handle :LOAD }
    end

    def connection_completed
      connection_really_completed unless @config.ssl
    end

    ##
    # Called when ForkingDongles is allowed to send IRC messages to the server.

    def connection_really_completed
      EventMachine::Timer.new(5) do
        @connected = true

        handle :CONNECTED
      end
    end

    ##

    def load_config
      config = @config

      begin
        @config = (YAML.load_file 'config.yml').to_ostruct_recursive
      rescue Exception => exception
        @config = config
        @logger.error exception.inspect
      end
    end

    def load_plugins &handler
      handle :UNLOAD

      @help.clear
      @handlers = {
        :CONNECTED    => [],
        :DISCONNECTED => [],
        :INVITE       => [],
        :JOIN         => [],
        :LOAD         => [],
        :NICK         => [],
        :PART         => [],
        :PING         => [],
        :PRIVMSG      => [],
        :QUIT         => [],
        :UNLOAD       => []
      }

      load_config

      ForkingDongles::Plugin::Loader.new
    end

    def post_init
      start_tls if @config.ssl
    end

    def receive_line line
      prefix, command, params = line.to_message

      if @handlers.has_key? command.to_sym
        params = [prefix, *params] if prefix

        handle command.to_sym, *params
      end
    end

    def handle action, *args
      EventMachine::Iterator.new(@handlers[action]).each do |handler, iteration|
        begin
          if action == :PRIVMSG
            matches = handler[0].match args[2]

            if matches
              @logger.info "Invoking #{action.id2name} handler"
              handler[1].call matches, *args
            end
          else
            @logger.info "Invoking #{action.id2name} handler"
            handler.call *args
          end
        rescue Exception => exception
          @logger.error exception.inspect
        end

        iteration.next
      end
    end

    ##
    # Sends an RFC 1459 compliant IRC message.

    def send_line line
      prefix, command, params = line.to_message
      send_data "#{line.strip}\r\n"
    end

    def ssl_handshake_completed
      connection_really_completed
    end

    def unbind
      handle :DISCONNECTED

      @connected = false
      @logger.info 'Quitting...'
      @logger.close
    end
  end
end