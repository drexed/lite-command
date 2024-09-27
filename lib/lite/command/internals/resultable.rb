# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Resultable

        def index
          @index ||= context.index ||= 0
        end

        def results
          context.results ||= []
        end

        def result
          if pending? || thrown_fault?
            state
          else
            status
          end
        end

        def to_hash
          {
            index: index,
            command: self.class.name,
            result:,
            state:,
            status:,
            reason:,
            fault: faulter&.index,
            throw: thrower&.index,
            runtime: execution_runtime
          }.compact
        end
        alias to_h to_hash

        private

        def append_execution_result
          results.push(self).sort_by!(&:index)
        end

      end
    end
  end
end
