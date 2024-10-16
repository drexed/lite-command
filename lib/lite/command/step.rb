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
        Utils.evaluate(cmd, options)
      end

    end
  end
end
