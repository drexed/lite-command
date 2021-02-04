# frozen_string_literal: true

module Lite
  module Command
    class Procedure < Complex

      include Lite::Command::Extensions::Errors

      attr_accessor :exit_on_failure

      def execute
        steps.each_with_object([]).with_index do |(command, results), i|
          command.call

          if command.respond_to?(:errors) && command.failure?
            failed_steps << failed_step(i, command)
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

      def failed_steps
        @failed_steps ||= []
      end

      def steps
        @steps ||= @args.flatten
      end

      private

      def failed_step(index, command)
        {
          index: index,
          step: index + 1,
          name: command.class.name,
          args: command.args,
          errors: command&.errors&.full_messages
        }
      end

    end
  end
end
