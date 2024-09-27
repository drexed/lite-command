# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Resultable

        def index
          @index ||= context.index ||= 0
        end

        def result
          return state if pending? || thrown_fault?

          status
        end

        def results
          context.results ||= []
        end

        private

        def before_execution_monotonic_time
          @before_execution_monotonic_time ||= Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end

        def after_execution_monotonic_time
          @after_execution_monotonic_time ||= Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end

        def runtime
          after_execution_monotonic_time - before_execution_monotonic_time
        end

        def append_execution_result
          results.push(self).sort_by!(&:index)
        end

        def increment_execution_index
          @index = context.index = index.next
        end

      end
    end
  end
end
