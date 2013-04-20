#!/usr/bin/env ruby
# coding: utf-8

FORKINGDONGLES_VERSION = '0.1.1'
FORKINGDONGLES_AUTHOR = 'Circlepuller'

require 'rubygems'
require 'bundler/setup'

require 'cgi'
require 'eventmachine'
require 'logger'
require 'nokogiri'
require 'ostruct'
require 'yaml'

require_relative 'commands'
require_relative 'bot'
require_relative 'keyboard'
require_relative 'plugin'

EventMachine.run do
  Signal.trap 'INT' { EventMachine::Timer.new(5) { EventMachine.stop }}
  Signal.trap 'TERM' { EventMachine::Timer.new(5) { EventMachine.stop }}

  config = YAML.load_file 'config.yml'
  $bot = EventMachine.connect config['server'], config['port'], ForkingDongles::Bot, config
  EventMachine.open_keyboard ForkingDongles::Keyboard
end