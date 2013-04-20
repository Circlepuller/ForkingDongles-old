# coding: utf-8

module ForkingDongles
  module Plugin
    class Loader
      include EventMachine::Deferrable

      def initialize
        files = Dir.glob 'plugins/*.rb'

        EventMachine::Iterator.new(files).map(proc do |file, iteration|
          $bot.logger.info "Loading #{file}..."

          begin
            load "./#{file}"
          rescue Exception => exception
            $bot.logger.error exception.inspect
            iteration.return false
          else
            $bot.logger.info "Loaded #{file}."
            iteration.return true
          end
        end, proc do |results|
          if files.length == results.count(true)
            succeed files, results
          else
            fail files, results 
          end
        end)
      end
    end
  end
end