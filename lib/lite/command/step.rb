# frozen_string_literal: true

module Lite
  module Command
    class Step

      # TODO: allow procs

      attr_reader :command, :options

      def initialize(command, options)
        @command = command
        @options = options
      end

      def execute?
        options[:from] || :context
      end

    end
  end
end
