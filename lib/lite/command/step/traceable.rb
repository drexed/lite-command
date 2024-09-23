# frozen_string_literal: true

module Lite::Command
  module Step
    module Traceable
      extend ActiveSupport::Concern

      def trace
        @trace ||= Lite::Command::Trace.init(context.trace.to_h)
      end

      private

      def advance_execution_trace
        return if trace_key.blank?

        @trace = context.trace = begin
          new_trace = trace.advance(trace_key)
          new_trace.freeze
          new_trace
        end
      end
    end
  end
end
