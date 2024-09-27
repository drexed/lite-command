# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Resultable

        def self.included(base)
          base.class_eval do
            def_delegators :to_h, :as_json
          end
        end

        def results
          context.results ||= Lite::Command::Results.new
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
            index: result_index,
            command: self.class.name,
            result:,
            state:,
            status:,
            reason:,
            fault: faulter&.result_index,
            throw: thrower&.result_index,
            runtime: execution_runtime
          }.compact
        end
        alias to_h to_hash

        private

        def append_execution_result
          results << self
        end

      end
    end
  end
end
