# frozen_string_literal: true

module Lite
  module Command
    module Metadata
      module Runtime

        private

        def current_execution_time
          Time.respond_to?(:current) ? Time.current : Time.now
        end

        def before_execution_runtime_metadata
          metadata.started_at = current_execution_time
        end

        def after_execution_runtime_metadata
          metadata.finished_at = current_execution_time
          metadata.runtime = metadata.finished_at - metadata.started_at
        end

      end
    end

  end
end
