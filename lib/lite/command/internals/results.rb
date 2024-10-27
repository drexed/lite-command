# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Results

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
            caused_exception: Utils.pretty_exception(caused_by&.original_exception),
            thrown_by: thrown_by&.index,
            thrown_exception: Utils.pretty_exception(thrown_by&.fault_exception),
            runtime:
          }.compact
        end
        alias to_h to_hash

        private

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
