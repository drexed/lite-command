# frozen_string_literal: true

module Lite
  module Command
    class Procedure < Complex

      include Lite::Command::Extensions::Errors

      attr_accessor :exit_on_failure

      def execute
        steps.each_with_object([]) do |command, results|
          command.call

          if command.respond_to?(:errors) && command.failure?
            merge_errors!(command) if respond_to?(:errors)
            break results if exit_on_failure?
          else
            results << command.result
          end
        end
      end

      def exit_on_failure?
        @exit_on_failure ||= false
      end

      def steps
        @steps ||= @args.flatten
      end

    end
  end
end
