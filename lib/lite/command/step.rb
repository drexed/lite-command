# frozen_string_literal: true

module Lite
  module Command
    class Step

      attr_reader :command, :options

      def initialize(command, options)
        @command = command
        @options = options
      end

      def run?(cmd)
        if options[:if]
          Utils.call(cmd, options[:if])
        elsif options[:unless]
          !Utils.call(cmd, options[:unless])
        else
          true
        end
      end

    end
  end
end
