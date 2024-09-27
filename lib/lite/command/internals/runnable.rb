# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Runnable

        def index
          @index ||= context.index ||= 0
        end

        private

        def before_execution_monotonic_time
          @before_execution_monotonic_time ||= Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end

        def after_execution_monotonic_time
          @after_execution_monotonic_time ||= Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end

        def execution_runtime
          after_execution_monotonic_time - before_execution_monotonic_time
        end

        def increment_execution_index
          @index = context.index = index.next
        end

      end
    end
  end
end
