# frozen_string_literal: true

module Lite
  module Command
    module Step
      module Resultable

        def self.included(base)
          base.class_eval do
            delegate :as_json, to: :to_h
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
            step: self.class.name,
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
