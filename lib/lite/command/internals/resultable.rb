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
            index: trace.index,
            trace: trace.to_fs,
            command: self.class.name,
            result:,
            state:,
            status:,
            reason:,
            fault: faulter&.trace&.index,
            throw: thrower&.trace&.index
          }.merge!(metadata.to_h).compact_blank
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
