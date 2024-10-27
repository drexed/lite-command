# frozen_string_literal: true

require "securerandom" unless defined?(SecureRandom)

module Lite
  module Command
    module Internals
      module Runtimes

        def index
          @index ||= context.index ||= 0
        end

        def cmd_id
          @cmd_id ||= context.cmd_id ||= SecureRandom.uuid
        end

        private

        def assign_execution_cmd_id
          @cmd_id = context.cmd_id ||= cmd_id
        end

        def increment_execution_index
          @index = context.index = index.next
        end

        def start_monotonic_time
          @start_monotonic_time ||= Utils.monotonic_time
        end

        def stop_monotonic_time
          @stop_monotonic_time ||= Utils.monotonic_time
        end

        def runtime
          stop_monotonic_time - start_monotonic_time
        end

      end
    end
  end
end
