# frozen_string_literal: true

module Lite
  module Command
    module Metadata
      module Tracing

        def trace
          @trace ||= Lite::Command::Trace.init(context.trace.to_h)
        end

        def trace_key
          # Define in your class to enable tracing.
          # eg: :parent, :__child
        end

        private

        def before_execution_tracing_metadata
          return if trace_key.nil?

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
