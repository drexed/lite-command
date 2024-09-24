# frozen_string_literal: true

module Lite
  module Command
    class Base

      include Lite::Command::Step::Traceable
      include Lite::Command::Step::Callable
      include Lite::Command::Step::Executable
      include Lite::Command::Step::Resultable

      attr_reader :context, :metadata

      def initialize(context = {})
        @context  = Lite::Command::Construct.build(context)
        @metadata = Lite::Command::Construct.init
      end

      private

      def on_before_execution
        # Define in your class to run code before execution
      end

      def on_after_execution
        # Define in your class to run code after execution
      end

      def on_noop(_error)
        # Define in your class to run code when a NOOP happens
      end

      def on_failure(_error)
        # Define in your class to run code when a Failure happens
      end

      def on_error(error)
        # Define in your class to run code when a StandardError happens
      end

      # Any metadata added can be accessed throught the step lifecyle
      # as well as dumped in to the `to_hash` method
      def assign_metadata_before_execution
        metadata.started_at = Time.current
      end

      def assign_metadata_after_execution
        metadata.finished_at = Time.current
        metadata.runtime = metadata.finished_at - metadata.started_at
      end

    end
  end
end
