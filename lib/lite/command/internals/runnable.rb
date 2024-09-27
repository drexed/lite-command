# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Runnable

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

      end
    end
  end
end
