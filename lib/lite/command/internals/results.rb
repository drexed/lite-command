# frozen_string_literal: true

require "securerandom" unless defined?(SecureRandom)

module Lite
  module Command
    module Internals
      module Results

        def index
          @index ||= context.index ||= 0
        end

        def cmd_id
          @cmd_id ||= context.cmd_id ||= SecureRandom.uuid
        end

        def outcome
          return state if pending? || thrown?

          status
        end

        def results
          @results ||= context.results ||= []
        end

        def to_hash
          {
            index:,
            cmd_id:,
            command: self.class.name,
            outcome:,
            state:,
            status:,
            reason:,
            metadata:,
            caused_by: caused_by&.index,
            thrown_by: thrown_by&.index,
            runtime:
          }.compact
        end
        alias to_h to_hash

        private

        def assign_execution_cmd_id
          @cmd_id = context.cmd_id ||= cmd_id
        end

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
