# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Resultable

        def index
          @index ||= context.index ||= 0
        end

        def outcome
          return state if pending? || thrown_fault?

          status
        end

        def results
          context.results ||= []
        end

        private

        def increment_execution_index
          @index = context.index = index.next
        end

        def start_monotonic_time
          @start_monotonic_time ||= Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end

        def stop_monotonic_time
          @stop_monotonic_time ||= Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end

        def runtime
          stop_monotonic_time - start_monotonic_time
        end

        def append_execution_result
          results.push(self).sort_by!(&:index)
        end

        def freeze_execution_objects
          context.freeze if index == 1
          freeze
        end

      end
    end
  end
end
