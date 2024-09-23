# frozen_string_literal: true

module Lite
  module Command
    module Faults
      # Fault represent a stoppage call execution due to some
      # condition not being met. This error should not be raised
      # directly since it wont provide any context.
      class Base < StandardError

        attr_reader :faulter, :thrower, :reason

        def initialize(faulter, thrower, reason)
          @faulter = faulter
          @thrower = thrower
          @reason = reason
          super(reason)
        end

      end
    end
  end
end
