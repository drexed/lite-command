# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Traceable

        def trace
          @trace ||= Lite::Command::Trace.init(context.trace.to_h)
        end

        def trace_key
          # Define in your class to enable tracing.
          # eg: :parent, :__child
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
end
